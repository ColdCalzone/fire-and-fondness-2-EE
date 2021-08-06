extends "res://objects/board/Character.gd"

class_name Inlaw

const SPRITE_ASH = preload("res://sprites/ash.png")
const SPRITE = preload("res://sprites/inlaw.png")
const OLD_SPRITE = preload("res://sprites/old_inlaw.png")

onready var sprite : Sprite = $Sprite
onready var tween : Tween = $Tween

var PREFERRED_DIRECTIONS : Dictionary = {
	Vector2.UP: [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP],
	Vector2.DOWN: [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN],
	Vector2.LEFT: [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT],
	Vector2.RIGHT: [Vector2.DOWN, Vector2.UP, Vector2.LEFT, Vector2.RIGHT]
}

const FOUR_DIRECTIONS : Array = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

var moving_direction : Vector2 = Vector2.RIGHT

var duplicated : bool = false

var state_stack : Array

func burn() -> void:
	sprite.region_enabled = false
	sprite.texture = SPRITE_ASH
	state = STATE.BURNED
	SoundMaster.fade_out_music()

func crush() -> void:
	SoundMaster.play_sound("squish")
	sprite.hide()
	state = STATE.CRUSHED
	SoundMaster.fade_out_music()

func fall() -> void:
	SoundMaster.play_sound("fall")
	sprite.hide()
	state = STATE.FALLEN
	SoundMaster.fade_out_music()

func wiggle(direction : Vector2) -> void:
	var start_offset : Vector2 = Vector2(0, -8) + (direction * 2)
	sprite.offset = start_offset
	tween.interpolate_property(sprite, "offset", start_offset, Vector2(0, -8), 0.2, Tween.TRANS_SINE)
	var scale_start : Vector2 = Vector2.ONE
	match direction:
		Vector2.UP:
			scale_start = Vector2(1.0, 1.25)
		Vector2.DOWN:
			scale_start = Vector2(1.0, 0.75)
		_:
			scale_start = Vector2(1.25, 1.0)
	sprite.scale = scale_start
	tween.interpolate_property(sprite, "scale", scale_start, Vector2(1.0, 1.0), 0.35, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()

func can_act() -> bool:
	for offset in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		if get_parent().is_space_free(board_position + offset):
			return true
	return false

func can_move_to(position : Vector2) -> bool:
	if not get_parent().is_space_free(position):
		return false
	return true

func choose_new_direction() -> void:
	var directions : Array = PREFERRED_DIRECTIONS[moving_direction]
	for direction in directions:
		var candidate : Vector2 = board_position + direction
		if can_move_to(candidate):
			moving_direction = direction
			# While we're here, flip the sprite if need be
			if moving_direction == Vector2.LEFT:
				sprite.flip_h = true
			if moving_direction == Vector2.RIGHT:
				sprite.flip_h = false
				
			return

func try_to_catch_player() -> void:
	for player in get_tree().get_nodes_in_group("player"):
		if board_position == player.board_position:
			player.caught_by_inlaw()

func act() -> void:
	var candidate : Vector2 = board_position + moving_direction
	# Change direction if needed/able
	if not can_move_to(candidate):
		choose_new_direction()
	# Move if able
	candidate = board_position + moving_direction
	if can_move_to(candidate):
		SoundMaster.play_sound("player_step")
		board_position = candidate
		wiggle(moving_direction * -1)
		refresh_on_board()
	# Did we just catch the player?
	try_to_catch_player()

func refresh_on_board() -> void:
	if state == STATE.NON_EXISTANT: queue_free()
	position = board_position * TILE_SIZE
	if Settings.classic_mode:
		sprite.texture = OLD_SPRITE
	else:
		sprite.texture = SPRITE

func save_state() -> void:
	state_stack.push_back([board_position, moving_direction, state])

func revert_to_previous_state() -> void:
	if state_stack.size() > 1:
		state_stack.pop_back()
	board_position = state_stack.back()[0]
	moving_direction = state_stack.back()[1]
	state = state_stack.back()[2]
	refresh_on_board()

func to_json() -> Dictionary:
	return {
		"type": "inlaw",
		"board_position": [board_position.x, board_position.y]
	}
