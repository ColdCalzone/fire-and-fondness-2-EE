extends "res://objects/board/BoardObject.gd"

class_name Ice

onready var sprite : Sprite = $Sprite
onready var tween : Tween = $Tween

var health : int = 3
var hit_by_fire : bool = false # Whether fire touched us last time the flamethrowers spouted
var melted : bool = false

var state_stack : Array

const SPRITE = preload("res://sprites/ice.png")
const OLD_SPRITE = preload("res://sprites/old_ice.png")

func set_hit() -> void:
	SoundMaster.play_sound("ice_hiss")
	hit_by_fire = true

func melt() -> void:
	melted = true
	refresh_on_board()

func melt_if_hit() -> void:
	if hit_by_fire:
		SoundMaster.play_sound("ice_melt")
		if health > 0:
			health -= 1
			hit_by_fire = false
			sprite.scale = Vector2(1.0, 1.2)
			tween.interpolate_property(sprite, "scale", Vector2(1.0, 1.2), Vector2.ONE, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
			tween.start()
			refresh_on_board()
	# Did we just melt?
	if health <= 0 and not melted:
		melt()

func is_blocker(is_player : bool = false) -> bool:
	return not melted

func refresh_on_board() -> void:
	if Settings.classic_mode:
		sprite.texture = OLD_SPRITE
	else:
		sprite.texture = SPRITE
	position = board_position * TILE_SIZE
	sprite.frame = 3 - health

func save_state() -> void:
	state_stack.push_back([health, melted])

func revert_to_previous_state() -> void:
	if state_stack.size() > 1:
		state_stack.pop_back()
	health = state_stack.back()[0]
	melted = state_stack.back()[1]
	refresh_on_board()

func to_json() -> Dictionary:
	return {
		"type": "ice",
		"board_position": [board_position.x, board_position.y],
		"health": health
	}
