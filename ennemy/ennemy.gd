extends CharacterBody2D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var health_component: HealthComponent = %HealthComponent
@onready var global_animation_player: AnimationPlayer = %GlobalAnimationPlayer
@onready var decision_timer: Timer = %DecisionTimer
@onready var states: SwitchableState = %States
@onready var state_label: Label = %StateLabel
@onready var token_label: Label = %TokenLabel
@onready var ray_cast_2d: RayCast2D = %RayCast2D
@onready var death_audio_stream_player_2d: AudioStreamPlayer2D = %DeathAudioStreamPlayer2D

signal died

var visible_on_screen = false
var target = null
var closest_player: Node2D = null
var target_speed := 0.0
var speed := 0.0
var direction: Vector2
var targeted_player: Node2D:
	set(v):
		if v != targeted_player:
			targeted_player = v
			player_targeted.emit(v)
var attack_token: AttackManager.AttackToken = null:
	set(v):
		attack_token = v
		if v != null:
			receive_attack_token.emit(v)
		else:
			lost_attack_token.emit()
var current_attack

@export var GLOBAL_SPEED = 50.0
@export var score_increment = 200.0
@export var attacks: Array[Attack]

signal was_shot(shooter)
signal receive_attack_token(token)
signal lost_attack_token
signal player_targeted(player)

func _process(_delta: float) -> void:
	state_label.text = states.get_active_state().name
	if attack_token:
		token_label.show()
		token_label.text = "left" if attack_token.left else "right"
	else:
		token_label.hide()
		
	
func get_real_speed():
	return speed * GLOBAL_SPEED
	
func move_with_target_speed(delta):
	speed = lerp(speed, target_speed, delta * 15.0)
	velocity = get_real_speed() * direction
	move_and_slide()
	
func pick_attack():
	if attacks.is_empty():
		return
	attacks.shuffle()
	current_attack = attacks[0]
	return current_attack
	
func shot(shooter):
	if visible_on_screen:
		was_shot.emit(shooter)

func direction_to_targeted_player():
	var t = targeted_player
	if t == null:
		return Vector2.ZERO
	return global_position.direction_to(t.global_position)
	
func distance_to_targeted_player():
	var t = targeted_player
	if t == null:
		return null
	return global_position.distance_to(t.global_position)
	
func find_closest_player():
	var c_player = null
	var min_dist_squared = INF
	for p in get_tree().get_nodes_in_group("player"):
		var dist_squared = p.global_position.distance_squared_to(global_position)
		if dist_squared < min_dist_squared:
			c_player = p
			min_dist_squared = dist_squared
			
	return c_player
	

func process_attack(attack_callback: Callable):
	await attack_callback.call()
		
	
func _on_decision_timer_timeout() -> void:
	targeted_player = find_closest_player()

func fight():
	var attack = pick_attack()
	states.change_state("Fighting", {"attack": attack, "token": attack_token})

func set_controlled():
	if states.get_active_state().name != "Controlled":
		states.change_state("Controlled")

func go_left():
	set_controlled()
	direction = Vector2(-1, 0)
	
func go_right():
	set_controlled()
	direction = Vector2(1, 0)
	
func go_toward_player():
	set_controlled()
	direction = Vector2(sign(direction_to_targeted_player().x), 0)
	
func stop():
	set_controlled()
	direction = Vector2.ZERO
	
func is_at_player_level():
	return ray_cast_2d.is_colliding()
	
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	visible_on_screen = true


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	visible_on_screen = false


func _on_health_component_died() -> void:
	death_audio_stream_player_2d.play()
	died.emit()
