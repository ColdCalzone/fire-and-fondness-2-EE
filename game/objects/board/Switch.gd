extends "res://objects/board/BoardObject.gd"

class_name Switch

const SPRITE_COLOURBLIND = preload("res://sprites/colourblind/switch.png")
const SPRITE_CLASSIC = preload("res://sprites/old_switch.png")
const SPRITE_CLASSIC_COLOURBLIND = preload("res://sprites/colourblind/old_switch.png")

onready var sprite = $Sprite
onready var tween = $Tween

var door_type : int # Which type of door this switch will open
var toggled : bool

var state_stack : Array

func is_interactive() -> bool:
	return true

func activate() -> void:
	SoundMaster.play_sound("switch_pull")
	toggled = !toggled
	refresh_on_board()
	# Make it bounce!
	tween.interpolate_property(sprite, "scale", Vector2(1.0, 0.75), Vector2(1.0, 1.0), 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	for door in get_tree().get_nodes_in_group("door"):
		door.toggle_if_type(door_type)

func refresh_on_board() -> void:
	position = board_position * TILE_SIZE
	sprite.frame = door_type + (int(toggled) * 4)

func save_state() -> void:
	state_stack.push_back(toggled)

func revert_to_previous_state() -> void:
	if state_stack.size() > 1:
		state_stack.pop_back()
	toggled = state_stack.back()
	refresh_on_board()

func _ready() -> void:
	if Settings.colour_blind_assist == Settings.COLOUR_BLIND_ASSIST.PALETTE and Settings.classic_mode:
		sprite.texture = SPRITE_CLASSIC_COLOURBLIND
	elif Settings.classic_mode:
		sprite.texture = SPRITE_CLASSIC
	elif Settings.colour_blind_assist == Settings.COLOUR_BLIND_ASSIST.PALETTE:
		sprite.texture = SPRITE_COLOURBLIND

func to_json() -> Dictionary:
	return {
		"type": "switch",
		"board_position": [board_position.x, board_position.y],
		"door_type": door_type,
		"toggled": toggled
	}

