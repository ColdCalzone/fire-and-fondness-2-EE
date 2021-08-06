extends "res://objects/board/BoardObject.gd"

class_name Mover

const ANIM_SPEED : float = 5.0
const OLD_SPRITE = preload("res://sprites/old_mover.png")

onready var sprite : Sprite = $Sprite

const DIRECTIONS = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

var direction_index : int = 3
var anim_index : float = 0.0

# When the way is blocked, but there is someone to move, we do a "shunt".
# But we only want to do it once, hence this flag.
var done_false_shunt : bool = false

func get_direction() -> Vector2:
	return DIRECTIONS[direction_index]

func refresh_on_board() -> void:
	position = board_position * TILE_SIZE
	sprite.frame = fmod(anim_index, 4.0) + (int(direction_index) * 4)

func can_act() -> bool:
	for character in get_tree().get_nodes_in_group("character"):
		if character.board_position == board_position:
			var candidate_position = character.board_position + get_direction()
			if board.is_space_free(candidate_position, character.is_in_group("player")):
				return true
			# Do we want to do a false shunt?
			elif not done_false_shunt:
				return true
	return false

func get_movee():
	for character in get_tree().get_nodes_in_group("character"):
		if character.board_position == board_position:
			return character
	return null

# How much do you want to bet there's never been a function with this name before?
func reset_shunt_status() -> void:
	done_false_shunt = false

func act() -> void:
	for character in get_tree().get_nodes_in_group("character"):
		if character.board_position == board_position:
			var candidate_position = character.board_position + get_direction()
			# Make it look like the mover is moving the player, even if the way is blocked
			SoundMaster.play_sound("mover_move")
			character.wiggle(get_direction())
			# If the path isn't blocked, move the player over there
			if board.is_space_free(candidate_position, character.is_in_group("player")):
				character.board_position = candidate_position
				character.refresh_on_board()
				if character is Player:
					character.check_for_flowers()
				elif character is Inlaw:
					character.moving_direction = get_direction()
					character.try_to_catch_player()
				elif character is Dog:
					character.try_to_catch_player()
				#character.refresh_on_board()
			else:
				done_false_shunt = true

func _process(delta : float) -> void:
	anim_index += delta * ANIM_SPEED
	refresh_on_board()

func _ready() -> void:
	if Settings.classic_mode:
		sprite.texture = OLD_SPRITE

func save_state() -> void:
	# yeet haw
	pass

func to_json() -> Dictionary:
	return {
		"type": "mover",
		"board_position": [board_position.x, board_position.y],
		"direction_index": direction_index
	}
