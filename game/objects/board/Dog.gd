extends "res://objects/board/Character.gd"

class_name Dog

const SPRITE_ASH = preload("res://sprites/ash.png")
const SPRITE = preload("res://sprites/dog.png")
const OLD_SPRITE = preload("res://sprites/old_dog.png")

onready var sprite : Sprite = $Sprite
onready var sprite_thoughts : Sprite = $Sprite_Thoughts
onready var anim_player : AnimationPlayer = $AnimationPlayer
onready var tween : Tween = $Tween

const FOUR_DIRECTIONS : Array = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

enum BEHAVIOUR_STATE {IDLE, JUST_SAW, CHASING, NON_EXISTANT}

var target_position : Vector2 = Vector2.ZERO
var chasing_cat : bool = false
onready var behaviour_state = BEHAVIOUR_STATE.IDLE

var duplicated : bool = false

var state_stack : Array

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

func can_see_position(position : Vector2) -> bool:
	for direction in FOUR_DIRECTIONS:
		var cursor : Vector2 = board_position
		var blocked : bool = false
		while not blocked:
			cursor += direction
			if not get_parent().is_space_free(cursor):
				blocked = true
				break
			if cursor == position:
				return true
	return false

func can_see_player() -> bool:
	for chasable in get_tree().get_nodes_in_group("player"):
		if can_see_position(chasable.board_position):
			return can_see_position(chasable.board_position)
	return false

func can_see_cat() -> bool:
	for chasable in get_tree().get_nodes_in_group("cat"):
		if can_see_position(chasable.board_position):
			return can_see_position(chasable.board_position)
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
	# or cat!
	for chasable in get_tree().get_nodes_in_group("chasable"):
		if board_position == chasable.board_position:
			chasable.caught_by_dog()
			SoundMaster.play_sound("dog_catch")

# Special case - can the dog see the player having just used a mover/teleporter?
func check_for_player_after_move() -> void:
	match behaviour_state:
		BEHAVIOUR_STATE.IDLE:
			idle()
	try_to_catch_player()
	refresh_on_board()

func can_act() -> bool:
	match behaviour_state:
		BEHAVIOUR_STATE.IDLE:
			return can_see_player() or can_see_cat()
		BEHAVIOUR_STATE.JUST_SAW:
			return true
		BEHAVIOUR_STATE.CHASING:
			return true
	return false

func idle() -> void:
	if can_see_player() or can_see_cat():
		behaviour_state = BEHAVIOUR_STATE.JUST_SAW
		think_question()
		SoundMaster.play_sound("dog_wake")
		wiggle_wake()

func just_saw() -> void:
	var seen : Array = []
	for chasable in get_tree().get_nodes_in_group("chasable"):
		if can_see_player() or can_see_cat():
			behaviour_state = BEHAVIOUR_STATE.CHASING
			if chasable in get_tree().get_nodes_in_group("player"):
				seen.push_back(chasable)
			if chasable in get_tree().get_nodes_in_group("cat"):
				seen.push_front(chasable)
			
			target_position = seen[0].board_position
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
		BEHAVIOUR_STATE.JUST_SAW:
			just_saw()
		BEHAVIOUR_STATE.CHASING:
			# Update the target position if we can see the player
			if can_see_cat():
				var chasable_position : Vector2
				for chasable in get_tree().get_nodes_in_group("cat"):
					if can_see_position(chasable.board_position):
						chasable_position = chasable.board_position
						chasing_cat = true
				target_position = chasable_position
			elif can_see_player() and not chasing_cat:
				var chasable_position : Vector2
				for chasable in get_tree().get_nodes_in_group("player"):
					if can_see_position(chasable.board_position):
						chasable_position = chasable.board_position
				target_position = chasable_position
				
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
					print("ERROR: dog goes wat")
			else:
				# Something weird happened - maybe we got teleported? Anyway, should probably give up.
				behaviour_state = BEHAVIOUR_STATE.JUST_SAW
				chasing_cat = false
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
	state_stack.push_back([board_position, behaviour_state, target_position, chasing_cat])

func revert_to_previous_state() -> void:
	if state_stack.size() > 1:
		state_stack.pop_back()
	board_position = state_stack.back()[0]
	behaviour_state = state_stack.back()[1]
	target_position = state_stack.back()[2]
	chasing_cat = state_stack.back()[3]
	refresh_on_board()

func to_json() -> Dictionary:
	return {
		"type": "dog",
		"board_position": [board_position.x, board_position.y]
	}
