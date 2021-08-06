extends "res://objects/board/BoardObject.gd"

class_name Door

const SPRITE_COLOURBLIND = preload("res://sprites/colourblind/door.png")
const SPRITE_CLASSIC = preload("res://sprites/old_door.png")
const SPRITE_CLASSIC_COLOURBLIND = preload("res://sprites/colourblind/old_door.png")
const OBJ_SMOKE = preload("res://objects/Smoke.tscn")

onready var sprite = $Sprite
onready var tween = $Tween

var door_type : int # What type of switch will open this door
var open : bool

var state_stack : Array

func is_blocker(is_player : bool = false) -> bool:
	return !open

func emit_smoke() -> void:
	for dir in [-1, 1]:
		var smoke : Sprite = OBJ_SMOKE.instance()
		smoke.global_position = sprite.global_position
		# Change which direction the smoke goes depending on which way the door is facing
		if sprite.rotation_degrees == -90:
			smoke.position += Vector2(4, 0) * dir
			smoke.velocity = Vector2(96.0, 0.0) * dir
		else:
			smoke.position += Vector2(0, 4) * dir
			smoke.velocity = Vector2(0.0, 96.0) * dir
		get_parent().add_child(smoke)

func toggle() -> void:
	if open:
		SoundMaster.play_sound("door_close")
		# Is someone squishy enough in the way?
		for character in get_tree().get_nodes_in_group("character"):
			if character.board_position == board_position and character.can_be_crushed():
				character.crush()
				emit_smoke()
	else:
		SoundMaster.play_sound("door_open")
	open = !open
	refresh_on_board()
	# Make 'em wiggle!
	tween.interpolate_property(sprite, "scale", Vector2(1.0, 0.75), Vector2(1.0, 1.0), 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()

func toggle_if_type(door_type : int) -> void:
	if self.door_type == door_type:
		toggle()

func set_board(board) -> void:
	.set_board(board)
	if board.is_wall_at(board_position + Vector2.LEFT) or board.is_wall_at(board_position + Vector2.RIGHT):
		sprite.rotation_degrees = -90

func refresh_on_board() -> void:
	position = board_position * TILE_SIZE
	sprite.frame = door_type + (int(open) * 16)

func save_state() -> void:
	state_stack.push_back(open)

func revert_to_previous_state() -> void:
	if state_stack.size() > 1:
		state_stack.pop_back()
	open = state_stack.back()
	refresh_on_board()

func _ready() -> void:
	if Settings.colour_blind_assist == Settings.COLOUR_BLIND_ASSIST.PALETTE and Settings.classic_mode:
		sprite.texture = SPRITE_CLASSIC_COLOURBLIND
	elif Settings.colour_blind_assist == Settings.COLOUR_BLIND_ASSIST.PALETTE:
		sprite.texture = SPRITE_COLOURBLIND
	elif Settings.classic_mode:
		sprite.texture = SPRITE_CLASSIC

func to_json() -> Dictionary:
	return {
		"type": "door",
		"board_position": [board_position.x, board_position.y],
		"door_type": door_type,
		"open": open
	}

