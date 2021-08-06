extends Node

func can_act() -> bool:
	for pressure_plate in get_tree().get_nodes_in_group("pressure_plate"):
		if pressure_plate.can_act():
			return true
	return false

func act() -> void:
	for pressure_plate in get_tree().get_nodes_in_group("pressure_plate"):
		if pressure_plate.can_act():
			pressure_plate.act()
