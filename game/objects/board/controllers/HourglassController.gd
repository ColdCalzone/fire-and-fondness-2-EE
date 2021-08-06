extends Node

func tick() -> void:
	for hourglass in get_tree().get_nodes_in_group("hourglass"):
		hourglass.tick()

func can_act() -> bool:
	for hourglass in get_tree().get_nodes_in_group("hourglass"):
		if hourglass.can_act():
			return true
	return false

func act() -> void:
	for hourglass in get_tree().get_nodes_in_group("hourglass"):
		if hourglass.can_act():
			hourglass.act()
