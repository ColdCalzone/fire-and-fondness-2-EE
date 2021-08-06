extends Node2D

const ANIM_SPEED : float = 20.0
const TILE_SIZE : float = 16.0

const SPRITE = preload("res://sprites/explosion.png")
const OLD_SPRITE = preload("res://sprites/old_explosion.png")

onready var anim_index : float = 0.0
var board_position : Vector2
var board

onready var sprite_north = $Sprite_North
onready var sprite_south = $Sprite_South
onready var sprite_west = $Sprite_West
onready var sprite_east = $Sprite_East

func refresh_on_board() -> void:
	position = board_position * TILE_SIZE
	if Settings.classic_mode:
		sprite_north.texture = OLD_SPRITE
		sprite_south.texture = OLD_SPRITE
		sprite_west.texture = OLD_SPRITE
		sprite_east.texture = OLD_SPRITE
	else:
		sprite_north.texture = SPRITE
		sprite_south.texture = SPRITE
		sprite_west.texture = SPRITE
		sprite_east.texture = SPRITE

func _process(delta : float) -> void:
	anim_index += delta * ANIM_SPEED
	if anim_index >= sprite_north.hframes:
		queue_free()
	else:
		for sprite in [sprite_north, sprite_south, sprite_west, sprite_east]:
			sprite.frame = int(anim_index)

func _ready() -> void:
	refresh_on_board()
	if board.is_space_free(board_position + Vector2.UP):
		sprite_north.show()
	if board.is_space_free(board_position + Vector2.DOWN):
		sprite_south.show()
	if board.is_space_free(board_position + Vector2.LEFT):
		sprite_west.show()
	if board.is_space_free(board_position + Vector2.RIGHT):
		sprite_east.show()
