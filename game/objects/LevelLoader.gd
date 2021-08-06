extends Node2D

const TILESET_COLOURBLIND = preload("res://tileset/tileset1_cb.tres")
const TILESET_CLASSIC = preload("res://tileset/tileset1_classic.tres")

const OBJECT_PLAYER = preload("res://objects/board/Player.tscn")
const OBJECT_PARTNER = preload("res://objects/board/Partner.tscn")
const OBJECT_FLOWER = preload("res://objects/board/Flower.tscn")
const OBJECT_FLAMETHROWER = preload("res://objects/board/Flamethrower.tscn")
const OBJECT_DOOR = preload("res://objects/board/Door.tscn")
const OBJECT_SWITCH = preload("res://objects/board/Switch.tscn")
const OBJECT_MOVER = preload("res://objects/board/Mover.tscn")
const OBJECT_ROTATING_MOVER = preload("res://objects/board/RotatingMover.tscn")
const OBJECT_TELEPORTER = preload("res://objects/board/Teleporter.tscn")
const OBJECT_TELEPORTER_TARGET = preload("res://objects/board/TeleporterTarget.tscn")
const OBJECT_BOMB = preload("res://objects/board/Bomb.tscn")
const OBJECT_ROCK = preload("res://objects/board/Rock.tscn")
const OBJECT_ICE = preload("res://objects/board/Ice.tscn")
const OBJECT_HOURGLASS = preload("res://objects/board/Hourglass.tscn")
const OBJECT_TRAPDOOR = preload("res://objects/board/Trapdoor.tscn")
const OBJECT_PRESSURE_PLATE = preload("res://objects/board/PressurePlate.tscn")
const OBJECT_DOG = preload("res://objects/board/Dog.tscn")
const OBJECT_INLAW = preload("res://objects/board/Inlaw.tscn")
const OBJECT_DUPLICATOR = preload("res://objects/board/Duplicator.tscn")
const OBJECT_CAT = preload("res://objects/board/Cat.tscn")

const CLEAR_AREA : Rect2 = Rect2(-4, -4, 32, 20)

var object_resources = {
	"player": OBJECT_PLAYER,
	"partner": OBJECT_PARTNER,
	"flower": OBJECT_FLOWER,
	"flamethrower": OBJECT_FLAMETHROWER,
	"door": OBJECT_DOOR,
	"switch": OBJECT_SWITCH,
	"mover": OBJECT_MOVER,
	"rotating_mover": OBJECT_ROTATING_MOVER,
	"teleporter": OBJECT_TELEPORTER,
	"teleporter_target": OBJECT_TELEPORTER_TARGET,
	"bomb": OBJECT_BOMB,
	"rock": OBJECT_ROCK,
	"ice": OBJECT_ICE,
	"hourglass": OBJECT_HOURGLASS,
	"trapdoor": OBJECT_TRAPDOOR,
	"pressure_plate": OBJECT_PRESSURE_PLATE,
	"dog": OBJECT_DOG,
	"inlaw": OBJECT_INLAW,
	"duplicator": OBJECT_DUPLICATOR,
	"cat": OBJECT_CAT
}

export (NodePath) var path_board
onready var board = get_node(path_board)

var player
var partner

func place_tiles(tile_data : Array) -> void:
	# First, do we need to switch to the colourblind palette?
	if Settings.colour_blind_assist == Settings.COLOUR_BLIND_ASSIST.PALETTE:
		board.set_tileset(TILESET_COLOURBLIND)
	if Settings.classic_mode:
		board.set_tileset(TILESET_CLASSIC)
	# Fill the whole board with walls first
	for x in range(CLEAR_AREA.position.x, CLEAR_AREA.position.x + CLEAR_AREA.size.x):
		for y in range(CLEAR_AREA.position.y, CLEAR_AREA.position.y + CLEAR_AREA.size.y):
			board.set_cell(x, y, 0)
	# Now actually place the tiles
	for y in range(0, tile_data.size()):
		var row : Array = tile_data[y]
		for x in range(0, row.size()):
			var cell : int
			if row[x] == null:
				cell = 0
			else:
				cell = row[x]
			board.set_cell(x, y, cell)
	board.update_bitmask_region()

func place_object(object_data : Dictionary) -> void:
	# Make sure we recognise this object
	if not object_data.type in object_resources:
		print("ERROR: unsupported object type %s" % object_data.type)
		return
	# Okay, we know what this is. Moving on
	var scene = object_resources[object_data.type]
	var object = scene.instance()
	object.board_position = Vector2(object_data["board_position"][0], object_data["board_position"][1])
	# Now set variables specific to the object type
	match object_data.type:
		"player":
			object.flipped = object_data["flipped"]
			if object_data.has("fake_partner"):
				object.fake_partner = object_data["fake_partner"]
				if object_data["fake_partner"]:
					partner = object
				else:
					player = object
			else:
				player = object
		"partner":
			object.flipped = object_data["flipped"]
			partner = object
		"flamethrower":
			object.turns_until_fire = object_data["turns_until_fire"]
			object.turns_between_fire = object_data["turns_between_fire"]
		"door":
			object.door_type = object_data["door_type"]
			object.open = object_data["open"]
		"flower":
			object.index = object_data["index"]
		"switch":
			object.door_type = object_data["door_type"]
			object.toggled = object_data["toggled"]
		"mover":
			object.direction_index = object_data["direction_index"]
		"rotating_mover":
			object.direction_index = object_data["direction_index"]
			object.turning_direction = object_data["turning_direction"]
		"teleporter":
			object.teleporter_type = object_data["teleporter_type"]
		"teleporter_target":
			object.teleporter_type = object_data["teleporter_type"]
		"duplicator":
			object.teleporter_type = object_data["teleporter_type"]
		"hourglass":
			object.door_type = object_data["door_type"]
			object.toggled = object_data["toggled"]
			object.time_until_flip = object_data["time_until_flip"]
			object.time_between_flips = object_data["time_between_flips"]
		"pressure_plate":
			object.door_type = object_data["door_type"]
		"trapdoor":
			if object_data.has("open"):
				object.open = object_data["open"]
	# Finally, add it to the scene
	board.add_child(object)
	if object_data.type == "trapdoor":
		print(object.state)
	object.set_board(board)
	object.refresh_on_board()

func place_objects(objects : Array) -> void:
	for object in objects:
		place_object(object)

func load_level(data : Dictionary) -> void:
	if "flags" in data:
		# Are we on a joke level?
		Levels.joke_level = data["flags"]["joke"]
		# Does the level have frozen time?
		Levels.time_level = data["flags"]["time"]
	else:
		Levels.joke_level = false
		Levels.time_level = false
	# Now actually make the level
	place_tiles(data["tiles"])
	place_objects(data["objects"])
	var camera_offset : Array = data["camera_offset"]
	board.camera_offset = Vector2(camera_offset[0], camera_offset[1])
	if not Levels.currently_editing:
		board.par = Levels.get_level_par(Levels.current_scene)
	elif not Levels.editing_level:
		board.par = data["par"]

func setup_level() -> void:
	board.player = player
	board.partner = partner
	for players in get_tree().get_nodes_in_group("player"):
		players.connect("player_moved", board, "player_moved")
	for current_object in get_tree().get_nodes_in_group("board_object"):
		current_object.get_board_position_from_position()
		current_object.set_board(board)
