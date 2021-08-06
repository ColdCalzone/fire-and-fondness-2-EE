extends "res://objects/board/Character.gd"
class_name Player

const SPRITE_CHARACTERS = preload("res://sprites/characters.png")
const SPRITE_ASH = preload("res://sprites/ash.png")
const TIME_CLONE = preload("res://objects/board/TimeClone.tscn")

onready var sprite : Sprite = $Sprite
onready var tween : Tween = $Tween

var can_move : bool
var flipped : bool

var stuck : bool = false

var newly_stuck : bool = false 

var steps_taken : int = 0

var duplicated : bool = false

var state_stack : Array

var collected_flowers : int = 0

var fake_partner : bool = false
var burned : bool = false

signal player_moved

func wiggle(direction : Vector2) -> void:
	tween.interpolate_property(sprite, "offset", Vector2(0, -8) + (direction * 2), Vector2(0, -8), 0.1, Tween.TRANS_SINE)
	var scale_start : Vector2 = Vector2.ONE
	match direction:
		Vector2.UP:
			scale_start = Vector2(1.0, 1.5)
		Vector2.DOWN:
			scale_start = Vector2(1.0, 0.65)
		_:
			scale_start = Vector2(1.5, 1.0)
	sprite.scale = scale_start
	tween.interpolate_property(sprite, "scale", scale_start, Vector2(1.0, 1.0), 0.25, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()

func burn() -> void:
	sprite.region_enabled = false
	sprite.texture = SPRITE_ASH
	state = STATE.BURNED
	burned = true
	SoundMaster.fade_out_music()

func crush() -> void:
	SoundMaster.play_sound("squish")
	can_move = false
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

func caught_by_cat() -> void:
	state = STATE.CATTED
	SoundMaster.fade_out_music()

func caught_by_inlaw() -> void:
	state = STATE.INLAWED
	SoundMaster.fade_out_music()

func finish_turn() -> void:
	can_move = false
	steps_taken += 1

# Called every time the player moves, or is moved
func check_for_flowers() -> void:
	for flower in get_tree().get_nodes_in_group("flower"):
		if flower.board_position == board_position and not flower.collected and not flower.burned:
			flower.collect()
			collected_flowers += 1
			SoundMaster.audio_flower_pickup.pitch_scale += 0.125

func can_do_something() -> bool:
	# Check that we can move in at least one direction
	for direction in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		if can_move_to(board_position + direction):
			return true
	# If not, are there any interactables we can use?
	var interactive_objects : Array = get_tree().get_nodes_in_group("interactive")
	for current_object in interactive_objects:
		if current_object.board_position == board_position and current_object.is_interactive():
			return true
	# Nope, there's nothing we can do
	return false

func is_fake_partner() -> bool:
	return fake_partner

func is_blocker(is_player : bool = false) -> bool:
	if !fake_partner:
		return is_player
	return false

func can_move_to(candidate : Vector2) -> bool:
	for character in get_tree().get_nodes_in_group("character"):
		if character.board_position == candidate:
			if not character in get_tree().get_nodes_in_group("player") and not character.is_fake_partner():
				return false
	# duplicates can't recognize board
	return get_parent().is_space_free(candidate, not is_fake_partner())

func try_to_move(move_direction : Vector2) -> void:
	if is_fake_partner():
		move_direction = -move_direction
	var candidate_position : Vector2 = board_position + move_direction
	if can_move_to(candidate_position):
		if Levels.time_level:
			var tc = TIME_CLONE.instance()
			tc.flipped = flipped
			tc.board_position = board_position
			tc.state = STATE.NON_EXISTANT
			tc.save_state()
			tc.state = STATE.NORMAL
			get_parent().add_child(tc)
			tc.refresh_on_board()
		SoundMaster.play_sound("player_step")
		board_position = candidate_position
		refresh_on_board()
		check_for_flowers()
		finish_turn()
		# Add a bit of flair to the movement
		wiggle(move_direction * -1)

func can_interact() -> Array:
	var interactive_objects : Array = get_tree().get_nodes_in_group("interactive")
	for current_object in interactive_objects:
		if current_object.board_position == board_position and current_object.is_interactive():
			return [true, current_object]
	return [false]

func try_to_interact() -> void:
	if can_interact()[0]:
		can_interact()[1].activate()
		finish_turn()

func flip(left : bool) -> void:
	flipped = left if not is_fake_partner() else not left

func refresh_on_board() -> void:
	if state == STATE.NON_EXISTANT: queue_free()
	position = board_position * TILE_SIZE
	if is_fake_partner():
		sprite.region_rect.position.x = Settings.partner_avatar * 16
	else:
		sprite.region_rect.position.x = Settings.player_avatar * 16
	sprite.flip_h = flipped
	if state == STATE.BURNED:
		sprite.texture = SPRITE_ASH
	else:
		sprite.texture = SPRITE_CHARACTERS

func save_state() -> void:
	state_stack.push_back(
		[board_position, state, steps_taken, flipped]
	)

func revert_to_previous_state() -> void:
	if state_stack.size() > 1:
		state_stack.pop_back()
	board_position = state_stack.back()[0]
	state = state_stack.back()[1]
	steps_taken = state_stack.back()[2]
	flipped = state_stack.back()[3]
	refresh_on_board()

func to_json() -> Dictionary:
	return {
		"type": "player",
		"board_position": [board_position.x, board_position.y],
		"fake_partner": fake_partner,
		"flipped": flipped
	}

