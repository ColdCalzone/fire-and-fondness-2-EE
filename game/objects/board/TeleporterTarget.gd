extends "res://objects/board/BoardObject.gd"

class_name TeleporterTarget

const SPRITE_COLOURBLIND = preload("res://sprites/colourblind/teleporter_target.png")
const SPRITE_CLASSIC = preload("res://sprites/old_teleporter_target.png")
const SPRITE_CLASSIC_COLOURBLIND = preload("res://sprites/colourblind/old_teleporter_target.png")
const SPRITE_NORMAL = preload("res://sprites/teleporter_target.png")

const EFFECT_ANIM_SPEED : float = 15.0


onready var sprite : Sprite = $Sprite
onready var effect : Sprite = $Effect

var teleporter_type : int = 0

var effect_anim_index : float = 0.0
var doing_effect : bool = false

func do_effect() -> void:
	doing_effect = true
	effect_anim_index = 0.0
	effect.show()

func _process(delta : float) -> void:
	# Vwoorp!
	refresh_on_board()
	if doing_effect:
		effect_anim_index += delta * EFFECT_ANIM_SPEED
		if effect_anim_index > 20.0:
			doing_effect = false
			effect.hide()
		else:
			effect.frame = int(effect_anim_index)

func refresh_on_board() -> void:
	position = board_position * TILE_SIZE
	sprite.frame = teleporter_type

func _ready() -> void:
	if Settings.colour_blind_assist == Settings.COLOUR_BLIND_ASSIST.PALETTE and Settings.classic_mode:
		sprite.texture = SPRITE_CLASSIC_COLOURBLIND
	elif Settings.colour_blind_assist == Settings.COLOUR_BLIND_ASSIST.PALETTE:
		sprite.texture = SPRITE_COLOURBLIND
	elif Settings.classic_mode:
		sprite.texture = SPRITE_CLASSIC
	else:
		sprite.texture = SPRITE_NORMAL

func to_json() -> Dictionary:
	return {
		"type": "teleporter_target",
		"board_position": [board_position.x, board_position.y],
		"teleporter_type": teleporter_type
	}
