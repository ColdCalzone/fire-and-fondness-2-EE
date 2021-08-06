extends "res://objects/board/BoardObject.gd"

class_name Teleporter

const SPRITE_COLOURBLIND = preload("res://sprites/colourblind/teleporter.png")
const SPRITE_CLASSIC = preload("res://sprites/old_teleporter.png")
const SPRITE_CLASSIC_COLOURBLIND = preload("res://sprites/colourblind/old_teleporter.png")

const ANIM_SPEED : float = 10.0
const EFFECT_ANIM_SPEED : float = 15.0

onready var sprite : Sprite = $Sprite
onready var effect : Sprite = $Effect

var teleporter_type : int = 0
var anim_index : float = 0.0
var effect_anim_index : float = 0.0
var doing_effect : bool = false

func do_effect() -> void:
	doing_effect = true
	effect_anim_index = 0.0
	effect.show()

func can_act() -> bool:
	for character in get_tree().get_nodes_in_group("character"):
		if character.board_position == board_position:
			return true
	return false

func act() -> void:
	for character in get_tree().get_nodes_in_group("character"):
		if character.board_position == board_position:
			# Find the teleporter target with this color
			var destination = board.teleport_controller.get_teleporter_target(teleporter_type)
			# Make sure the destination exists and isn't blocked
			if destination != null and board.is_space_free(destination.board_position):
				do_effect()
				destination.do_effect()
				SoundMaster.play_sound("teleport")
				yield(get_tree().create_timer(0.3), "timeout")
				character.board_position = destination.board_position
				if character is Inlaw or character is Dog or character is Cat:
					character.try_to_catch_player()
				if character is Player:
					for player in get_tree().get_nodes_in_group("player"):
						player.can_move = false
				character.refresh_on_board()
	#for target in get_tree().get_nodes_in_group("move_target"):
	#	target.queue_free()
	#for character in get_tree().get_nodes_in_group("character"):
	#	character.refresh_on_board()

func _process(delta : float) -> void:
	anim_index += delta * ANIM_SPEED
	refresh_on_board()
	# Vwoorp!
	if doing_effect:
		effect_anim_index += delta * EFFECT_ANIM_SPEED
		if effect_anim_index > 20.0:
			doing_effect = false
			effect.hide()
		else:
			effect.frame = int(effect_anim_index)

func refresh_on_board() -> void:
	position = board_position * TILE_SIZE
	sprite.frame = fmod(anim_index, 6.0) + (int(teleporter_type) * 6)

func _ready() -> void:
	if Settings.colour_blind_assist == Settings.COLOUR_BLIND_ASSIST.PALETTE and Settings.classic_mode:
		sprite.texture = SPRITE_CLASSIC_COLOURBLIND
	elif Settings.colour_blind_assist == Settings.COLOUR_BLIND_ASSIST.PALETTE:
		sprite.texture = SPRITE_COLOURBLIND
	elif Settings.classic_mode:
		sprite.texture = SPRITE_CLASSIC

func to_json() -> Dictionary:
	return {
		"type": "teleporter",
		"board_position": [board_position.x, board_position.y],
		"teleporter_type": teleporter_type
	}

