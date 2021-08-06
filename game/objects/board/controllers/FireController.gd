extends Node

const OBJ_FIRE = preload("res://objects/board/Fire.tscn")

const DELAY_INCR : float = 0.05
# burn.
const MAX_DELAY : float = 5.2

class Fire:
	var position : Vector2
	var delay : float
	
	func _init(position : Vector2, delay : float):
		self.position = position
		self.delay = delay

func get_youngest_fire(burning : Array) -> Fire:
	var youngest_fire : Fire = burning[0]
	for fire in burning:
		if fire.delay < youngest_fire.delay:
			youngest_fire = fire
	return youngest_fire

func array_has_fire_with_pos(array : Array, position : Vector2) -> bool:
	for fire in array:
		if fire.position == position:
			return true
	return false

func spread_fire(fire : Fire, burning : Array, burned : Array, board : Board) -> void:
	for offset in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		var candidate : Vector2 = fire.position + offset
		# Check if we can spread in this direction
		var can_spread : bool = true
		if not board.is_space_free(candidate): can_spread = false
		elif array_has_fire_with_pos(burning, candidate): can_spread = false
		elif array_has_fire_with_pos(burned, candidate): can_spread = false
		# If so, get toastin'!
		if can_spread:
			var new_fire : Fire = Fire.new(candidate, fire.delay + DELAY_INCR)
			burning.append(new_fire)

func make_fires_and_return_burn_time(board : Board) -> float:
	SoundMaster.play_sound("flamethrower_fire" if not Levels.joke_level else "flamethrower_fake")
	var burning : Array = []
	var burned : Array = []
	# Create the fires that'll start us off
	for flamethrower in get_tree().get_nodes_in_group("flamethrower"):
		if flamethrower.is_about_to_fire():
			var new_fire : Fire = Fire.new(flamethrower.board_position, 0.5)
			flamethrower.do_effect()
			flamethrower.reset_timer()
			if not Levels.joke_level:
				burning.append(new_fire)
			
	# Calculate how far the fires will go
	while not burning.empty():
		var youngest_fire : Fire = get_youngest_fire(burning)
		# One slight safe-guard: if the youngest fire is already hella old, let's stop
		if youngest_fire.delay > MAX_DELAY:
			break
		spread_fire(youngest_fire, burning, burned, board)
		burned.append(youngest_fire)
		burning.remove(burning.find(youngest_fire))
	# Now actually make the fires
	var max_time : float = 0.0
	for fire in burned:
		max_time = max(fire.delay, max_time)
		var fire_scene = OBJ_FIRE.instance()
		fire_scene.board_position = fire.position
		fire_scene.delay = fire.delay
		board.add_child(fire_scene)
	return max_time

func tick() -> void:
	for flamethrower in get_tree().get_nodes_in_group("flamethrower"):
		flamethrower.tick()

func can_fire() -> bool:
	for flamethrower in get_tree().get_nodes_in_group("flamethrower"):
		if flamethrower.is_about_to_fire():
			return true
	return false
