extends Node2D

const TILE_SIZE : int = 16

var board_position : Vector2

var board

func is_flammable() -> bool:
	return false

func is_fake_partner() -> bool:
	return false

func is_blocker(is_player : bool = false) -> bool:
	return false

func is_interactive() -> bool:
	return false

func is_character() -> bool:
	return false

func set_board(board) -> void:
	self.board = board

func get_board_position_from_position() -> void:
	board_position = position / TILE_SIZE

func refresh_on_board() -> void:
	position = board_position * TILE_SIZE

func save_state() -> void:
	pass

func revert_to_previous_state() -> void:
	pass

func to_json() -> Dictionary:
	return {
		"type": "unsupported",
		"board_position": board_position
	}
