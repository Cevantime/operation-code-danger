class_name GordonData extends Resource

enum NAME {
	BEAUVOIR,
	BERNARD
}


const CODE_NAMES = ["beauvoir", "bernard"]

@export var name = null:
	set(v):
		if v == name:
			return
		name = v
		packed_scene = get_packed_from_code_name(code_name)
		other_gordon_packed_scene = get_packed_from_code_name(CODE_NAMES[NAME.BERNARD] if name == NAME.BEAUVOIR else CODE_NAMES[NAME.BEAUVOIR])
			
		emit_changed()
		
var packed_scene: PackedScene

var other_gordon_packed_scene: PackedScene

var code_name :
	get: 
		return CODE_NAMES[name]
		
func get_packed_from_code_name(c_name):
	return load("res://gordon_%s.tscn" % c_name)
		
	
