extends "res://objects/board/BoardObject.gd"
class_name Flower

const SPRITE_FLOWERS = preload("res://sprites/Flowers.png")
const SPRITE_ASH = preload("res://sprites/ash.png")

onready var sprite : Sprite = $Sprite

var collected : bool = false
var burned : bool = false
var index : int = 0

var state_stack : Array

func is_flammable() -> bool:
	return not burned and not collected

func burn() -> void:
	burned = true
	refresh_on_board()

func collect() -> void:
	SoundMaster.play_sound("flower_pickup")
	collected = true
	refresh_on_board()
	return

func refresh_on_board() -> void:
	position = board_position * TILE_SIZE
	# this will allow creation multiple DIFFERENT flowers
	sprite.region_rect.position.x = (16 * index) + (64 if Settings.classic_mode else 0)
	if burned:
		sprite.texture = SPRITE_ASH
	else:
		sprite.texture = SPRITE_FLOWERS
	if collected:
		sprite.hide()
	else:
		sprite.show()

func save_state() -> void:
	state_stack.push_back([burned, collected])

func revert_to_previous_state() -> void:
	var flower_collected = state_stack.back()[1]
	if state_stack.size() > 1:
		state_stack.pop_back()
	burned = state_stack.back()[0]
	collected = state_stack.back()[1]
	# raises the pitch for that ＪＵＩＣＩＮＥＳＳ
	if collected == false and flower_collected == true:
		SoundMaster.audio_flower_pickup.pitch_scale -= 0.125
	refresh_on_board()

func to_json() -> Dictionary:
	return {
		"type": "flower",
		"board_position": [board_position.x, board_position.y],
		"index": index
	}

