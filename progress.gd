extends Node

const CONFIG_FILE = "user://config.cfg"
const PROGRESS_SECTION = "progress"

var __config: ConfigFile
var prefix = ""

# whether the introduction dialogue has been played one time
const INTRO_DONE = "intro_done"
const COMMANDS_DONE = "commands_done"
const FIRST_SPECTATOR_MET = "first_spectator_met"
const NICE_WALK_DONE = "nice_walk_done"
const FIRST_WAVE_DONE = "first_wave_done"
const FIRST_WAVE_SUCCESS = "first_wave_success"
const SECOND_WAVE_DONE = "second_wave_done"
const SECOND_WAVE_SUCCESS = "second_wave_success"
const OPHELIE_MET = "ophelie_met"
const QUESTION_GORDON = "question_gordon"
const POSTER_DONE = "poster_done"
const SALUTE_DONE = "salute_done"

# Called when the node enters the scene tree for the first time.
func _ready():
	__config = __get_config()
		
	
func __get_config():
	var config = ConfigFile.new()
	config.load(CONFIG_FILE)
	return config
	
	
func __save():
	__config.save(CONFIG_FILE)
	
func read_raw(key: String):
	return __config.get_value(PROGRESS_SECTION, key, false)
	
func read(key: String):
	return __config.get_value(PROGRESS_SECTION, prefix + "." + key, false)

func write(key: String, value: Variant):
	__config.set_value(PROGRESS_SECTION, prefix + "." + key, value)
	__save()

func reset():
	__config.erase_section(PROGRESS_SECTION)
	__config.save(CONFIG_FILE)
