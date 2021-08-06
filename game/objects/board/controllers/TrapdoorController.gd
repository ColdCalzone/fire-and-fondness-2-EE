extends Node

func tick() -> void:
	for trapdoor in get_tree().get_nodes_in_group("trapdoor"):
		trapdoor.tick()

func can_act() -> bool:
	for trapdoor in get_tree().get_nodes_in_group("trapdoor"):
		if trapdoor.can_act():
			return true
	return false

func act() -> void:
	for trapdoor in get_tree().get_nodes_in_group("trapdoor"):
		if trapdoor.can_act():
			trapdoor.act()
