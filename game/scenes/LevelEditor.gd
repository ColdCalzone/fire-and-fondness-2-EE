extends Node2D

const SPRITE_ICONS = preload("res://sprites/level_editor_icons.png")
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

const EDITABLE_AREA : Rect2 = Rect2(1, 1, 18, 9)

const FONT_BUTTON : Font = preload("res://fonts/paragraph_bold.tres")
const FONT_PARAGRAPH : Font = preload("res://fonts/paragraph.tres")
const FONT_UI : Font = preload("res://fonts/ui.tres")

const COLOR_SHADOW : Color = Color("222034")
const COLOR_SHADE_A : Color = Color("847e87")
const COLOR_SHADE_B : Color = Color("595652")

onready var board = $Board
onready var loader = $LevelLoader
onready var menu_container = $MenuContainer
onready var msg_timeout = $MessageTimeout

onready var Leveljson = File.new()

enum Mode {FLOOR, PLAYER, PARTNER, FLOWER, FLAMETHROWER, DOOR, SWITCH, MOVER, ROTATING_MOVER, TELEPORTER, TELEPORTER_TARGET, BOMB, ROCK, ICE, HOURGLASS, TRAPDOOR, PRESSURE_PLATE, DOG, INLAW, DUPLICATOR, CAT}


var mode_objects = {
	Mode.PLAYER: OBJECT_PLAYER,
	Mode.PARTNER: OBJECT_PARTNER,
	Mode.FLOWER: OBJECT_FLOWER,
	Mode.FLAMETHROWER: OBJECT_FLAMETHROWER,
	Mode.DOOR: OBJECT_DOOR,
	Mode.SWITCH: OBJECT_SWITCH,
	Mode.MOVER: OBJECT_MOVER,
	Mode.ROTATING_MOVER: OBJECT_ROTATING_MOVER,
	Mode.TELEPORTER: OBJECT_TELEPORTER,
	Mode.TELEPORTER_TARGET: OBJECT_TELEPORTER_TARGET,
	Mode.BOMB: OBJECT_BOMB,
	Mode.ROCK: OBJECT_ROCK,
	Mode.ICE: OBJECT_ICE,
	Mode.HOURGLASS: OBJECT_HOURGLASS,
	Mode.TRAPDOOR: OBJECT_TRAPDOOR,
	Mode.PRESSURE_PLATE: OBJECT_PRESSURE_PLATE,
	Mode.DOG: OBJECT_DOG,
	Mode.INLAW: OBJECT_INLAW,
	Mode.DUPLICATOR: OBJECT_DUPLICATOR,
	Mode.CAT: OBJECT_CAT
}

var object_tooltips = {
	Player: ["(Z): Turn", "(X) Toggle Partner Mode"],
	Partner: ["(Z): Turn", ""],
	Door: ["(Z): Change type", "(X): Open/close"],
	Switch: ["(Z): Change type", "(X): Toggle"],
	Mover: ["(Z): Change direction", ""],
	RotatingMover: ["(Z): Change direction", "(X): Change rotation"],
	Teleporter: ["(Z): Change type", ""],
	Duplicator: ["(Z): Change type", ""],
	TeleporterTarget: ["(Z): Change type", ""],
	Hourglass: ["(Z): Change type", ""],
	PressurePlate: ["(Z): Change type", ""],
	Trapdoor: ["(Z): Open/Close", ""],
}

var help = [
	["LMB", "Place object"],
	["RMB", "Remove object"],
	["Arrow Keys", "Shift board"],
	["MWheel/(A/D)", "Next/previous object"],
	["(Z)", "Change object"],
	["(X)", "Change object alt"],
	["(F1)", "Toggle help"],
	["(F2)", "Playtest level"],
	["(F3)", "Change level settings"],
	["(F5)", "Save to Level.json"],
	["(F6)", "Export to .cart.png"],
	["(F7)", "Export to .png"],
	["(F9)", "Load from Level.json"],
	["(F11)", "Clear level"],
	["(ESC)", "Return to Main Menu"]
]

const BACKGROUNDS = [
	"squares",
	"chevrons",
	"diamonds",
	"mines",
	"cluster",
	"worm",
	"wavy",
	"wavy_alt",
	"wonks",
	"lines",
	"plane",
	"flag",
	"none"
]

onready var last_place_pos : Vector2 = Vector2.ZERO
onready var last_place_type : int = -99
onready var show_grid : bool = true
onready var show_help : bool = false

var mode_index : int = 0
var mode_index_offset : float = 0

var label_a_text : String = ""
var label_b_text : String = ""

var FILELOADED : bool = false
var SAVING : bool = false
var WAITING_FOR_LABEL : bool = false
var ERROR : bool = false
var err_message : String = ""

var flower_index : int = 0

const OBJ_MENU = preload("res://objects/Menu.tscn")
var settings_menu
var confirm_menu
var confirm_open : bool = false

var unsaved : bool = false

var cart_label : Image = Image.new()

func draw_text_with_shadow(font : Font, text : String, position : Vector2, color : Color) -> void:
	draw_string(font, position + Vector2(1, 1), text, COLOR_SHADOW)
	draw_string(font, position, text, color)

func draw_icons() -> void:
	for i in range(-2, 3):
		var index : int = (mode_index + i) % Mode.size()
		if index < 0: index += Mode.size()
		draw_texture_rect_region(SPRITE_ICONS, Rect2(48 + (i*16) + mode_index_offset, 162, 16, 16), Rect2(index*16, 0, 16, 16))
	draw_rect(Rect2(48, 162, 16, 16), Color.white, false, 2.0)

func _draw() -> void:
	draw_icons()
	draw_rect(Rect2(96, 160, 128, 32), Color.black)
	draw_text_with_shadow(FONT_UI, label_a_text, Vector2(102, 168), COLOR_SHADE_A)
	draw_text_with_shadow(FONT_UI, label_b_text, Vector2(102, 176), COLOR_SHADE_B)
	if show_grid:
		# Draw grid
		for x in range(1, 20):
			draw_line(Vector2(x*16, 16), Vector2(x*16, 10*16), Color(0.1, 0.1, 0.1), 1.1)
		for y in range(1, 11):
			draw_line(Vector2(16, y*16), Vector2(16*19, y*16), Color(0.1, 0.1, 0.1), 1.1)
	if confirm_open:
		draw_rect(Rect2(51, 21, 216, 26), Color.black)
		draw_rect(Rect2(51, 21, 216, 26), COLOR_SHADE_A, false, 1.1)
		draw_text_with_shadow(FONT_UI, "Do you want to leave without saving?", Vector2(56, 31), COLOR_SHADE_A)
		draw_text_with_shadow(FONT_UI, "Your work will not be saved.", Vector2(81, 41), COLOR_SHADE_A)
	if FILELOADED: 
		draw_rect(Rect2(215, 168, 225, 178), Color.black)
		draw_text_with_shadow(FONT_UI, "File Loaded!", Vector2(315 - FONT_UI.get_string_size("File Loaded!").x, FONT_UI.get_string_size("File Loaded!").y), COLOR_SHADE_A)
		return
	if WAITING_FOR_LABEL:
		draw_rect(Rect2(56, 21, 208, 136), Color.black)
		draw_rect(Rect2(56, 21, 208, 136), COLOR_SHADE_A, false, 1.1)
		draw_text_with_shadow(FONT_UI, "Drop the Cart label here", Vector2(86, 31), COLOR_SHADE_A)
		draw_text_with_shadow(FONT_UI, "(ESC to cancel)", Vector2(121, 151), COLOR_SHADE_B)
		return
	if SAVING:
		draw_rect(Rect2(215, 168, 225, 178), Color.black)
		draw_text_with_shadow(FONT_UI, "SAVED!", Vector2(315 - FONT_UI.get_string_size("SAVED!").x, FONT_UI.get_string_size("SAVED!").y), COLOR_SHADE_A)
		return
	if ERROR:
		draw_rect(Rect2(215, 168, 225, 178), Color.black)
		var msg_width : float = FONT_UI.get_string_size(err_message).x
		draw_text_with_shadow(FONT_UI, "ERROR: " + err_message, Vector2(2, FONT_UI.get_string_size(err_message).y), COLOR_SHADE_A)
		return
	# Draw cursor
	var cursor_pos : Vector2 = board.world_to_map(get_global_mouse_position())
	if EDITABLE_AREA.has_point(cursor_pos):
		draw_rect(Rect2(cursor_pos.x*16, cursor_pos.y*16, 16, 16), Color(0.5, 0.5, 0.5), false, 1.5)
	# Draw help
	if show_help:
		draw_rect(Rect2(56, 21, 208, 156), Color.black)
		draw_rect(Rect2(56, 21, 208, 156), COLOR_SHADE_A, false, 1.1)
		for i in range(0, help.size()):
			var help_item : Array = help[i]
			var help_width : float = FONT_UI.get_string_size(help_item[0]).x
			draw_text_with_shadow(FONT_UI, help_item[0], Vector2(128 - help_width, 31 + (i*10)), COLOR_SHADE_B)
			draw_text_with_shadow(FONT_UI, help_item[1], Vector2(136, 31 + (i*10)), COLOR_SHADE_A)
	else:
		draw_text_with_shadow(FONT_UI, "(F1) Help", Vector2(268, 10), COLOR_SHADE_B)
		draw_text_with_shadow(FONT_UI, "Press escape to stop testing.", Vector2(5,  10), COLOR_SHADE_B)

func change_object() -> void:
	var object : Node2D = find_object_to_change()
	if object == null: return
	if object is Player or object is Partner:
		object.flipped = !object.flipped
	if object is Switch or object is Door or object is Hourglass or object is PressurePlate:
		object.door_type += 1
		if object.door_type >= 4:
			object.door_type = 0
	if object is Mover or object is RotatingMover:
		object.direction_index += 1
		if object.direction_index >= 4:
			object.direction_index = 0
	if object is Teleporter or object is TeleporterTarget or object is Duplicator:
		object.teleporter_type += 1
		if object.teleporter_type >= 4:
			object.teleporter_type = 0
	if object is Trapdoor:
		object.editor_open_acted = false
		object.open = !object.open
		
	object.refresh_on_board()

func change_object_alt() -> void:
	var object : Node2D = find_object_to_change()
	if object == null: return
	if object is Door:
		object.open = !object.open
	if object is Switch:
		object.toggled = !object.toggled
	if object is RotatingMover:
		object.turning_direction *= -1
	if object is Player:
		object.fake_partner = !object.fake_partner
	object.refresh_on_board()

func find_object_to_change() -> Node2D:
	var tile_pos : Vector2 = board.world_to_map(get_global_mouse_position())
	if not EDITABLE_AREA.has_point(tile_pos): return null
	for current_object in get_tree().get_nodes_in_group("board_object"):
		if current_object.board_position == tile_pos:
			return current_object
	return null

func place_floor(pos : Vector2) -> void:
	if last_place_pos == pos and last_place_type == Mode.FLOOR:
		return
	board.set_cellv(pos, rand_range(3, 6))
	board.update_bitmask_region()
	# Make sure we aren't doing this sixty times a second
	last_place_pos = pos
	last_place_type = Mode.FLOOR

func remove_floor(pos : Vector2) -> void:
	if last_place_pos == pos and last_place_type == Mode.FLOOR + 100:
		return
	board.set_cellv(pos, 0)
	board.update_bitmask_region()
	# Make sure we aren't doing this sixty times a second
	last_place_pos = pos
	last_place_type = Mode.FLOOR + 100

func place_object(pos : Vector2) -> void:
	if last_place_pos == pos and last_place_type == mode_index:
		return
	# Delete anything already on this tile unless it's a flower
	if not mode_index == Mode.FLOWER: delete_object(pos)
	var new_object = mode_objects[mode_index].instance()
	match mode_index:
		Mode.FLOWER:
			var ignore = false
			new_object.index = flower_index
			flower_index += 1
			flower_index = clamp(flower_index, 0, 5)
			for flowers in get_tree().get_nodes_in_group("flower"):
				if flowers.board_position == pos:
					ignore = true
					break
			if flower_index <= 4 and not ignore:
				delete_object(pos)
				new_object.board_position = pos
				new_object.position = pos * 16
				board.add_child(new_object)
				new_object.set_board(board)
				# Make sure we aren't doing this sixty times a second
				last_place_pos = pos
				last_place_type = mode_index
				new_object.refresh_on_board()
			else: flower_index -= 1
		_:
			new_object.board_position = pos
			new_object.position = pos * 16
			board.add_child(new_object)
			new_object.set_board(board)
			# Make sure we aren't doing this sixty times a second
			last_place_pos = pos
			last_place_type = mode_index
			# Is this a door? Do we need to place a tile?
			if mode_index == Mode.DOOR:
				if new_object.sprite.rotation_degrees == -90:
					board.set_cellv(pos, 1)
				else:
					board.set_cellv(pos, 2)
			new_object.refresh_on_board()

func delete_object(pos : Vector2) -> void:
	if last_place_pos == pos and last_place_type == mode_index + 100:
		return
	var deleted_flower
	# yeetus deletus this is for the flowers
	# please god if someone knows how this stuff works tell me how to do this better.
	for flowers in get_tree().get_nodes_in_group("flower"):
		if flowers.board_position == pos:
			deleted_flower = flowers.index
			flower_index -= 1
			if flower_index == 4: flower_index -= 1
			for flower in get_tree().get_nodes_in_group("flower"):
				if flower.index > deleted_flower:
					flower.index -= 1
			break
	for current_object in get_tree().get_nodes_in_group("board_object"):
		if current_object.board_position == pos:
			current_object.queue_free()
		else:
			current_object.refresh_on_board()
	# Make sure we aren't doing this sixty times a second
	last_place_pos = pos
	last_place_type = mode_index + 100

func place_tile() -> void:
	var tile_pos : Vector2 = board.world_to_map(get_global_mouse_position())
	if not EDITABLE_AREA.has_point(tile_pos): return
	match mode_index:
		Mode.FLOOR:
			place_floor(tile_pos)
		_:
			place_object(tile_pos)

func remove_tile() -> void:
	var tile_pos : Vector2 = board.world_to_map(get_global_mouse_position())
	if not EDITABLE_AREA.has_point(tile_pos): return
	match mode_index:
		Mode.FLOOR:
			remove_floor(tile_pos)
		_:
			delete_object(tile_pos)

func clear_level() -> void:
	# Make EVERYTHING a wall!
	for x in range(EDITABLE_AREA.position.x - 2, EDITABLE_AREA.position.x + EDITABLE_AREA.size.x + 2):
		for y in range(EDITABLE_AREA.position.y - 2, EDITABLE_AREA.position.y + EDITABLE_AREA.size.y + 2):
			board.set_cell(x, y, 0)
	board.update_bitmask_region()
	# Get rid of all the objects
	for object in get_tree().get_nodes_in_group("board_object"):
		object.queue_free()
	flower_index = 0

func shift_tiles(direction : Vector2) -> void:
	var temp_map = board.duplicate()
	for x in range(EDITABLE_AREA.position.x, EDITABLE_AREA.position.x + EDITABLE_AREA.size.x):
		for y in range(EDITABLE_AREA.position.y, EDITABLE_AREA.position.y + EDITABLE_AREA.size.y):
			board.set_cell(x, y, 0)
	for coord in temp_map.get_used_cells():
		var tile = temp_map.get_cellv(coord)
		coord += direction
		board.set_cellv(coord, tile)
	board.update_bitmask_region()
	# Now shift the objects themselves
	for object in get_tree().get_nodes_in_group("board_object"):
		object.board_position += direction
		object.refresh_on_board()

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if WAITING_FOR_LABEL:
			hide_messages()
			return
		if not unsaved:
			Overlay.transition_out()
			SoundMaster.change_layer(0)
			get_tree().get_root().set_disable_input(true)
			yield(Overlay, "transition_finished")
			Levels.currently_editing = false
			get_tree().get_root().set_disable_input(false)
			get_tree().change_scene("res://scenes/TitleScreen.tscn")
		else:
			confirm_menu = OBJ_MENU.instance()
			confirm_menu.items = {
				"yes_no": {
					"type":"menu",
					"children":[
						"no",
						"yes"
					]
				},
				"yes":{
					"type":"button",
					"label":"Yep!"
				},
				"no":{
					"type":"button",
					"label":"No!"
				}
			}
			confirm_menu.current_item = "yes_no"
			#menu_container.rect_scale = Vector2(0.5, 0.5)
			menu_container.add_child(confirm_menu)
			confirm_open = true
			confirm_menu.connect("button_pressed", self, "_on_Confirm_button_pressed")
			confirm_menu.connect("back_from_root", self, "_on_Confirm_back_from_root")
			update()
			
		update()
	if WAITING_FOR_LABEL: return
	# If we're looking at the help menu, don't process any other inputs
	if event.is_action_pressed("level_editor_help"):
		show_help = !show_help
		update()
	if show_help:
		return
	# Current "unsaved" system is a PROTOTYPE!
	# TODO: Make "unsaved" system efficient
	if event.is_action_pressed("move_up"):
		shift_tiles(Vector2.UP)
		unsaved = true
	if event.is_action_pressed("move_down"):
		shift_tiles(Vector2.DOWN)
		unsaved = true
	if event.is_action_pressed("move_left"):
		shift_tiles(Vector2.LEFT)
		unsaved = true
	if event.is_action_pressed("move_right"):
		shift_tiles(Vector2.RIGHT)
		unsaved = true
	if event.is_action_pressed("level_editor_change_object"):
		change_object()
		unsaved = true
	if event.is_action_pressed("level_editor_change_object_alt"):
		change_object_alt()
		unsaved = true
	if event.is_action_pressed("level_editor_next_mode"):
		mode_index += 1
		if mode_index >= Mode.size():
			mode_index = 0
		mode_index_offset = 16.0
	if event.is_action_pressed("level_editor_previous_mode"):
		mode_index -= 1
		if mode_index < 0:
			mode_index = Mode.size() - 1
		mode_index_offset = -16.0
	if event.is_action_pressed("level_editor_toggle_grid"):
		show_grid = !show_grid
	if event.is_action_pressed("level_editor_save"):
		if OS.has_feature("web"): return
		var json = board.level_to_json()
		SAVING = true
		FILELOADED = false
		ERROR = false
		WAITING_FOR_LABEL = false
		msg_timeout.start()
		update()
		# Quicksave local level file
		unsaved = false
		if OS.has_feature("editor"):
			Leveljson.open("res://Level.json", File.WRITE)
		elif OS.has_feature("release"): 
			Leveljson.open(OS.get_executable_path().get_base_dir() + "/Level.json", File.WRITE)
		Leveljson.store_string(JSON.print(json))
		Leveljson.close()
	if event.is_action_pressed("level_editor_load"):
		if OS.has_feature("web"):
			return
		elif OS.has_feature("editor"):
			Leveljson.open("res://Level.json", File.READ)
		elif OS.has_feature("release"): 
			Leveljson.open(OS.get_executable_path().get_base_dir() + "/Level.json", File.READ)
		var json = parse_json(Leveljson.get_as_text())
		if json != null:
			load_data_from_file(json)
	if event.is_action_pressed("level_editor_play"):
		Levels.editing_level = board.level_to_json()
		get_tree().change_scene("res://scenes/LevelTester.tscn")
	if event.is_action_pressed("level_editor_clear"):
		clear_level()
		unsaved = true
	if event.is_action_pressed("level_editor_change_settings"):
		settings_menu = OBJ_MENU.instance()
		settings_menu.items = {
			"settings": {
				"type":"menu",
				"children":[
					"episode",
					"season",
					"joke",
					"time",
					"par",
					"background",
					"camera_x",
					"camera_y",
					"back"
				]
			},
			"episode": {
				"type":"variable",
				"label": "Episode #",
				"variable_name": "episode"
			},
			"season": {
				"type":"variable",
				"label": "Season #",
				"variable_name": "season"
			},
			"title": {
				# I need to make a new type, and it needs to be text input >~<
				# Bag that noise if someone's making levels they can open notepad.
				# Or if someone wants to maybe make their own version of the "text" variable? Get on it, mod modders!
				# FRICK I STILL NEED TO MAKE THE NUMBERS THING FOr PAR FFFFFFFFFFF
				# Screw it I just made it a select from 1 to 99
				"type":"variable",
				"label": "Title",
				"variable_name": "title"
			},
			"subtitle": {
				"type":"variable",
				"label": "Subtitle",
				"variable_name": "subtitle"
			},
			"joke": {
				"type":"variable",
				"label": "Joke Level",
				"variable_name": "joke"
			},
			"time": {
				"type":"variable",
				"label": "Time Level",
				"variable_name": "time"
			},
			"par": {
				"type":"variable",
				"label": "Par",
				"variable_name": "par"
			},
			"camera_x": {
				"type":"variable",
				"label": "Camera Offset X",
				"variable_name": "camera_x"
			},
			"camera_y": {
				"type":"variable",
				"label": "Camera Offset Y",
				"variable_name": "camera_y"
			},
			"background": {
				"type":"variable",
				"label": "Background",
				"variable_name": "current_bg"
			},
			"back": {
				"type": "button",
				"label": "Close"
			}
		}
		settings_menu.variables = {
			"episode": {"type": "select", "options":["1","2","3","4","5","6","7"], "value": board.episode},
			"season": {"type": "select", "options":["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32"], "value": board.season},
			"title": {"type": "text", "value": board.title},
			"subtitle": {"type": "text", "value": board.subtitle},
			"joke": {"type": "tickbox", "value": board.joke},
			"time": {"type": "tickbox", "value": board.time},
			# There are no laws
			"par": {"type": "select", "options":["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "63", "64", "65", "66", "67", "68", "69", "70", "71", "72", "73", "74", "75", "76", "77", "78", "79", "80", "81", "82", "83", "84", "85", "86", "87", "88", "89", "90", "91", "92", "93", "94", "95", "96", "97", "98", "99"], "value": board.par},
			"camera_x": {"type": "select", "options":["-0.5","0","0.5"], "value": board.camera_offset_x},
			"camera_y": {"type": "select", "options":["-0.5","0","0.5"], "value": board.camera_offset_y},
			"current_bg": {"type": "select", "options": ["Squares", "Chevrons", "Diamonds", "Mines", "Clusters", "Worms", "Wavy", "Wavy alt.", "Wonk", "Lines", "Plane", "Flag", "None"], "value": board.current_bg},
		}
		settings_menu.current_item = "settings"
		#settings_menu.rect_scale = Vector2(0.5, 0.5)
		menu_container.add_child(settings_menu)
		settings_menu.resize()
		settings_menu.connect("variable_changed", self, "_on_Menu_variable_changed")
		settings_menu.connect("back_from_root", self, "_on_Menu_back_from_root")
			
	if event.is_action_pressed("level_editor_export_encode"):
		var img = json_to_png(JSON.print(board.level_to_json()))
		if OS.has_feature("editor"):
			img.save_png("s" + String(board.season + 1) + "e" + String(board.episode + 1) + ".png")
		if OS.has_feature("release"):
			img.save_png(OS.get_executable_path().get_base_dir() + "/s" + String(board.season + 1) + "e" + String(board.episode + 1) + ".png")
	if event.is_action_pressed("level_editor_export_cart"):
		WAITING_FOR_LABEL = true
		FILELOADED = false
		SAVING = false
		ERROR = false
		msg_timeout.start()
		update()


func json_to_png(input : String) -> Image:
	#var width : int = 1
	#var height : int = 1
	#var bytes : PoolByteArray = [00000000]
	#bytes.append_array(input.to_ascii())
	#var bytes : PoolByteArray
	#for x in input.to_ascii():
	#	bytes.append(x)
	var bytes : PoolByteArray = input.to_ascii()
	var max_width : int = bytes.size() + bytes.size() % 3
	var img : Image = Image.new()
	var width : int = max_width/3
	var height : int = 1
	while width > height * 1.5:
		width = ceil(float(width) / 2)
		height *= 2
	while width*height - bytes.size()/3 > 0:
		bytes.append(00000000) 
	img.create_from_data(width, height, false, Image.FORMAT_RGB8, bytes)
	return img

func png_to_json(img : Image) -> String:
	img.lock()
	var bytes : PoolByteArray = PoolByteArray()
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			var c : Color = img.get_pixel(x, y)
			bytes.append_array([c.r8, c.g8, c.b8])
	img.unlock()
	return bytes.get_string_from_ascii()

func cart_to_json(cart : Image):
	var bytes : PoolByteArray = cart.get_data()
	var data : PoolByteArray = PoolByteArray([])
	
	cart.lock()
	var starting_height : int = 0
	for y in range(cart.get_height()):
		var done = false
		for x in range(cart.get_width()):
			var c : Color = cart.get_pixel(x, y)
			if (c.r8 + c.g8 + c.b8) > 0:
				starting_height += c.r8 + c.g8 + c.b8
			else:
				done = true
				break
		if done: break

	for y in range(starting_height, cart.get_height()):
		for x in range(cart.get_width()):
			var c : Color = cart.get_pixel(x, y)
			data.append_array([c.r8, c.g8, c.b8])
	cart.unlock()
	return data.get_string_from_ascii()

func png_to_cart(label : Image, data : String):
	label.convert(Image.FORMAT_RGB8)
	var bytes : PoolByteArray = label.get_data()
	var level_data : PoolByteArray = data.to_ascii()
	bytes.append_array(level_data)
	var pointer : PoolByteArray = []
	var remaining_height = label.get_height()
	while remaining_height > 0:
		pointer.append(min(remaining_height, 255))
		remaining_height -= min(remaining_height, 255)
	while pointer.size() % 3 != 0:
		pointer.append(0)
	for _x in range(2):
		pointer.append(0)
	for _x in range(pointer.size()):
		bytes.remove(0)
	pointer.append_array(bytes)
	# lol
	bytes = pointer
	
	var min_width = label.get_width()
	var width : int = min_width
	var min_height : int = label.get_height()
	var height : int = min_height
	height += ceil((level_data.size()/3) / width)
	while (width*height) < bytes.size()/3:
		height += 1
	while (width*height) > bytes.size()/3:
		bytes.append(00000000)
	var cart = Image.new()
	cart.create_from_data(width, height, false, Image.FORMAT_RGB8, bytes)
	return cart


func _on_Confirm_button_pressed(slug : String) -> void:
	match slug:
		"yes":
			Overlay.transition_out()
			SoundMaster.change_layer(0)
			get_tree().get_root().set_disable_input(true)
			yield(Overlay, "transition_finished")
			get_tree().get_root().set_disable_input(false)
			Levels.currently_editing = false
			get_tree().change_scene("res://scenes/TitleScreen.tscn")
		_:
			confirm_menu.items = {}
			yield(get_tree().create_timer(0.1), "timeout")
			confirm_menu.queue_free()
			confirm_open = false
	update()

func _on_Confirm_back_from_root() -> void:
	confirm_menu.active = false
	confirm_menu.items = {}
	yield(get_tree().create_timer(0.1), "timeout")
	confirm_menu.queue_free()
	confirm_open = false
	update()

func _on_Menu_back_from_root() -> void:
	settings_menu.items = {}
	yield(get_tree().create_timer(0.1), "timeout")
	if settings_menu != null:
		settings_menu.queue_free()

func _on_Menu_variable_changed(variable_name : String) -> void:
	board.episode = settings_menu.variables["episode"]["value"]
	board.season = settings_menu.variables["season"]["value"]
	board.title = settings_menu.variables["title"]["value"]
	board.subtitle = settings_menu.variables["subtitle"]["value"]
	board.joke = settings_menu.variables["joke"]["value"]
	board.time = settings_menu.variables["time"]["value"]
	board.par = settings_menu.variables["par"]["value"]
	board.camera_offset_x = settings_menu.variables["camera_x"]["value"]
	board.camera_offset_y = settings_menu.variables["camera_y"]["value"]
	board.current_bg = settings_menu.variables["current_bg"]["value"]
	unsaved = true

func _process(delta : float) -> void:
	# If we're looking at the help menu, don't do any of this
	if show_help or WAITING_FOR_LABEL:
		return
		
	if Input.is_action_pressed("level_editor_place"):
		place_tile()
		unsaved = true
	if Input.is_action_pressed("level_editor_remove"):
		remove_tile()
		unsaved = true
		
	mode_index_offset = lerp(mode_index_offset, 0.0, delta * 15.0)
	
	label_a_text = ""
	label_b_text = ""
	var object_info = find_object_to_change()
	for tooltip_key in object_tooltips:
		if object_info is tooltip_key:
			var info : Array = object_tooltips[tooltip_key]
			label_a_text = info[0]
			label_b_text = info[1]

	update()

#do. not. touch.
func get_level_file(files: PoolStringArray, from_screen: int) -> void:
	var file = File.new()
	file.open(files[0], File.READ)
	if not WAITING_FOR_LABEL:
		if ".json" in files[0] or ".tres" in files[0]:
			var json = parse_json(file.get_as_text())
			if json != null:
				load_data_from_file(json)
			else:
				err_message = "The data is not formatted correctly"
				ERROR = true
				FILELOADED = false
				SAVING = false
				WAITING_FOR_LABEL = false
				msg_timeout.start()
				update()
		elif ".png" in file.get_path_absolute():
			# i'm going to commit a waR CRIME
			var source : Image = Image.new()
			source.load(files[0])
			source.lock()
			var json = null
			if ".cart" in file.get_path_absolute():
				json = parse_json(cart_to_json(source))
			else:
				json = parse_json(png_to_json(source))
			if json != null:
				load_data_from_file(json)
			else:
				err_message = "The data is not formatted correctly"
				ERROR = true
				FILELOADED = false
				SAVING = false
				ERROR = false
				WAITING_FOR_LABEL = false
				msg_timeout.start()
				update()
	else:
		if ".png" in file.get_path_absolute():
			cart_label = Image.new()
			cart_label.load(files[0])
			var img = png_to_cart(cart_label, JSON.print(board.level_to_json()))
			if OS.has_feature("editor"):
				img.save_png("s" + String(board.season + 1) + "e" + String(board.episode + 1) + ".cart.png")
			if OS.has_feature("release") or (OS.has_feature("debug") and not OS.has_feature("editor")):
				img.save_png(OS.get_executable_path().get_base_dir() + "/s" + String(board.season + 1) + "e" + String(board.episode + 1) + ".cart.png")
			WAITING_FOR_LABEL = false
			

func load_data_from_file(json) -> void:
	# oops, ur data is fricked up, soz
	if typeof(json) != TYPE_DICTIONARY:
		err_message = "The data is not formatted correctly"
		ERROR = true
		FILELOADED = false
		SAVING = false
		WAITING_FOR_LABEL = false
		msg_timeout.start()
		update()
		return
	if not ("variables" in json and "title" in json and "subtitle" in json and "flags" in json and "par" in json and "camera_offset" in json):
		err_message = "The data is not formatted correctly"
		ERROR = true
		FILELOADED = false
		SAVING = false
		WAITING_FOR_LABEL = false
		msg_timeout.start()
		update()
		return
	get_tree().call_group("board_object", "queue_free")
	loader.load_level(json)
	flower_index = get_tree().get_nodes_in_group("flower").size()
	board.episode = json["variables"]["episode"] if json.has("variables") else 0
	board.season = json["variables"]["season"] if json.has("variables") else 0
	board.title = json["title"]
	board.subtitle = json["subtitle"]
	board.joke = json["flags"]["joke"] if json.has("flags") else false
	board.time = json["flags"]["time"] if json.has("flags") else false
	board.par = json["par"]
	board.camera_offset_x = (json["camera_offset"][0]*2)+1
	board.camera_offset_y = (json["camera_offset"][1]*2)+1
	board.camera_offset = Vector2.ZERO
	board.current_bg = BACKGROUNDS.find(json["background"])
	board.tutorial = json["tutorial"] if json.has("tutorial") else {}
	FILELOADED = true
	SAVING = false
	ERROR = false
	WAITING_FOR_LABEL = false
	msg_timeout.start()
	update()

func hide_messages() -> void:
	# there are A MILLION better ways to do this, I'm just too lazy to setget or w/e
	FILELOADED = false
	SAVING = false
	ERROR = false
	WAITING_FOR_LABEL = false
	err_message = ""
	update()

func _ready() -> void:
	
	#DO. NOT. TOUCH.
	msg_timeout.connect("timeout", self, "hide_messages")
	get_tree().connect("files_dropped", self, "get_level_file")
	#ok touchy here
	Levels.currently_editing = true
	Levels.current_scene = ""
	clear_level()
	if Levels.editing_level != null:
		loader.load_level(Levels.editing_level)
		flower_index = get_tree().get_nodes_in_group("flower").size()
		board.episode = int(Levels.editing_level["variables"]["episode"])
		board.season = int(Levels.editing_level["variables"]["season"])
		board.title = Levels.editing_level["title"]
		board.subtitle = Levels.editing_level["subtitle"]
		board.joke = Levels.editing_level["flags"]["joke"]
		board.time = Levels.editing_level["flags"]["time"]
		board.par = Levels.editing_level["par"]-1
		board.camera_offset_x = (Levels.editing_level["camera_offset"][0]*2)+1
		board.camera_offset_y = (Levels.editing_level["camera_offset"][1]*2)+1
		board.current_bg = BACKGROUNDS.find(Levels.editing_level["background"])
		board.camera_offset = Vector2.ZERO
		board.tutorial = Levels.editing_level["tutorial"]
	Overlay.transition_in()
