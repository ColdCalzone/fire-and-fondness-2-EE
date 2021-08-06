extends "res://objects/board/BoardObject.gd"

class_name Bomb

const OBJ_EXPLOSION = preload("res://objects/board/Explosion.tscn")
const OLD_SPRITE = preload("res://sprites/old_bomb.png")
const SPRITE = preload("res://sprites/bomb.png")

const ANIM_SPEED : float = 20.0

onready var sprite : Sprite = $Sprite

var lit : bool = false
var exploded : bool = false
var anim_index : float = 0.0

var state_stack : Array

func is_about_to_explode() -> bool:
	return lit and not exploded

func can_be_lit() -> bool:
	return not lit and not exploded

func light() -> void:
	lit = true
	SoundMaster.play_sound("bomb_wick")

func explode() -> void:
	exploded = true
	sprite.hide()
	# Destroy nearby rocks/burn things
	for current_direction in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		for current_rock in get_tree().get_nodes_in_group("rock"):
			if current_rock.can_be_destroyed() and current_rock.board_position == board_position + current_direction:
				current_rock.destroy()
		for current_object in get_tree().get_nodes_in_group("board_object"):
			if current_object.is_flammable() and current_object.board_position == board_position + current_direction:
				current_object.burn()
	# Make explosion effect
	var explosion = OBJ_EXPLOSION.instance()
	explosion.board_position = board_position
	explosion.board = board
	get_parent().add_child(explosion)

func explode_if_lit() -> void:
	if lit and not exploded:
		explode()

func _process(delta : float) -> void:
	if lit:
		anim_index += delta * ANIM_SPEED
		sprite.frame = min(10, int(anim_index))

func is_blocker(is_player : bool = false) -> bool:
	return not exploded

func refresh_on_board() -> void:
	position = board_position * TILE_SIZE
	if exploded:
		sprite.hide()
	else:
		sprite.show()
	if Settings.classic_mode:
		sprite.texture = OLD_SPRITE
	else:
		sprite.texture = SPRITE

func save_state() -> void:
	state_stack.push_back([lit, exploded])

func revert_to_previous_state() -> void:
	if state_stack.size() > 1:
		state_stack.pop_back()
	lit = state_stack.back()[0]
	exploded = state_stack.back()[1]
	# If we just reverted from an exploded state, we need to reset the animation
	if not exploded:
		anim_index = 0
		sprite.frame = 0 # For rewinding after animation plays
	refresh_on_board()

func to_json() -> Dictionary:
	return {
		"type": "bomb",
		"board_position": [board_position.x, board_position.y]
	}
