extends "res://objects/board/Character.gd"

class_name Cat

const SPRITE_ASH = preload("res://sprites/ash.png")
const SPRITE = preload("res://sprites/cat.png")
const OLD_SPRITE = preload("res://sprites/old_cat.png")

onready var sprite : Sprite = $Sprite
onready var sprite_thoughts : Sprite = $Sprite_Thoughts
onready var anim_player : AnimationPlayer = $AnimationPlayer
onready var tween : Tween = $Tween

var PREFERRED_DIRECTIONS : Dictionary = {
	Vector2.UP: [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP],
	Vector2.DOWN: [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN],
	Vector2.LEFT: [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT],
	Vector2.RIGHT: [Vector2.DOWN, Vector2.UP, Vector2.LEFT, Vector2.RIGHT]
}

var moving_direction : Vector2 = Vector2.LEFT

var FOUR_DIRECTIONS : Array = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

enum BEHAVIOUR_STATE {IDLE, JUST_SEEN, CHASED, NON_EXISTANT}

var target_position : Vector2 = Vector2.ZERO
onready var behaviour_state = BEHAVIOUR_STATE.IDLE

var duplicated : bool = false

var state_stack : Array

var distance_from_dog = 0

var turned : bool = false

func wiggle_wake() -> void:
	tween.interpolate_property(sprite, "scale", Vector2(1.0, 0.5), Vector2(1.0, 1.0), 0.25, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()

func wiggle_sleep() -> void:
	tween.interpolate_property(sprite, "scale", Vector2(1.0, 1.5), Vector2(1.0, 1.0), 0.25, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()

func wiggle(direction : Vector2) -> void:
	sprite.offset = Vector2(0, -8) + (direction * 2)
	tween.interpolate_property(sprite, "offset", Vector2(0, -8) + (direction * 2), Vector2(0, -8), 0.1, Tween.TRANS_SINE)
	var scale_start : Vector2 = Vector2.ONE
	match direction:
		Vector2.UP:
			scale_start = Vector2(1.0, 1.5)
		Vector2.DOWN:
			scale_start = Vector2(1.0, 0.65)
		_:
			scale_start = Vector2(1.5, 1.0)
	tween.interpolate_property(sprite, "scale", scale_start, Vector2(1.0, 1.0), 0.25, Tween.TRANS_CIRC, Tween.EASE_OUT)
	sprite.scale = scale_start
	tween.start()

func burn() -> void:
	sprite.region_enabled = false
	sprite.texture = SPRITE_ASH
	state = STATE.BURNED
	SoundMaster.fade_out_music()

func crush() -> void:
	SoundMaster.play_sound("squish")
	sprite.hide()
	state = STATE.CRUSHED
	SoundMaster.fade_out_music()

func fall() -> void:
	SoundMaster.play_sound("fall")
	sprite.hide()
	state = STATE.FALLEN
	SoundMaster.fade_out_music()

func caught_by_dog() -> void:
	state = STATE.DOGGED
	SoundMaster.fade_out_music()

func can_see_position(position : Vector2) -> bool:
	for direction in FOUR_DIRECTIONS:
		var cursor : Vector2 = board_position
		var blocked : bool = false
		while not blocked:
			cursor += direction
			if cursor == position:
				return true
			if not get_parent().is_space_free(cursor):
				blocked = true
	return false

func can_see_dog() -> bool:
	for dog in get_tree().get_nodes_in_group("dog"):
		if can_see_position(dog.board_position):
			return can_see_position(dog.board_position)
	return false

func can_see_dog_directional(direction: Vector2) -> bool:
	for dog in get_tree().get_nodes_in_group("dog"):
		var cursor : Vector2 = board_position
		var blocked : bool = false
		while not blocked:
			cursor += direction
			if cursor == dog.board_position:
				return true
			if not get_parent().is_space_free(cursor):
				blocked = true
	return false

func straight_line_between(a : Vector2, b : Vector2) -> bool:
	#return (a.x != b.x and a.y == b.y) or (a.x == b.x and a.y != b.y) # My kingdom for a boolean XOR!
	return a != b # Give me your kingdom

func think_question() -> void:
	sprite_thoughts.frame = 0
	anim_player.play("think")

func think_exclamation() -> void:
	sprite_thoughts.frame = 1
	anim_player.play("think")

func try_to_catch_player() -> void:
	# If we're at the same position as the player, gg!
	for player in get_tree().get_nodes_in_group("player"):
		if board_position == player.board_position:
			player.caught_by_cat()
			SoundMaster.play_sound("dog_catch")

# Special case - can the cat see the dog having just used a mover/teleporter?
func check_for_dog_after_move() -> void:
	match behaviour_state:
		BEHAVIOUR_STATE.IDLE:
			idle()
	try_to_catch_player()
	refresh_on_board()

func can_act() -> bool:
	match behaviour_state:
		BEHAVIOUR_STATE.IDLE:
			return can_see_dog()
		BEHAVIOUR_STATE.JUST_SEEN:
			return true
		BEHAVIOUR_STATE.CHASED:
			var candidate : Vector2 = board_position + moving_direction
			# Change direction if needed/able
			if not can_move_to(candidate, moving_direction):
				choose_new_direction()
			if not turned:
				var directions : int
				for direction in FOUR_DIRECTIONS:
					if can_move_to(board_position + direction, direction) and direction != -moving_direction:
						directions += 1
				if directions > 1:
					choose_new_direction()
					turned = true
			# Move if able
			candidate = board_position + moving_direction
			if can_move_to(candidate, moving_direction):
				SoundMaster.play_sound("player_step")
				board_position = candidate
				wiggle(moving_direction * -1)
				refresh_on_board()
			# Did we just catch the player?
			if not can_see_dog():
				distance_from_dog += 1
				if distance_from_dog >= 4:
					behaviour_state = BEHAVIOUR_STATE.JUST_SEEN
					distance_from_dog = 0
					turned = false
			else:
				distance_from_dog = 0
			try_to_catch_player()
	return false

func can_move_to(position : Vector2, direction : Vector2) -> bool:
	if not get_parent().is_space_free(position):
		return false
	else:
		var cursor : Vector2 = board_position
		var blocked : bool = false
		while not blocked:
			cursor += direction
			for dog in get_tree().get_nodes_in_group("dog"):
				if cursor == dog.board_position:
					return false
			if not get_parent().is_space_free(cursor):
				blocked = true
	return true

func choose_new_direction() -> void:
	var directions : Array = PREFERRED_DIRECTIONS[moving_direction]
	for direction in directions:
		var candidate : Vector2 = board_position + direction
		if can_move_to(candidate, direction):
			moving_direction = direction
				
			return

func idle() -> void:
	if can_see_dog():
		behaviour_state = BEHAVIOUR_STATE.CHASED
		think_question()
		SoundMaster.play_sound("dog_wake")
		wiggle_wake()

func just_seen() -> void:
	for dog in get_tree().get_nodes_in_group("dog"):
		if can_see_dog():
			behaviour_state = BEHAVIOUR_STATE.CHASED
			var dog_position : Vector2 = dog.board_position
			target_position = dog_position
			think_exclamation()
			SoundMaster.play_sound("dog_alert")
		else:
			behaviour_state = BEHAVIOUR_STATE.IDLE
			SoundMaster.play_sound("dog_nevermind")
			wiggle_sleep()

func act() -> void:
	match behaviour_state:
		BEHAVIOUR_STATE.IDLE:
			idle()
		BEHAVIOUR_STATE.JUST_SEEN:
			just_seen()
		BEHAVIOUR_STATE.CHASED:
			# Update the target position if we can see the dog
			if can_see_dog():
				var dog_position : Vector2
				for dog in get_tree().get_nodes_in_group("dog"):
					if can_see_position(dog.board_position):
						dog_position = dog.board_position
				target_position = dog_position
			# It's a straight line to the target, right?
			if straight_line_between(board_position, target_position) and can_see_position(target_position):
				if target_position.x > board_position.x:
					board_position.x += 1
					wiggle(Vector2.LEFT)
				elif target_position.x < board_position.x:
					board_position.x -= 1
					wiggle(Vector2.RIGHT)
				elif target_position.y > board_position.y:
					board_position.y += 1
					wiggle(Vector2.UP)
				elif target_position.y < board_position.y:
					board_position.y -= 1
					wiggle(Vector2.DOWN)
				else:
					# wat
					print("ERROR: cat goes wat")
			else:
				# Something weird happened - maybe we got teleported? Anyway, should probably give up.
				behaviour_state = BEHAVIOUR_STATE.JUST_SEEN
				think_question()
				SoundMaster.play_sound("dog_lose")

	try_to_catch_player()
	refresh_on_board()

func refresh_on_board() -> void:
	if behaviour_state == BEHAVIOUR_STATE.NON_EXISTANT: queue_free()
	position = board_position * TILE_SIZE
	sprite.frame = 0 if behaviour_state == BEHAVIOUR_STATE.IDLE else 1
	if Settings.classic_mode:
		sprite.texture = OLD_SPRITE
	else:
		sprite.texture = SPRITE

func save_state() -> void:
	state_stack.push_back([board_position, behaviour_state, target_position, moving_direction, distance_from_dog, turned])

func revert_to_previous_state() -> void:
	if state_stack.size() > 1:
		state_stack.pop_back()
	board_position = state_stack.back()[0]
	behaviour_state = state_stack.back()[1]
	target_position = state_stack.back()[2]
	moving_direction = state_stack.back()[3]
	distance_from_dog = state_stack.back()[4]
	turned = state_stack.back()[5]
	refresh_on_board()

func to_json() -> Dictionary:
	return {
		"type": "cat",
		"board_position": [board_position.x, board_position.y]
	}
