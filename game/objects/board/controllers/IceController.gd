extends Node

func can_act() -> bool:
	for ice in get_tree().get_nodes_in_group("ice"):
		if ice.hit_by_fire:
			return true
	return false

func act() -> void:
	for ice in get_tree().get_nodes_in_group("ice"):
		ice.melt_if_hit()
