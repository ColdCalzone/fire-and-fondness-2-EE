extends "res://objects/board/BoardObject.gd"

class_name Hourglass

const SPRITE_COLOURBLIND = preload("res://sprites/colourblind/hourglass_colours.png")
const SPRITE_COLOURS = preload("res://sprites/hourglass_colours.png")
const SPRITE_COLOURS_CLASSIC = preload("res://sprites/old_hourglass_colours.png")
const SPRITE_CLASSIC_COLOURBLIND = preload("res://sprites/colourblind/old_hourglass_colours.png")
const SPRITE = preload("res://sprites/hourglass.png")
const SPRITE_CLASSIC = preload("res://sprites/old_hourglass.png")

onready var sprite = $Sprite
onready var sprite_colours = $Sprite_Colours
onready var tween = $Tween

var door_type : int # Which type of door this switch will open
var toggled : bool
var time_until_flip : int = 4
var time_between_flips : int = 4

var state_stack : Array

func is_interactive() -> bool:
	return not toggled

func activate() -> void:
	if not toggled:
		SoundMaster.play_sound("switch_pull")
		toggled = true
		refresh_on_board()
		# Make it bounce!
		tween.interpolate_property(sprite, "scale", Vector2(1.0, 0.75), Vector2(1.0, 1.0), 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.interpolate_property(sprite_colours, "scale", Vector2(1.0, 0.75), Vector2(1.0, 1.0), 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.start()
		for door in get_tree().get_nodes_in_group("door"):
			door.toggle_if_type(door_type)
		time_until_flip = time_between_flips + 1 # For the first tick thing
		refresh_on_board()

func tick() -> void:
	if toggled:
		time_until_flip -= 1
	refresh_on_board()

func can_act() -> bool:
	return toggled and time_until_flip <= 0

func act() -> void:
	if time_until_flip <= 0:
		toggled = false
		time_until_flip = 0
		for door in get_tree().get_nodes_in_group("door"):
			door.toggle_if_type(door_type)
	refresh_on_board()

func refresh_on_board() -> void:
	position = board_position * TILE_SIZE
	sprite.frame = min(time_until_flip, sprite.hframes - 1)
	sprite_colours.frame = door_type

func save_state() -> void:
	state_stack.push_back([toggled, time_until_flip])

func revert_to_previous_state() -> void:
	if state_stack.size() > 1:
		state_stack.pop_back()
	toggled = state_stack.back()[0]
	time_until_flip = state_stack.back()[1]
	refresh_on_board()

func _ready() -> void:
	if Settings.classic_mode:
		sprite.texture = SPRITE_CLASSIC
		if Settings.colour_blind_assist == Settings.COLOUR_BLIND_ASSIST.PALETTE:
			sprite_colours.texture = SPRITE_CLASSIC_COLOURBLIND
		else:
			sprite_colours.texture = SPRITE_COLOURS_CLASSIC
	else:
		sprite.texture = SPRITE
		if Settings.colour_blind_assist == Settings.COLOUR_BLIND_ASSIST.PALETTE:
			sprite_colours.texture = SPRITE_COLOURBLIND
		else:
			sprite_colours.texture = SPRITE_COLOURS

func to_json() -> Dictionary:
	return {
		"type": "hourglass",
		"board_position": [board_position.x, board_position.y],
		"door_type": door_type,
		"toggled": toggled,
		"time_until_flip": time_until_flip,
		"time_between_flips": time_between_flips
	}
