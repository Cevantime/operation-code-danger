extends CharacterBody2D


enum STATES {
	SPAWNING,
	NORMAL,
	HIT,
	DEAD
}

var is_shooting := false
var is_crouching := false
var current_velocity := Vector2.ZERO
var state = STATES.SPAWNING
var direction := Vector2.ZERO
var inspecting = false
var inspected_show: ShowResource:
	set(v):
		inspected_show = v
		if inspected_show != null:
			show_assigned.emit(inspected_show)
			play_emotion("question", true)
		else:
			show_unassigned.emit()
			stop_emotion()

@export var controlled = false

signal died
signal touched
signal deadly_touched
signal show_assigned(show)
signal show_unassigned(show)
signal show_inspected(show)
signal show_uninspected

@onready var top_animation_player: AnimationPlayer = %TopAnimationPlayer
@onready var legs_animation_player: AnimationPlayer = %LegsAnimationPlayer
@onready var top_sprite_2d: Sprite2D = %TopSprite2D
@onready var legs_sprite_2d: Sprite2D = %LegsSprite2D
@onready var shoot_ray_cast_2d: RayCast2D = %ShootRayCast2D
@onready var health_component: HealthComponent = %HealthComponent
@onready var global_animation_player: AnimationPlayer = %GlobalAnimationPlayer
@onready var target_sprite_2d: Sprite2D = %TargetSprite2D
@onready var emotion: Node2D = %Emotion
@onready var gun_audio_stream_player: AudioStreamPlayer = %GunAudioStreamPlayer

@export var SPEED := 50.0
@export var CROUCH_SPEED := 30.0


func _ready():
	top_animation_player.animation_finished.connect(_on_top_animation_player_animation_finished)
	hide()
	
func _process(delta: float) -> void:
	emotion.position = top_sprite_2d.offset - Vector2(0, 45)
	
	if state in [STATES.SPAWNING, STATES.DEAD]:
		return
		
	if controlled:
		direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
		
		if Input.is_action_just_pressed("interact"):
			if inspecting:
				stop_inspecting()
			elif inspected_show != null:
				start_inspecting()
		
		is_shooting = Input.is_action_pressed("shoot")
		
		if Input.is_action_just_pressed("crouch") and state == STATES.NORMAL:
			is_crouching = !is_crouching
			if is_crouching:
				legs_animation_player.play("start_crouching")
			else:
				legs_animation_player.play_backwards("start_crouching")
	
	var target_velocity = Vector2.ZERO
	
	if state == STATES.NORMAL:
		if is_shooting and top_animation_player.current_animation != "" and top_animation_player.current_animation not in ["start_aiming", "shoot"]:
			top_animation_player.play("start_aiming")
		
		elif not is_shooting:
			top_animation_player.play("guard")
		
		var speed = CROUCH_SPEED if is_crouching else SPEED
		target_velocity = speed * direction
	
	velocity = lerp(velocity, target_velocity, delta * 15.0)
		
	move_and_slide()
	
	if state == STATES.NORMAL:
		if shoot_ray_cast_2d.is_colliding():
			target_sprite_2d.show()
			target_sprite_2d.global_position = shoot_ray_cast_2d.get_collider().global_position + Vector2(0, 0 if is_crouching else -16)
			
		else:
			target_sprite_2d.hide()
		var significant_h_speed = direction.x != 0
		if significant_h_speed:
			for sprite_2d in [top_sprite_2d, legs_sprite_2d]:
				sprite_2d.scale.x = 1 if velocity.x > 0 else -1
		
		if direction != Vector2.ZERO and legs_animation_player.current_animation != "start_crouching":
			legs_animation_player.play("crouching" if is_crouching else "walking")
		elif legs_animation_player.current_animation != "start_crouching":
			legs_animation_player.play("crouch" if is_crouching else "waiting")
	
func start_inspecting():
	show_inspected.emit(inspected_show)
	inspecting = true
	
func stop_inspecting():
	show_uninspected.emit()
	inspecting = false
	
	
func _on_top_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "start_aiming" and is_shooting:
		top_animation_player.play("shoot")
		
func shoot():
	gun_audio_stream_player.play()
	if shoot_ray_cast_2d.is_colliding():
		var collider = shoot_ray_cast_2d.get_collider()
		collider.shot(self)

func recept():
	legs_animation_player.play("reception")
	await legs_animation_player.animation_finished
	state = STATES.NORMAL

func spawn_and_recept():
	global_animation_player.play("spawn")
	await global_animation_player.animation_finished
	await recept()
	
	
func face(node):
	for sprite_2d in [top_sprite_2d, legs_sprite_2d]:
		sprite_2d.scale.x = 1 if node.global_position.x > global_position.x else -1

func go_left():
	direction = Vector2(-1, 0)
	
func go_right():
	direction = Vector2(1, 0)
	
func stop():
	is_shooting = false
	direction = Vector2.ZERO

func start_crouching():
	is_crouching = true
	legs_animation_player.play("start_crouching")
	await legs_animation_player.animation_finished
	
func stop_crouching():
	is_crouching = false
	legs_animation_player.play_backwards("start_crouching")
	await legs_animation_player.animation_finished
	
func spawn_and_crouch():
	global_animation_player.play("spawn")
	await global_animation_player.animation_finished
	await start_crouching()
	state = STATES.NORMAL
	
func salute(forward = true):
	set_process(false)
	legs_animation_player.stop()
	if forward:
		top_animation_player.play("salute")
	else:
		top_animation_player.play_backwards("salute")
	await top_animation_player.animation_finished
	
	
func play_emotion(emotion_name, permanently = false):
	await emotion.play_emotion(emotion_name, permanently)
	
	
func stop_emotion():
	emotion.stop_emotion()
	
func _on_hit_box_area_entered(area: Area2D) -> void:
	if not area.owner.is_at_player_level():
		return
	if state in [STATES.SPAWNING, STATES.DEAD]:
		return
	state = STATES.HIT
	health_component.decrease(20.0)
	top_animation_player.play("hit_head")
	global_animation_player.play("hit")
	velocity.x = 100.0 * sign(global_position.x - area.global_position.x)
	await top_animation_player.animation_finished
	if state != STATES.DEAD:
		top_animation_player.play("guard")
		state = STATES.NORMAL


func _on_health_component_died() -> void:
	state = STATES.DEAD
	is_crouching = false
	is_shooting = false
	
	deadly_touched.emit()
	
	collision_layer = 0
	await top_animation_player.animation_finished
	
	top_animation_player.play("die")
	legs_animation_player.play("die")
	await top_animation_player.animation_finished
	global_animation_player.play("disappear")
	await global_animation_player.animation_finished
	died.emit()
	queue_free()
	
func _on_health_component_changed(new_value: int, old_value: int):
	if new_value < old_value:
		touched.emit()