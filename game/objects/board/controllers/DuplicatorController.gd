extends Node

func get_duplicator_target(teleporter_type : int) -> Node2D:
	for current_object in get_tree().get_nodes_in_group("teleporter_target"):
		if current_object.teleporter_type == teleporter_type:
			return current_object
	return null

func can_act() -> bool:
	for current_object in get_tree().get_nodes_in_group("duplicator"):
		if current_object.can_act():
			return true
	return false

func act() -> void:
	for current_object in get_tree().get_nodes_in_group("duplicator"):
		current_object.act()	
