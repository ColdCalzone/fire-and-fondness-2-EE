extends Control

onready var menu = $Center/Menu
onready var logo = $Logo
onready var copyright = $Label_Copyright
onready var subtitle = $CenterSubtitle/Subtitle
onready var mod = $Label_Mod
onready var credits = $Credits

# backgrounds
const BACKGROUNDS = [
	preload("res://objects/backgrounds/Squares.tscn"),
	preload("res://objects/backgrounds/Chevrons.tscn"),
	preload("res://objects/backgrounds/Diamonds.tscn"),
	preload("res://objects/backgrounds/Mines.tscn"),
	preload("res://objects/backgrounds/Cluster.tscn"),
	preload("res://objects/backgrounds/Worms.tscn"),
	preload("res://objects/backgrounds/Wavy.tscn"),
	preload("res://objects/backgrounds/Wavy_Alt.tscn"),
	preload("res://objects/backgrounds/Wonks.tscn"),
	preload("res://objects/backgrounds/Lines.tscn"),
	preload("res://objects/backgrounds/Wavy_Plane.tscn"),
	preload("res://objects/backgrounds/Flag.tscn")
]

onready var overlay = preload("res://objects/Scanline_Overlay.tscn")
var overlay_node 
onready var active = true

func _ready() -> void:
	# Woah a secret! This is why source release was pushed back btw :p
	get_tree().connect("files_dropped", self, "handle_files")
	randomize()
	var file = File.new()
	if file.file_exists(OS.get_executable_path().get_base_dir() + "/mods/manifest.tres"):
		file.open(OS.get_executable_path().get_base_dir() + "/mods/manifest.tres", File.READ)
		var manifest = JSON.parse(file.get_as_text()).result
		subtitle.text = manifest["subtitles"][randi() % manifest["subtitles"].size()]
		mod.text = manifest["pack_name"] + " " + manifest["version"]
	menu.items = {
		"main_menu": {
			"type": "menu",
			"children": ["play", "settings", "credits", "edit", "quit"]
		},
		"edit": {
			"type": "button",
			"label": "Edit"
		},
		"play": {
			"type": "button",
			"label": "Play"
		},
		"mods": {
			"type": "button",
			"label": "Mods"
		},
		"settings": {
			"label": "Settings",
			"type": "menu",
			"children": ["game", "video", "audio", "back"],
			"parent": "main_menu"
		},
		"game": {
			"label": "Game",
			"type": "menu",
			"children": ["player_avatar", "partner_avatar", "show_ui", "skip_tutorials", "data", "classic_mode", "back"],
			"parent": "settings"
		},
		"data": {
			"label": "Data Management",
			"type": "menu",
			"children": ["reset_save", "back"],
			"parent": "game"
		},
		"reset_save": {
			"label": "Reset Save",
			"type" : "menu",
			"children": ["data_warn", "reset_confirm", "back"],
			"parent": "data"
		},
		"data_warn": {
			"label": "This cannot be undone!",
			"type" : "warn"
		},
		"reset_confirm": {
			"label": "Erase my save",
			"type": "button"
		},
		"classic_settings": {
			"label": "Shader Settings",
			"type": "menu",
			"children": ["use_scan", "screen_warp", "use_shader_glow", "back"],
			"parent": "game"
		},
		"show_ui": {
			"label": "Show UI",
			"type": "variable",
			"variable_name": "show_ui"
		},
		"classic_mode": {
			"label": "Classic Mode",
			"type": "variable",
			"variable_name": "classic_mode"
		},
		"use_scan": {
			"label": "Show Scanlines",
			"type": "variable",
			"variable_name": "use_scan"
		},
		"screen_warp": {
			"label": "Screen warp",
			"type": "variable",
			"variable_name": "screen_warp"
		},
		"use_shader_glow": {
			"label": "Glow",
			"type": "variable",
			"variable_name": "use_shader_glow"
		},
		"skip_tutorials": {
			"label": "Skip Tutorials",
			"type": "variable",
			"variable_name": "skip_tutorials"
		},
		"player_avatar": {
			"label": "Player Avatar",
			"type": "variable",
			"variable_name": "player_avatar"
		},
		"partner_avatar": {
			"label": "Partner Avatar",
			"type": "variable",
			"variable_name": "partner_avatar"
		},
		"video": {
			"label": "Video",
			"type": "menu",
			"children": ["backgrounds", "fullscreen", "screen_scale", "camera_shake", "bg_bloodying", "colour_blind_assist", "show_cursor", "back"],
			"parent": "settings"
		},
		"fullscreen": {
			"label": "Fullscreen",
			"type": "variable",
			"variable_name": "fullscreen"
		},
		"show_cursor": {
			"label": "Show Mouse Cursor",
			"type": "variable",
			"variable_name": "show_cursor"
		},
		"screen_scale": {
			"label": "Screen Scale",
			"type": "variable",
			"variable_name": "screen_scale"
		},
		"camera_shake": {
			"label": "Camera Shake",
			"type": "variable",
			"variable_name": "camera_shake"
		},
		"colour_blind_assist": {
			"label": "Colour Blind Assist",
			"type": "variable",
			"variable_name": "colour_blind_assist"
		},
		"backgrounds": {
			"label": "Backgrounds",
			"type": "menu",
			"children": ["background_enabled", "background_palette", "background_speed", "current_bg", "back"],
			"parent": "video"
		},
		"background_enabled": {
			"label": "BG Enabled",
			"type": "variable",
			"variable_name": "background_enabled"
		},
		"background_palette": {
			"label": "BG Palette",
			"type": "variable",
			"variable_name": "background_palette"
		},
		"background_speed": {
			"label": "BG Speed",
			"type": "variable",
			"variable_name": "background_speed"
		},
		"current_bg": {
			"label": "Title BG",
			"type": "variable",
			"variable_name": "current_bg"
		},
		"bg_bloodying": {
			"label": "BG Difficulty",
			"type": "variable",
			"variable_name": "bg_bloodying"
		},
		"audio": {
			"label": "Audio",
			"type": "menu",
			"children": ["sfx_volume", "bgm_volume", "ui_volume", "back"],
			"parent": "settings"
		},
		"sfx_volume": {
			"label": "SFX",
			"type": "variable",
			"variable_name": "sfx_volume"
		},
		"bgm_volume": {
			"label": "Music",
			"type": "variable",
			"variable_name": "bgm_volume"
		},
		"ui_volume": {
			"label": "UI",
			"type": "variable",
			"variable_name": "ui_volume"
		},
		"credits": {
			"type": "button",
			"label": "Credits"
		},
		"quit": {
			"type": "button",
			"label": "Quit"
		},
		"back": {
			"type": "button",
			"label": "Back"
		}
	}
	menu.variables = {
		"skip_tutorials": {"type": "tickbox", "value": Settings.skip_tutorials},
		"show_ui": {"type": "tickbox", "value": Settings.show_ui},
		"classic_mode": {"type": "tickbox", "value": Settings.classic_mode},
		"use_scan": {"type": "tickbox", "value": Settings.use_scan},
		"screen_warp": {"type": "tickbox", "value": Settings.screen_warp},
		"use_shader_glow": {"type": "tickbox", "value": Settings.use_shader_glow},
		"colour_blind_assist": {"type": "select", "options": ["None", "Palette", "Flags"], "value": Settings.colour_blind_assist},
		"player_avatar": {"type": "avatar", "value": Settings.player_avatar},
		"partner_avatar": {"type": "avatar", "value": Settings.partner_avatar},
		"fullscreen": {"type": "tickbox", "value": Settings.fullscreen},
		"show_cursor": {"type": "tickbox", "value": Settings.show_cursor},
		"screen_scale": {"type": "select", "options": ["1x", "2x", "3x", "4x"], "value": Settings.screen_scale},
		"camera_shake": {"type": "select", "options": ["None", "Subtle", "Intense", "Extreme", "Silly", "Too Much", "Unreasonable", "Death"], "value": Settings.camera_shake},
		"background_enabled": {"type": "tickbox", "value": Settings.background_enabled},
		"background_palette": {"type": "select", "options": ["Muted", "Fiery", "Earthy", "Envious", "Aquatic", "Ace", "Aro", "Trans", "Non Binary", "Lesbian", "Demisexual", "Bisexual"], "value": Settings.background_palette},
		"background_speed": {"type": "select", "options": ["0.00x", "0.25x", "0.50x", "0.75x", "1.00x", "1.25x", "1.50x", "1.75x", "2.00x", "2.25x", "2.50x", "2.75x", "3.00x"], "value": Settings.background_speed},
		"current_bg": {"type": "select", "options": ["Squares", "Chevrons", "Diamonds", "Mines", "Clusters", "Worms", "Wavy", "Wavy alt.", "Wonk", "Lines", "Plane", "Flag"], "value": Settings.current_bg},
		"bg_bloodying": {"type": "tickbox", "value": Settings.bg_bloodying},
		"sfx_volume": {"type": "volume", "value": Settings.sfx_volume},
		"bgm_volume": {"type": "volume", "value": Settings.bgm_volume},
		"ui_volume": {"type": "volume", "value": Settings.ui_volume}
	}
	# If this is the web version, remove various desktop-only items
	if OS.has_feature("web"):	
		menu.items["main_menu"]["children"].remove(
			menu.items["main_menu"]["children"].find("quit")
		)
		for item in ["fullscreen", "screen_scale"]:
			menu.items["video"]["children"].remove(
				menu.items["video"]["children"].find(item)
			)
		for item in ["classic_mode"]:
			menu.items["game"]["children"].remove(
				menu.items["game"]["children"].find(item)
			)
	menu.current_item = "main_menu"
	menu.resize(true)
	Overlay.transition_in()
	credits.connect("close_credits", self, "close_credits")
	SoundMaster.change_layer_immediately(0)
	SoundMaster.play_title_music()
	var selected_bg = BACKGROUNDS[menu.variables["current_bg"]["value"]].instance()
	yield(get_tree().create_timer(0.01), "timeout")
	selected_bg.name = "Background"
	if menu.variables["current_bg"]["value"] == 1 or menu.variables["current_bg"]["value"] == 2:
			selected_bg.set_scale(Vector2(2,2))
	add_child(selected_bg, true)
	menu.items["game"]["children"] = ["player_avatar", "partner_avatar", "show_ui", "skip_tutorials", "data", "classic_mode", "classic_settings", "back"] if menu.variables["classic_mode"]["value"] else ["player_avatar", "partner_avatar", "show_ui", "skip_tutorials", "data", "classic_mode", "back"]
	overlay_node = overlay.instance()
	overlay_node.get_material().set_shader_param("apply_shader", Settings.classic_mode)
	overlay_node.get_material().set_shader_param("scanlines", Settings.use_scan)
	overlay_node.get_material().set_shader_param("screen_warp", Settings.screen_warp)
	overlay_node.get_material().set_shader_param("glow", Settings.use_shader_glow)
	add_child(overlay_node, true)
	overlay_node.visible = Settings.classic_mode


func _on_Menu_variable_changed(variable_name : String) -> void:
	Settings.skip_tutorials = menu.variables["skip_tutorials"]["value"]
	Settings.show_ui = menu.variables["show_ui"]["value"]
	Settings.classic_mode = menu.variables["classic_mode"]["value"]
	Settings.player_avatar = menu.variables["player_avatar"]["value"]
	Settings.partner_avatar = menu.variables["partner_avatar"]["value"]
	Settings.colour_blind_assist = menu.variables["colour_blind_assist"]["value"]
	Settings.fullscreen = menu.variables["fullscreen"]["value"]
	Settings.show_cursor = menu.variables["show_cursor"]["value"]
	Settings.background_enabled = menu.variables["background_enabled"]["value"]
	Settings.background_speed = menu.variables["background_speed"]["value"]
	Settings.background_palette = menu.variables["background_palette"]["value"]
	Settings.current_bg = menu.variables["current_bg"]["value"]
	Settings.screen_warp = menu.variables["screen_warp"]["value"]
	Settings.use_shader_glow = menu.variables["use_shader_glow"]["value"]
	Settings.use_scan = menu.variables["use_scan"]["value"]
	#I kinda hate this but I need to do this to update junk
	if variable_name == "current_bg":
		get_node("Background").queue_free()
		var selected_bg = BACKGROUNDS[menu.variables["current_bg"]["value"]].instance()
		menu.active = false
		#this is the worst
		yield(get_tree().create_timer(0.001), "timeout")
		menu.active = true
		selected_bg.name = "Background"
		if menu.variables["current_bg"]["value"] == 1 or menu.variables["current_bg"]["value"] == 2:
			selected_bg.set_scale(Vector2(2, 2))
		add_child(selected_bg, true)
	if variable_name == "classic_mode":
		menu.items["game"]["children"] = ["player_avatar", "partner_avatar", "show_ui", "skip_tutorials", "data", "classic_mode", "classic_settings", "back"] if menu.variables["classic_mode"]["value"] else ["player_avatar", "partner_avatar", "show_ui", "skip_tutorials", "data", "classic_mode", "back"]
		overlay_node.visible = Settings.classic_mode
	overlay_node.get_material().set_shader_param("apply_shader", Settings.classic_mode)
	overlay_node.get_material().set_shader_param("scanlines", Settings.use_scan)
	overlay_node.get_material().set_shader_param("screen_warp", Settings.screen_warp)
	overlay_node.get_material().set_shader_param("glow", Settings.use_shader_glow)
	#back to your regularly scheduled programming
	Settings.bg_bloodying = menu.variables["bg_bloodying"]["value"]
	Settings.screen_scale = menu.variables["screen_scale"]["value"]
	Settings.camera_shake = menu.variables["camera_shake"]["value"]
	Settings.sfx_volume = menu.variables["sfx_volume"]["value"]
	Settings.bgm_volume = menu.variables["bgm_volume"]["value"]
	Settings.ui_volume = menu.variables["ui_volume"]["value"]
	Settings.apply_config()
	Settings.save_config()

func start_game() -> void:
	if GameProgress.new_game:
		Levels.new_game()
	else:
		get_tree().change_scene("res://scenes/LevelSelect.tscn")

func open_editor() -> void:
	get_tree().change_scene("res://scenes/LevelEditor.tscn")

func open_credits() -> void:
	logo.hide()
	menu.hide()
	copyright.hide()
	credits.show()
	menu.active = false

func close_credits() -> void:
	logo.show()
	menu.show()
	menu.current_child = 0
	menu.move_cursor()
	copyright.show()
	credits.hide()
	menu.active = true

func _on_Menu_button_pressed(slug : String) -> void:
	match slug:
		"play":
			menu.active = false
			if GameProgress.new_game:
				SoundMaster.fade_out_music()
			else:
				SoundMaster.change_layer(1)
			Overlay.transition_out()
			yield(Overlay, "transition_finished")
			start_game()
		"mods":
			menu.active = false
			if GameProgress.new_game:
				SoundMaster.fade_out_music()
			else:
				SoundMaster.change_layer(1)
			Overlay.transition_out()
			yield(Overlay, "transition_finished")
			start_game()
		"credits":
			open_credits()
		"quit":
			menu.active = false
			Overlay.transition_out()
			yield(Overlay, "transition_finished")
			get_tree().quit()
		"edit":
			menu.active = false
			Overlay.transition_out()
			SoundMaster.change_layer(1)
			yield(Overlay, "transition_finished")
			open_editor()
		"reset_confirm":
			menu.active = false
			Overlay.transition_out()
			GameProgress.new_game()
			SoundMaster.fade_out_music()
			yield(Overlay, "transition_finished")
			get_tree().change_scene("res://scenes/TitleScreen.tscn")

func dir_contents(path):
	var files : Array = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true)
		var file_name = dir.get_next()
		while file_name != "":
			files.append(path + "/" + file_name)
			file_name = dir.get_next()
		return files
	else:
		print("An error occurred when trying to access the path.")

func handle_files(files : PoolStringArray, _screen : int):
	#var file = File.new()
	#file.open(files[0], File.READ)
	var image = Image.new()
	image.load(files[0])
	var data : Dictionary = cart_to_json(image)
	var dir_thingy : Directory = Directory.new()
	for x in data.keys():
		var file = File.new()
		if x.rsplit("/", true, 1)[0] == "mods":
			file.open(OS.get_executable_path().get_base_dir() + "/" + x, File.WRITE)
		else:
			if not dir_thingy.dir_exists(OS.get_executable_path().get_base_dir() + "/mods/" + x.rsplit("/", true, 1)[0]):
				dir_thingy.make_dir(OS.get_executable_path().get_base_dir() + "/mods/" + x.rsplit("/", true, 1)[0])
			file.open(OS.get_executable_path().get_base_dir() + "/mods/" + x, File.WRITE)
		file.store_string(data[x])
		file.close()
	yield(get_tree().create_timer(2), "timeout")
	get_tree().quit(0)

# Yoink! @LevelEditor.gd: line 637
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
	var dictionary_of_contents : Dictionary = {}
	# PoolByteArray([00000028]).get_string_from_ascii() is a neat control character I found with no use
	#so I yoinked it for my own.
	var data_ascii : Array = data.get_string_from_ascii().split(PoolByteArray([00000028]).get_string_from_ascii())
	for i in range(data_ascii.size()/2):
		dictionary_of_contents[data_ascii[i*2]] = data_ascii[(i*2)+1]
	return dictionary_of_contents
