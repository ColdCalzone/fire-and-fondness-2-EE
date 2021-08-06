extends Node

func can_act() -> bool:
	for cat in get_tree().get_nodes_in_group("cat"):
		if cat.can_act():
			return true
	return false

func act() -> void:
	for cat in get_tree().get_nodes_in_group("cat"):
		cat.act()
