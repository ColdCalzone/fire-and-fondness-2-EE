extends "res://objects/board/BoardObject.gd"

class_name Character

enum STATE {NORMAL, BURNED, CRUSHED, FALLEN, DOGGED, CATTED, INLAWED, NON_EXISTANT}

onready var state : int = STATE.NORMAL

func is_character() -> bool:
	return true

func is_fake_partner() -> bool:
	return false

func is_alive() -> bool:
	return state == STATE.NORMAL

func is_blocker(is_player : bool = false) -> bool:
	return false

func is_flammable() -> bool:
	return is_alive()

func can_fall() -> bool:
	return is_alive()

func can_be_crushed() -> bool:
	return is_alive()

func burn() -> void:
	pass

func fall() -> void:
	pass

func crush() -> void:
	pass

func caught_by_dog() -> void:
	pass

func caught_by_inlaw() -> void:
	pass
