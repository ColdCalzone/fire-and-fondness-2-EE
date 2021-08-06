extends Sprite

const ANIM_SPEED : float = 10.0
const TILE_SIZE : float = 16.0

var anim_index : float = 0.0
var burning : bool = false
var delay : float

var board_position : Vector2
var board

func refresh_on_board() -> void:
	position = board_position * TILE_SIZE

func burn_tile() -> void:
	for current_object in get_tree().get_nodes_in_group("board_object"):
		if current_object.is_flammable() and current_object.board_position == board_position:
			current_object.burn()
	# Check for surrounding objects to affect
	for offset in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		# Melting ice
		for current_ice in get_tree().get_nodes_in_group("ice"):
			if not current_ice.melted and current_ice.board_position == board_position + offset:
				current_ice.set_hit()
		# Igniting bombs
		for current_bomb in get_tree().get_nodes_in_group("bomb"):
			if current_bomb.can_be_lit() and current_bomb.board_position == board_position + offset:
				current_bomb.light()

func _process(delta : float) -> void:
	if burning:
		anim_index += delta * ANIM_SPEED
		if anim_index >= 6.0:
			queue_free()
		else:
			frame = int(anim_index)

func _ready() -> void:
	hide()
	refresh_on_board()
	yield(get_tree().create_timer(delay), "timeout")
	burning = true
	show()
	burn_tile()
