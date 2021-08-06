extends Node

func can_act() -> bool:
	for dog in get_tree().get_nodes_in_group("dog"):
		if dog.can_act():
			return true
	return false

func act() -> void:
	for dog in get_tree().get_nodes_in_group("dog"):
		dog.act()

func check_for_player_after_move() -> void:
	for dog in get_tree().get_nodes_in_group("dog"):
		dog.check_for_player_after_move()
