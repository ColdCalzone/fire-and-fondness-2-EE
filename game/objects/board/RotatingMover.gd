extends "res://objects/board/BoardObject.gd"

class_name RotatingMover

const ANIM_SPEED : float = 5.0
const SPRITE_ARROW = preload("res://sprites/rotating_mover_arrow.png")
const SPRITE_CIRCLE = preload("res://sprites/rotating_mover_circle.png")
const OLD_SPRITE_ARROW = preload("res://sprites/old_rotating_mover_arrow.png")
const OLD_SPRITE_CIRCLE = preload("res://sprites/old_rotating_mover_circle.png")

onready var sprite_circle : Sprite = $Sprite_Circle
onready var sprite_arrow : Sprite = $Sprite_Arrow

const DIRECTIONS = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]

var direction_index : int = 0
var turning_direction : int = 1
var anim_index : float = 0.0

# When the way is blocked, but there is someone to move, we do a "shunt".
# But we only want to do it once, hence this flag.
var done_false_shunt : bool = false

var state_stack : Array

func get_direction() -> Vector2:
	return DIRECTIONS[direction_index]

func refresh_on_board() -> void:
	position = board_position * TILE_SIZE
	var arrow_flashing : int = int(fmod(anim_index, 1.0))
	var circle_start : int = 0 if turning_direction == 1 else 4
	sprite_arrow.frame = (direction_index * 2) + arrow_flashing
	sprite_circle.frame = circle_start + fmod(anim_index, 4.0)
	if Settings.classic_mode:
		sprite_arrow.texture = OLD_SPRITE_ARROW
		sprite_circle.texture = OLD_SPRITE_CIRCLE
	else:
		sprite_arrow.texture = SPRITE_ARROW
		sprite_circle.texture = SPRITE_CIRCLE

func can_act() -> bool:
	for character in get_tree().get_nodes_in_group("character"):
		if character.board_position == board_position:
			var candidate_position = character.board_position + get_direction()
			if board.is_space_free(candidate_position, character.is_in_group("player")) and not done_false_shunt:
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

func rotate_mover() -> void:
	direction_index += turning_direction
	if direction_index >= 4:
		direction_index -= 4
	if direction_index < 0:
		direction_index += 4
	refresh_on_board()

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
			else:
				done_false_shunt = true
			#yield(get_tree().create_timer(0.1), "timeout")
			rotate_mover()

func _process(delta : float) -> void:
	anim_index += delta * ANIM_SPEED
	refresh_on_board()

func save_state() -> void:
	state_stack.push_back([direction_index, turning_direction])

func revert_to_previous_state() -> void:
	if state_stack.size() > 1:
		state_stack.pop_back()
	direction_index = state_stack.back()[0]
	turning_direction = state_stack.back()[1]
	refresh_on_board()

func to_json() -> Dictionary:
	return {
		"type": "rotating_mover",
		"board_position": [board_position.x, board_position.y],
		"direction_index": direction_index,
		"turning_direction": turning_direction
	}
