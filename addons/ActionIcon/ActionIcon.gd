@tool
@icon("res://addons/ActionIcon/icon.png")
class_name ActionIcon extends TextureRect

## Use for special actions outside of InputMap. Format is keyboard icon|mouse icon|joypad icon.
const CUSTOM_ACTIONS = {
	"move": "WSAD||LeftStick"
}

const GROUP_NAME = &"action_icons"
const DEFAULT_TEXTURE = preload("res://addons/ActionIcon/Keyboard/Blank.png")

enum { KEYBOARD, MOUSE, JOYPAD }
enum JoypadMode { ADAPTIVE, FORCE_KEYBOARD, FORCE_JOYPAD }
enum FitMode { CUSTOM, MATCH_WIDTH, MATCH_HEIGHT }
enum JoypadModel { AUTO, XBOX, XBOX360, DS3, DS4, DUAL_SENSE, JOY_CON }

const MODEL_MAP = {
	JoypadModel.XBOX: "Xbox",
	JoypadModel.XBOX360: "Xbox360",
	JoypadModel.DS3: "DS3",
	JoypadModel.DS4: "DS4",
	JoypadModel.DUAL_SENSE: "DualSense",
	JoypadModel.JOY_CON: "JoyCon",
}

## Action name from InputMap or CUSTOM_ACTIONS.
@export var action_name: StringName = &"":
	set(action):
		if action == action_name:
			return
		
		action_name = action
		refresh()

## Whether a joypad button should be used or keyboard/mouse.
@export var joypad_mode: JoypadMode = JoypadMode.ADAPTIVE:
	set(mode):
		if mode == joypad_mode:
			return
		
		joypad_mode = mode
		refresh()

## Controller model for the displayed icon.
@export var joypad_model: JoypadModel = JoypadModel.AUTO:
	set(model):
		if model == joypad_model:
			return
		
		joypad_model = model
		if model == JoypadModel.AUTO:
			if not Input.joy_connection_changed.is_connected(_on_joy_connection_changed):
				Input.joy_connection_changed.connect(_on_joy_connection_changed)
		else:
			if Input.joy_connection_changed.is_connected(_on_joy_connection_changed):
				Input.joy_connection_changed.disconnect(_on_joy_connection_changed)
		
			_cached_model = ""
		refresh()

## If action has both keyboard and mouse events, this makes mouse icons preferred if available.
@export var favor_mouse: bool = true:
	set(favor):
		if favor == favor_mouse:
			return
		
		favor_mouse = favor
		refresh()

## Use to control the size of icon inside a container. CUSTOM enables setting strech modes manually using [TextureRect] properties.
@export var fit_mode: FitMode = FitMode.MATCH_WIDTH:
	set(mode):
		if mode == fit_mode and _fit_initialized:
			return
		
		_fit_initialized = true
		
		fit_mode = mode
		match fit_mode:
			FitMode.MATCH_WIDTH:
				expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
				stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			FitMode.MATCH_HEIGHT:
				expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
				stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		notify_property_list_changed()

static var _base_path: String
static var _use_joypad: bool

var _pending_refresh: bool = true
var _fit_initialized: bool
static var _cached_model: String

static func _static_init() -> void:
	_use_joypad = not Input.get_connected_joypads().is_empty()

func _init():
	add_to_group(GROUP_NAME)
	if DisplayServer.keyboard_get_layout_name(DisplayServer.keyboard_get_current_layout()) == "":
		DisplayServer.keyboard_set_current_layout(0)
	texture = DEFAULT_TEXTURE
	
	if _base_path.is_empty():
		_base_path = get_script().resource_path.get_base_dir()

## Forces icon refresh. Useful when you change controls.
func refresh():
	if _pending_refresh or not is_inside_tree():
		return
	_pending_refresh = true
	_refresh.call_deferred()

## Calls [method refresh] on all ActionIcon nodes in the scene tree.
func refresh_all():
	Engine.get_main_loop().call_group(GROUP_NAME, refresh.get_method())

static func use_joypad():
	return _use_joypad
	
static func get_icon_texture(action_name, joypad_mode: JoypadMode = JoypadMode.ADAPTIVE, favor_mouse: bool = false, joypad_model: JoypadModel = JoypadModel.AUTO):
	var is_joypad := (joypad_mode == JoypadMode.FORCE_JOYPAD or (joypad_mode == JoypadMode.ADAPTIVE and _use_joypad))

	
	if action_name in CUSTOM_ACTIONS:
		var image_list: PackedStringArray = CUSTOM_ACTIONS[action_name].split("|")
		assert(image_list.size() >= 3, "Need more |")
		
		if is_joypad and not image_list[JOYPAD].is_empty():
			return _get_image(JOYPAD, "%s/%s" % [_get_joypad_model(0, joypad_model), image_list[JOYPAD]])
		elif not is_joypad:
			if (favor_mouse or image_list[KEYBOARD].is_empty()) and not image_list[MOUSE].is_empty():
				return _get_image(MOUSE, image_list[MOUSE])
			elif image_list[KEYBOARD]:
				return _get_image(KEYBOARD, image_list[KEYBOARD])

	
	var events := _action_get_events(action_name)
	if events.is_empty():
		return DEFAULT_TEXTURE

	
	var keyboard := -1
	var mouse := -1
	var joypad := -1
	var joypad_axis := -1
	var joypad_axis_value: float
	var joypad_id: int
	
	for event in events:
		if event is InputEventKey and keyboard == -1:
			keyboard = DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
		elif event is InputEventMouseButton and mouse == -1:
			mouse = event.button_index
		elif event is InputEventJoypadButton and joypad == -1:
			joypad = event.button_index
			joypad_id = event.device
		elif event is InputEventJoypadMotion and joypad_axis == -1:
			joypad_axis = event.axis
			joypad_axis_value = event.axis_value
			joypad_id = event.device
	
	if is_joypad and joypad >= 0:
		return _get_joypad(joypad, joypad_id)
	elif is_joypad and joypad_axis >= 0:
		return _get_joypad_axis(joypad_axis, joypad_axis_value, joypad_id)
	elif not is_joypad:
		if mouse >= 0 and (favor_mouse or keyboard < 0):
			return _get_mouse(mouse)
		elif keyboard >= 0:
			return _get_keyboard(keyboard)
	
	
func _refresh():
	if not is_visible_in_tree():
		return
	
	texture = get_icon_texture(action_name, joypad_mode, favor_mouse, joypad_model)
	
	_pending_refresh = false
	
	if not texture and action_name != &"":
		push_error("No icon for action: %s" % action_name)

static func _get_keyboard(key: int) -> Texture2D:
	var key_string = OS.get_keycode_string(key)
	if key_string:
		return _get_image(KEYBOARD, key_string)
	return null

static func _get_joypad_model(device: int, joypad_model: JoypadModel) -> String:
	if not _cached_model.is_empty():
		return _cached_model
	
	var model := "Xbox"
	if joypad_model == JoypadModel.AUTO:
		var device_name := Input.get_joy_name(maxi(device, 0))
		if device_name.contains("Xbox 360"):
			model = "Xbox360"
		elif device_name.contains("PS3"):
			model = "DS3"
		elif device_name.contains("PS4"):
			model = "DS4"
		elif device_name.contains("PS5"):
			model = "DualSense"
		elif device_name.contains("Joy-Con") or device_name.contains("Joy Con"):
			model = "JoyCon"
	else:
		model = MODEL_MAP[joypad_model]
	
	_cached_model = model
	return model

static func _get_joypad(button: int, device: int, joypad_model: JoypadModel = JoypadModel.AUTO) -> Texture2D:
	var model := _get_joypad_model(device, joypad_model) + "/"
	
	match button:
		JOY_BUTTON_A:
			return _get_image(JOYPAD, model + "A")
		JOY_BUTTON_B:
			return _get_image(JOYPAD, model + "B")
		JOY_BUTTON_X:
			return _get_image(JOYPAD, model + "X")
		JOY_BUTTON_Y:
			return _get_image(JOYPAD, model + "Y")
		JOY_BUTTON_LEFT_SHOULDER:
			return _get_image(JOYPAD, model + "LB")
		JOY_BUTTON_RIGHT_SHOULDER:
			return _get_image(JOYPAD, model + "RB")
		JOY_BUTTON_LEFT_STICK:
			return _get_image(JOYPAD, model + "L")
		JOY_BUTTON_RIGHT_STICK:
			return _get_image(JOYPAD, model + "R")
		JOY_BUTTON_BACK:
			return _get_image(JOYPAD, model + "Select")
		JOY_BUTTON_START:
			return _get_image(JOYPAD, model + "Start")
		JOY_BUTTON_DPAD_UP:
			return _get_image(JOYPAD, model + "DPadUp")
		JOY_BUTTON_DPAD_DOWN:
			return _get_image(JOYPAD, model + "DPadDown")
		JOY_BUTTON_DPAD_LEFT:
			return _get_image(JOYPAD, model + "DPadLeft")
		JOY_BUTTON_DPAD_RIGHT:
			return _get_image(JOYPAD, model + "DPadRight")
		JOY_BUTTON_MISC1:
			return _get_image(JOYPAD, model + "Share")
	return null

static func _get_joypad_axis(axis: int, value: float, device: int, joypad_model: JoypadModel = JoypadModel.AUTO) -> Texture2D:
	var model := _get_joypad_model(device, joypad_model) + "/"
	
	match axis:
		JOY_AXIS_LEFT_X:
			if value < 0:
				return _get_image(JOYPAD, model + "LeftStickLeft")
			elif value > 0:
				return _get_image(JOYPAD, model + "LeftStickRight")
			else:
				return _get_image(JOYPAD, model + "LeftStick")
		JOY_AXIS_LEFT_Y:
			if value < 0:
				return _get_image(JOYPAD, model + "LeftStickUp")
			elif value > 0:
				return _get_image(JOYPAD, model + "LeftStickDown")
			else:
				return _get_image(JOYPAD, model + "LeftStick")
		JOY_AXIS_RIGHT_X:
			if value < 0:
				return _get_image(JOYPAD, model + "RightStickLeft")
			elif value > 0:
				return _get_image(JOYPAD, model + "RightStickRight")
			else:
				return _get_image(JOYPAD, model + "RightStick")
		JOY_AXIS_RIGHT_Y:
			if value < 0:
				return _get_image(JOYPAD, model + "RightStickUp")
			elif value > 0:
				return _get_image(JOYPAD, model + "RightStickDown")
			else:
				return _get_image(JOYPAD, model + "RightStick")
		JOY_AXIS_TRIGGER_LEFT:
			return _get_image(JOYPAD, model + "LT")
		JOY_AXIS_TRIGGER_RIGHT:
			return _get_image(JOYPAD, model + "RT")
	return null

static func _get_mouse(button: int) -> Texture2D:
	match button:
		MOUSE_BUTTON_LEFT:
			return _get_image(MOUSE, "Left")
		MOUSE_BUTTON_RIGHT:
			return _get_image(MOUSE, "Right")
		MOUSE_BUTTON_MIDDLE:
			return _get_image(MOUSE, "Middle")
		MOUSE_BUTTON_WHEEL_DOWN:
			return _get_image(MOUSE, "WheelDown")
		MOUSE_BUTTON_WHEEL_LEFT:
			return _get_image(MOUSE, "WheelLeft")
		MOUSE_BUTTON_WHEEL_RIGHT:
			return _get_image(MOUSE, "WheelRight")
		MOUSE_BUTTON_WHEEL_UP:
			return _get_image(MOUSE, "WheelUp")
	return null

static func _get_image(type: int, image: String) -> Texture2D:
	match type:
		KEYBOARD:
			return load(_base_path.path_join("Keyboard").path_join(image) + ".png") as Texture
		MOUSE:
			return load(_base_path.path_join("Mouse").path_join(image) + ".png") as Texture
		JOYPAD:
			return load(_base_path.path_join("Joypad").path_join(image) + ".png") as Texture
	return null

func _on_joy_connection_changed(device: int, connected: bool):
	if connected:
		_cached_model = ""
		refresh()

func _input(event: InputEvent) -> void:
	var _prev_use := _use_joypad
	if _use_joypad and (event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion):
		_use_joypad = false
	elif not _use_joypad and (event is InputEventJoypadButton or (event is InputEventJoypadMotion and absf(event.axis_value) > 0.5)):
		_use_joypad = true
	
	if _use_joypad != _prev_use:
		refresh_all()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_ENTER_TREE:
			if get_tree().get_first_node_in_group(GROUP_NAME) == self:
				_queue_update_process_input()
			else:
				set_process_input(false)
		
		NOTIFICATION_EXIT_TREE:
			if is_processing_input():
				_queue_update_process_input()
		
		NOTIFICATION_READY:
			if not _fit_initialized:
				fit_mode = fit_mode
			
			if joypad_model == JoypadModel.AUTO:
				Input.joy_connection_changed.connect(_on_joy_connection_changed)
			
			set_process_input(false)
			
			if action_name == &"":
				return
		
			if not Engine.is_editor_hint():
				assert(InputMap.has_action(action_name) or action_name in CUSTOM_ACTIONS, str("Action \"", action_name, "\" does not exist in the InputMap nor CUSTOM_ACTIONS."))
			
		NOTIFICATION_VISIBILITY_CHANGED:
			if is_visible_in_tree() and _pending_refresh:
				_refresh()

func _validate_property(property: Dictionary) -> void:
	if property.name == "texture":
		property.usage = 0
	elif fit_mode != FitMode.CUSTOM and (property.name == "expand_mode" or property.name == "stretch_mode"):
		property.usage = 0

func _queue_update_process_input():
	Engine.get_main_loop().call_group_flags(SceneTree.GROUP_CALL_DEFERRED | SceneTree.GROUP_CALL_UNIQUE, GROUP_NAME, _update_process_input.get_method())

func _update_process_input():
	if not is_inside_tree():
		return
	set_process_input(get_tree().get_first_node_in_group(GROUP_NAME) == self)

static func _action_get_events(action_name: StringName) -> Array[InputEvent]:
	if Engine.is_editor_hint():
		var setting := "input/" + action_name
		var ret: Array[InputEvent]
		if not ProjectSettings.has_setting(setting):
			return ret
		
		ret.assign(ProjectSettings.get(setting)["events"])
		return ret
	else:
		return InputMap.action_get_events(action_name)
