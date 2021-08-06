extends "res://objects/board/BoardObject.gd"

class_name PressurePlate

const SPRITE_COLOURBLIND = preload("res://sprites/colourblind/pressure_plate.png")
const SPRITE = preload("res://sprites/pressure_plate.png")
const SPRITE_CLASSIC = preload("res://sprites/old_pressure_plate.png")
const SPRITE_CLASSIC_COLOURBLIND = preload("res://sprites/colourblind/old_pressure_plate.png")

onready var sprite : Sprite = $Sprite
onready var tween : Tween = $Tween

var door_type : int # Which type of door this plate will open
var toggled : bool

var state_stack : Array

func is_stepped_on() -> bool:
	for character in get_tree().get_nodes_in_group("character"):
		if character.board_position == board_position:
			return true
	return false

func can_act() -> bool:
	return toggled != is_stepped_on()

func act() -> void:
	if toggled != is_stepped_on():
		toggled = is_stepped_on()
		for door in get_tree().get_nodes_in_group("door"):
			door.toggle_if_type(door_type)
		if toggled:
			tween.interpolate_property(sprite, "offset", Vector2(0, 1), Vector2.ZERO, 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
			tween.start()

func refresh_on_board() -> void:
	position = board_position * TILE_SIZE
	sprite.frame = door_type

func save_state() -> void:
	state_stack.push_back(toggled)

func revert_to_previous_state() -> void:
	if state_stack.size() > 1:
		state_stack.pop_back()
	toggled = state_stack.back()
	refresh_on_board()

func _ready() -> void:
	if Settings.classic_mode and Settings.colour_blind_assist == Settings.COLOUR_BLIND_ASSIST.PALETTE:
		sprite.texture = SPRITE_CLASSIC_COLOURBLIND
	elif Settings.colour_blind_assist == Settings.COLOUR_BLIND_ASSIST.PALETTE:
		sprite.texture = SPRITE_COLOURBLIND
	elif Settings.classic_mode:
		sprite.texture = SPRITE_CLASSIC

func to_json() -> Dictionary:
	return {
		"type": "pressure_plate",
		"board_position": [board_position.x, board_position.y],
		"door_type": door_type
	}
