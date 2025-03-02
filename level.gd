extends Node2D

@onready var intro_gordon_spawner: Marker2D = %IntroGordonSpawner
@onready var gordon_spawner: Marker2D = %GordonSpawner
@onready var ui: CanvasLayer = %UI
@onready var camera_2d: Camera2D = %Camera2D
@onready var menu: CanvasLayer = %Menu
@onready var gameover_layer: CanvasLayer = %GameoverLayer
@onready var first_spectator_spawner: Marker2D = %FirstSpectatorSpawner
@onready var first_wave_trigger_zone: Area2D = %FirstWaveTriggerZone
@onready var second_wave_trigger_zone: Area2D = %SecondWaveTriggerZone
@onready var ophelie_spawner: Marker2D = %OphelieSpawner
@onready var count_ennemy_timer: Timer = %CountEnnemyTimer
@onready var poster_layer: CanvasLayer = %PosterLayer
@onready var interact_action_icon: ActionIcon = %InteractActionIcon
@onready var gordon_2_spawner: Marker2D = %Gordon2Spawner
@onready var spawners: Node2D = %Spawners
@onready var music_audio_stream_player: AudioStreamPlayer = %MusicAudioStreamPlayer
@onready var end_panel_layer: CanvasLayer = %EndPanelLayer
@onready var mobile_input_container: Control = %MobileInputContainer


@export var gordon_data: GordonData

var balloon
var gordon
var last_entered_zone
var music_stream: AudioStreamInteractive

func _ready() -> void:
	mobile_input_container.visible = is_mobile_with_touchscreen()
	gordon_data.name = GlobalState.selected_gordon
	Progress.prefix = gordon_data.code_name
	music_stream = music_audio_stream_player.stream
	intro_gordon_spawner.packed_scene = gordon_data.packed_scene
	gordon_spawner.packed_scene = gordon_data.packed_scene
	gordon_2_spawner.packed_scene = gordon_data.other_gordon_packed_scene
	gordon_data.changed.connect(_on_gordon_changed)
	#Progress.write(Progress.INTRO_DONE, false)
	if not Progress.read(Progress.INTRO_DONE):
		intro_gordon_spawner.spawn()
	else:
		gordon_spawner.spawn()
		
	gordon_2_spawner.spawn()
	for tz in get_tree().get_nodes_in_group("trigger_zone"):
		tz.entered.connect(_on_tz_entered)
	
	for spawner in spawners.get_children():
		spawner.spawned.connect(_on_ennemy_spawner_spawned)

func is_mobile_with_touchscreen() -> bool:
	return OS.has_feature("mobile") and DisplayServer.is_touchscreen_available()

func _on_ennemy_spawner_spawned(ennemy):
	ennemy.died.connect(_on_ennemy_died.bind(ennemy))


func _on_ennemy_died(ennemy):
	GlobalState.score += ennemy.score_increment
	if randi_range(0, 3) == 0:
		if randi_range(0, 1) == 0:
			play("%s/ha ha ca t apprendra" % gordon_data.code_name)
		else:
			await get_tree().create_timer(0.3).timeout
			play("%s/vile salopard" % gordon_data.code_name)
			

func _on_gordon_changed():
	gordon_spawner.packed_scene = gordon_data.packed_scene
	Progress.prefix = gordon_data.code_name
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_menu") and gordon.controlled:
		menu.display()

func wait(secs):
	await get_tree().create_timer(secs).timeout
	
func use_joypad():
	return ActionIcon.use_joypad()
	
func get_action_icon(action):
	return ActionIcon.get_icon_texture(action).resource_path
	
func action_bb(action):
	return "[img]%s[/img]" % get_action_icon(action)
	
func _on_intro_gordon_spawner_spawned(g: Node) -> void:
	gordon = g
	await gordon.ready
	await run_dialogue("intro")
	await get_tree().create_timer(0.3).timeout
	configure_gordon(gordon)
	
	
func _on_gordon_spawner_spawned(g: Node) -> void:
	gordon = g
	await gordon.ready
	await gordon.spawn_and_recept()
	configure_gordon(gordon)

func configure_gordon(g):
	g.touched.connect(_on_gordon_touched)
	g.deadly_touched.connect(_on_gordon_deadly_touched)
	g.died.connect(_on_gordon_died)
	g.show_assigned.connect(_on_gordon_show_assigned)
	g.show_unassigned.connect(_on_gordon_show_unassigned)
	g.show_inspected.connect(_on_gordon_show_inspected)
	g.show_uninspected.connect(_on_gordon_show_uninspected)
	camera_2d.followed_node = g
	
	if not g.is_node_ready():
		await g.ready
	
	ui.health_progress_bar.value_node = g.health_component
	ui.show()
	
	if not Progress.read(Progress.COMMANDS_DONE) and not is_bernard():
		run_dialogue("commands")
	
	g.controlled = true
	
func _on_gordon_touched():
	GlobalState.score -= 100


func _on_gordon_deadly_touched():
	play("%s/gordon il m a eu" % gordon_data.code_name)
	

func _on_gordon_died():
	if GlobalState.lives == 1:
		game_over()
		return
	GlobalState.lives -= 1
	await get_tree().create_timer(1.0).timeout
	gordon_spawner.spawn()

func _on_gordon_show_inspected(show_resource: ShowResource):
	poster_layer.poster_texture = show_resource.big_poster
	poster_layer.title = show_resource.title
	poster_layer.text = show_resource.presentation_text
	poster_layer.show()
	if balloon == null or not balloon.is_inside_tree():
		gordon.controlled = false
		gordon.stop()
		await wait(1)
		await run_dialogue(show_resource.dialogue, "", [ {"inspected_show": show_resource}])
		gordon.stop_inspecting()
		gordon.controlled = true
	

func is_bernard():
	return gordon_data.code_name == "bernard"
	
func _on_gordon_show_uninspected():
	poster_layer.poster_texture = null
	poster_layer.hide()

func _on_gordon_show_assigned(_show):
	interact_action_icon.show()
	
func _on_gordon_show_unassigned():
	interact_action_icon.hide()
	
func game_over():
	menu.prevent_cancel()
	await get_tree().create_timer(1.0).timeout
	gameover_layer.show()
	await get_tree().create_timer(2.0).timeout
	gameover_layer.hide()
	menu.display()
	
	
func run_dialogue(dialogue_name, title: String = "", extra_game_states: Array = []):
	if is_instance_valid(balloon):
		await balloon.tree_exited
	await get_tree().process_frame
	var dialogue = load("res://asset/dialogues/%s/%s.dialogue" % [gordon_data.code_name, dialogue_name]) if dialogue_name is String else dialogue_name
	balloon = DialogueManager.show_dialogue_balloon(dialogue, title, extra_game_states)
	await balloon.tree_exited
	
func play(sound_name):
	var player = SoundManager.play_sound(load("res://asset/sounds/%s.ogg" % sound_name), "Dialogue")
	await player.finished
	

func _on_menu_visibility_changed() -> void:
	get_tree().paused = menu.visible


func _on_menu_restart_requested() -> void:
	restart()

func restart():
	GlobalState.lives = 3
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func _on_tz_entered(zone):
	last_entered_zone = zone
	count_ennemy_timer.start()
	if zone.blocking:
		camera_2d.follow_the_node = false


func _on_count_ennemy_timer_timeout() -> void:
	var ennemy_count = get_tree().get_nodes_in_group("ennemy").size()
	if ennemy_count > 0 and music_audio_stream_player["parameters/switch_to_clip"] != "Battle":
		music_audio_stream_player["parameters/switch_to_clip"] = "Battle"
		if randi_range(0, 3) == 0:
			play("%s/et pour l injustice" % gordon_data.code_name)
	if ennemy_count == 0 and not camera_2d.follow_the_node:
		count_ennemy_timer.stop()
		music_audio_stream_player["parameters/switch_to_clip"] = "Walk"
		zone_completed(last_entered_zone)
		for l in get_tree().get_nodes_in_group("alarm_lights"):
			l.stop()
		camera_2d.follow_the_node = true
		ui.display_go()
		await get_tree().create_timer(2.0).timeout
		ui.hide_go()

func zone_completed(zone):
	if zone == first_wave_trigger_zone and not Progress.read(Progress.FIRST_WAVE_SUCCESS):
		run_dialogue("first_wave_success")
	elif zone == second_wave_trigger_zone and not Progress.read(Progress.SECOND_WAVE_SUCCESS):
		run_dialogue("second_wave_success")
	
func _on_meet_spectator_trigger_zone_entered(_this: Variant) -> void:
	if not Progress.read(Progress.FIRST_SPECTATOR_MET) and not is_bernard():
		var ennemy = first_spectator_spawner.spawn()
		await ennemy.ready
		ennemy.states.change_state("Controlled")
		if balloon != null and is_instance_valid(balloon):
			await balloon.tree_exited
			await get_tree().process_frame
		run_dialogue("first_spectator_met", "", [ {"ennemy": ennemy}])
	else:
		await get_tree().process_frame
		camera_2d.follow_the_node = true
		
func wait_for_death(node):
	await node.tree_exited


func _on_nice_walk_trigger_zone_entered(_this: Variant) -> void:
	if not Progress.read(Progress.NICE_WALK_DONE) and not is_bernard():
		run_dialogue("nice_walk")


func _on_reset_progress_button_pressed() -> void:
	Progress.reset()
	restart()


func _on_first_wave_trigger_zone_entered(_this: Variant) -> void:
	if not Progress.read(Progress.FIRST_WAVE_DONE):
		run_dialogue("first_wave")


func _on_second_wave_trigger_zone_entered(_this: Variant) -> void:
	if not Progress.read(Progress.SECOND_WAVE_DONE):
		run_dialogue("second_wave")


func _on_meet_ophelie_trigger_zone_entered(_this: Variant) -> void:
	var ophelie = ophelie_spawner.spawn()
	if not Progress.read(Progress.OPHELIE_MET) and not is_bernard():
		await ophelie.ready
		run_dialogue("ophelie_met", "", [ {"ophelie": ophelie}])
	

func ennemies_walk_toward_player():
	for e in get_tree().get_nodes_in_group("ennemy"):
		e.targeted_player = gordon
		e.go_toward_player()
		
func ennemies_idle():
	for e in get_tree().get_nodes_in_group("ennemy"):
		e.states.change_state('Idle')
	
func ennemies_stop():
	for e in get_tree().get_nodes_in_group("ennemy"):
		e.stop()


func _on_question_gordon_trigger_zone_entered(_this: Variant) -> void:
	await get_tree().process_frame
	count_ennemy_timer.stop()
	if not Progress.read(Progress.QUESTION_GORDON) and not is_bernard():
		await run_dialogue("question_gordon")
	camera_2d.follow_the_node = true


func _on_poster_zone_entered(_this: Variant) -> void:
	if not Progress.read(Progress.POSTER_DONE):
		run_dialogue("poster")


func _on_salute_zone_entered(_this: Variant) -> void:
	LeaderBoard.submit_score(GlobalState.score)
	await run_dialogue("salute")
	var end_panel_packed = preload("res://end_panel.tscn")
	var end_panel = end_panel_packed.instantiate()
	end_panel_layer.add_child(end_panel)
	

func _on_gordon_2_spawner_spawned(node: Node) -> void:
	await node.ready
	node.show()
