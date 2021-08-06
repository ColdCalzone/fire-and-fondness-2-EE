extends "res://objects/board/BoardObject.gd"

class_name Partner

const SPRITE_ASH = preload("res://sprites/ash.png")

onready var sprite : Sprite = $Sprite

var burned : bool = false
var flipped : bool

func is_flammable() -> bool:
	return not burned

func burn() -> void:
	sprite.region_enabled = false
	sprite.texture = SPRITE_ASH
	burned = true
	SoundMaster.fade_out_music()

func refresh_on_board() -> void:
	position = board_position * TILE_SIZE
	sprite.region_rect.position.x = Settings.partner_avatar * 16
	sprite.flip_h = flipped

func to_json() -> Dictionary:
	return {
		"type": "partner",
		"board_position": [board_position.x, board_position.y],
		"flipped": flipped
	}
