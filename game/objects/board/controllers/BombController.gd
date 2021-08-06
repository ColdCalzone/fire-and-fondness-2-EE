extends Node

func can_act() -> bool:
	for bomb in get_tree().get_nodes_in_group("bomb"):
		if bomb.is_about_to_explode():
			return true
	return false

func act() -> void:
	SoundMaster.play_sound("bomb_explosion")
	for bomb in get_tree().get_nodes_in_group("bomb"):
		bomb.explode_if_lit()
