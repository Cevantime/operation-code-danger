extends Node

const COMPONENTS_META = &"components_meta"

func _enter_tree():
	get_tree().node_added.connect(Callable(self, "_on_node_added"))
	
func _on_node_added(n: Node):
	var parent = n.get_parent()
	if 'component_id' in n and parent != null:
		var component_id = n.component_id
		n.add_to_group(_get_component_group(component_id))
		if not parent.has_meta(COMPONENTS_META):
			parent.set_meta(COMPONENTS_META, Dictionary())
		var map = parent.get_meta(COMPONENTS_META)
		map[component_id] = n

func _get_component_group(id):
	return "component_" + str(id)
	
func has_entity_component(entity, id: Components.IDS):
	if entity.has_meta(COMPONENTS_META):
		return entity.get_meta(COMPONENTS_META).has(id)
	else:
		for c in entity.get_children():
			if 'component_id' in c and c.component_id == id:
				return true
		return false
	
func get_entity_component(entity, id: Components.IDS):
	if entity.has_meta(COMPONENTS_META):
		var dict = entity.get_meta(COMPONENTS_META)
		if dict.has(id):
			return dict[id]
		else : return null
	else:
		for c in entity.get_children():
			if 'component_id' in c and c.component_id == id:
				return c
		return null

func get_components(id: Components.IDS):
	return get_tree().get_nodes_in_group(_get_component_group(id))
