extends Node

func can_act() -> bool:
	for inlaw in get_tree().get_nodes_in_group("inlaw"):
		if inlaw.can_act():
			return true
	return false

func act() -> void:
	for inlaw in get_tree().get_nodes_in_group("inlaw"):
		inlaw.act()

func try_to_catch_player() -> void:
	for inlaw in get_tree().get_nodes_in_group("inlaw"):
		inlaw.try_to_catch_player()
