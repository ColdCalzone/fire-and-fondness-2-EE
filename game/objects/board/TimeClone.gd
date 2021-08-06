extends "res://objects/board/Character.gd"
class_name TimeClone

const SPRITE_CHARACTERS = preload("res://sprites/characters.png")
const SPRITE_ASH = preload("res://sprites/ash.png")

const ANIM_SPEED : float = 20.0

onready var sprite : Sprite = $Sprite
onready var tween : Tween = $Tween
onready var overlay : Sprite = $timeclones

var anim_index : float = 0.0

var flipped : bool

var duplicated : bool

var state_stack : Array

func is_blocker(is_player : bool = false) -> bool:
	return is_player

func refresh_on_board() -> void:
	if state == STATE.NON_EXISTANT: queue_free()
	overlay.frame = fmod(anim_index, 20.0)
	position = board_position * TILE_SIZE
	sprite.region_rect.position.x = Settings.player_avatar * 16
	sprite.flip_h = flipped
	if state == STATE.BURNED:
		sprite.texture = SPRITE_ASH
	else:
		sprite.texture = SPRITE_CHARACTERS

func save_state() -> void:
	state_stack.push_back(
		[board_position, state, flipped]
	)

func revert_to_previous_state() -> void:
	if state_stack.size() > 1:
		state_stack.pop_back()
	board_position = state_stack.back()[0]
	state = state_stack.back()[1]
	flipped = state_stack.back()[2]
	refresh_on_board()

func _process(delta: float) -> void:
	anim_index += delta * ANIM_SPEED
	refresh_on_board()

func to_json() -> Dictionary:
	return {
		"type": "time_clone",
		"board_position": [board_position.x, board_position.y],
		"flipped": flipped
	}

