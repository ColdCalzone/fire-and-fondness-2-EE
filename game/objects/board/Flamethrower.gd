extends "res://objects/board/BoardObject.gd"

const OBJ_FIRE = preload("res://objects/board/Fire.tscn")

const RUMBLE_SPEED : float = 2.0
const SHAKE_AMOUNT : float = 4.0
const ANIM_SPEED : float = 3.0

const CLASSIC_SPRITE = preload("res://sprites/old_flamethrower.png")
const NORMAL_SPRITE = preload("res://sprites/flamethrower.png")

onready var sprite : Sprite = $Sprite
onready var tween : Tween = $Tween

var turns_until_fire : int = 8
var turns_between_fire : int = 8
var rumbling : bool = false # About to spout
var rumble_index : float = 0.0
var anim_index : float = 0.0

var state_stack : Array

func is_about_to_fire() -> bool:
	return turns_until_fire <= 0

func do_effect() -> void:
	rumbling = true
	tween.interpolate_property(self, "rumble_index", 0.0, 1.0, 0.5, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_all_completed")
	rumbling = false
	rumble_index = 0.0
	sprite.offset = Vector2.ZERO
	if not Levels.joke_level:
		board.shake_camera()

func tick() -> void:
	turns_until_fire -= 1

func reset_timer() -> void:
	turns_until_fire = turns_between_fire

func _process(delta : float) -> void:
	anim_index += (delta * ANIM_SPEED) / (max(float(turns_until_fire), 1) / float(turns_between_fire + 1))
	if not Settings.classic_mode:
		sprite.frame = fmod(anim_index, 4.0)
	else:
		sprite.vframes = 1
		sprite.hframes = 1
	if rumbling:
		sprite.offset.x = (randf() - 0.5) * rumble_index * SHAKE_AMOUNT
		anim_index += delta * ANIM_SPEED * 10

func save_state() -> void:
	state_stack.push_back(turns_until_fire)

func revert_to_previous_state() -> void:
	if state_stack.size() > 1:
		state_stack.pop_back()
	turns_until_fire = state_stack.back()

func _ready():
	sprite.texture = CLASSIC_SPRITE if Settings.classic_mode else NORMAL_SPRITE

func to_json() -> Dictionary:
	return {
		"type": "flamethrower",
		"board_position": [board_position.x, board_position.y],
		"turns_until_fire": turns_until_fire,
		"turns_between_fire": turns_between_fire
	}

