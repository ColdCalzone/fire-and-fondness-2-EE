extends "res://objects/board/BoardObject.gd"

class_name Duplicator

const SPRITE_COLOURBLIND = preload("res://sprites/colourblind/duplicator.png")
const SPRITE_CLASSIC = preload("res://sprites/old_duplicator.png")
const SPRITE_CLASSIC_COLOURBLIND = preload("res://sprites/colourblind/old_duplicator.png")

const PLAYERS = preload("res://objects/board/Player.tscn")
const INLAWS = preload("res://objects/board/Inlaw.tscn")
const DOGS = preload("res://objects/board/Dog.tscn")
const CATS = preload("res://objects/board/Cat.tscn")

const ANIM_SPEED : float = 10.0
const EFFECT_ANIM_SPEED : float = 15.0

onready var sprite : Sprite = $Sprite
onready var effect : Sprite = $Effect

var teleporter_type : int = 0
var anim_index : float = 0.0
var effect_anim_index : float = 0.0
var doing_effect : bool = false 
var already_acted : bool = false

func do_effect() -> void:
	doing_effect = true
	effect_anim_index = 0.0
	effect.show()

func can_act() -> bool:
	for character in get_tree().get_nodes_in_group("character"):
		if character.board_position == board_position and !already_acted:
			already_acted=true
			return true
	return false

func act() -> void:
	for character in get_tree().get_nodes_in_group("character"):
		if character.board_position == board_position and not character.duplicated:
			# Find the duplicator target with this color
			var destination = board.duplicator_controller.get_duplicator_target(teleporter_type)
			# Make sure the destination exists and isn't blocked
			if destination != null and board.is_space_free(destination.board_position):
				do_effect()
				destination.do_effect()
				SoundMaster.play_sound("teleport")
				yield(get_tree().create_timer(0.3), "timeout")
				if character is Inlaw:
					var new_thing = INLAWS.instance()
					get_parent().add_child(new_thing)
					new_thing.board_position = destination.board_position
					new_thing.refresh_on_board()
					new_thing.state = new_thing.STATE.NON_EXISTANT
					new_thing.save_state()
					new_thing.state = new_thing.STATE.NORMAL
				if character is Dog:
					var new_thing = DOGS.instance()
					get_parent().add_child(new_thing)
					new_thing.board_position = destination.board_position
					new_thing.refresh_on_board()
					new_thing.behaviour_state = new_thing.BEHAVIOUR_STATE.NON_EXISTANT
					new_thing.save_state()
					new_thing.behaviour_state = new_thing.BEHAVIOUR_STATE.IDLE
				if character is Player:
					for player in get_tree().get_nodes_in_group("player"):
						player.can_move = false
					var new_thing = PLAYERS.instance()
					get_parent().add_child(new_thing)
					new_thing.board_position = destination.board_position
					new_thing.fake_partner = character.is_fake_partner()
					new_thing.refresh_on_board()
					new_thing.state = new_thing.STATE.NON_EXISTANT
					new_thing.save_state()
					new_thing.state = new_thing.STATE.NORMAL
					new_thing.connect("player_moved", get_parent(), "player_moved")
				if character is Cat:
					var new_thing = CATS.instance()
					get_parent().add_child(new_thing)
					new_thing.board_position = destination.board_position
					new_thing.refresh_on_board()
					new_thing.behaviour_state = new_thing.BEHAVIOUR_STATE.NON_EXISTANT
					new_thing.save_state()
					new_thing.behaviour_state = new_thing.BEHAVIOUR_STATE.IDLE
				#character.refresh_on_board()
				character.duplicated = true
				if character is Inlaw or character is Dog or character is Cat:
					character.try_to_catch_player()

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
		"type": "duplicator",
		"board_position": [board_position.x, board_position.y],
		"teleporter_type": teleporter_type
	}
