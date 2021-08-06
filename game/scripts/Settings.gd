extends Node

const CONFIG_PATH : String = "user://settings.cfg"

const PALETTE_MUTED : Array = [Color("222034"), Color("45283c"), Color("3f3f74")]
const PALETTE_FIERY : Array = [Color("222034"), Color("df7126"), Color("ac3232")]
const PALETTE_EARTHY : Array = [Color("45283c"), Color("663931"), Color("8f563b")]
const PALETTE_ENVIOUS : Array = [Color("524b24"), Color("4b692f"), Color("37946e")]
const PALETTE_BLOODY : Array = [Color("A11213"), Color("A11213"), Color("A11213")]

#made from colorhunt.co
const PALETTE_AQUATIC : Array = [Color("086972"), Color("071a52"), Color("17b978")]


#Pride colors :)
const PALETTE_ACE : Array = [Color("a3a3a3"), Color("800080"), Color("7d7d7d")]
const PALETTE_ARO : Array = [Color("3da53d"), Color("a9a9a9"), Color("7d7d7d")]
const PALETTE_TRANS : Array = [Color("3d95b8"), Color("d68797"), Color("a9a9a9")]
const PALETTE_NB : Array = [Color("cfc629"), Color("a9a9a9"), Color("9b59d0")]
const PALETTE_LESBIAN : Array = [Color("d62e02"), Color("a20160"), Color("a9a9a9")]
const PALETTE_DEMI : Array = [Color("a3a3a3"), Color("800080"), Color("4f4f4f")]
const PALETTE_BI : Array = [Color("D60270"), Color("9B4F96"), Color("0038A8")]


enum COLOUR_BLIND_ASSIST {NONE, PALETTE, INDICATORS}

var fullscreen : bool
var show_cursor : bool
var screen_scale : int
var camera_shake : int
var background_enabled : bool
var background_palette : int
var background_speed : int
var current_bg : int
var bg_bloodying : bool
var sfx_volume : float
var bgm_volume : float
var ui_volume : float
var player_avatar : int
var partner_avatar : int
var skip_tutorials : bool
var show_ui : bool
var colour_blind_assist : int
var classic_mode : bool
var use_scan : bool
var screen_warp : bool
var use_shader_glow : bool

var config : ConfigFile

func get_camera_shake_amount() -> float:
	match camera_shake:
		1: return 4.0
		2: return 8.0
		3: return 16.0
		4: return 32.0
		5: return 64.0
		6: return 128.0
		7: return 512.0
		_: return 0.0

func get_background_speed_amount() -> float:
	return background_speed * 0.25
	
func get_current_bg() -> int:
	return current_bg

func get_bg_bloodying() -> bool:
	return bg_bloodying

func get_background_colours() -> Array:
	match background_palette:
		1: return PALETTE_FIERY
		2: return PALETTE_EARTHY
		3: return PALETTE_ENVIOUS
		4: return PALETTE_AQUATIC
		5: return PALETTE_ACE
		6: return PALETTE_ARO
		7: return PALETTE_TRANS
		8: return PALETTE_NB
		9: return PALETTE_LESBIAN
		#it be a me
		10: return PALETTE_DEMI
		11: return PALETTE_BI
		_: return PALETTE_MUTED
		

func apply_config() -> void:
	if not OS.has_feature("web"):
		# Turns out linux doesn't jive with this here, I'm fixing it up
		#OS.window_fullscreen = fullscreen
		#OS.window_size = Vector2(640, 360) * (screen_scale + 1)
		OS.window_fullscreen = fullscreen
		if not fullscreen:
			# Keep the window centered when changing scale 'n' stuff
			if OS.window_size != Vector2(640, 360) * (screen_scale +1):
				OS.window_size = Vector2(640, 360) * (screen_scale + 1)
				OS.center_window()
			else:
				OS.window_size = Vector2(640, 360) * (screen_scale + 1)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(sfx_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), linear2db(bgm_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("UI"), linear2db(ui_volume))
	if show_cursor:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func load_config() -> void:
	config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	if err == ERR_FILE_NOT_FOUND:
		err = config.save(CONFIG_PATH)
	if err == OK:
		player_avatar = config.get_value("game", "player_avatar", 0)
		partner_avatar = config.get_value("game", "partner_avatar", 1)
		show_ui = config.get_value("game", "show_ui", true)
		classic_mode = config.get_value("game", "classic_mode", false)
		use_scan = config.get_value("game", "use_scan", true)
		screen_warp = config.get_value("game", "screen_warp", true)
		use_shader_glow = config.get_value("game", "use_shader_glow", true)
		skip_tutorials = config.get_value("game", "skip_tutorials", false)
		colour_blind_assist = config.get_value("game", "colour_blind_assist", 0)
		fullscreen = config.get_value("graphics", "fullscreen", false)
		show_cursor = config.get_value("graphics", "show_cursor", false)
		screen_scale = config.get_value("graphics", "screen_scale", 1)
		camera_shake = config.get_value("graphics", "camera_shake", 2)
		background_enabled = config.get_value("graphics", "background_enabled", true)
		background_palette = config.get_value("graphics", "background_palette", 0)
		background_speed = config.get_value("graphics", "background_speed", 2)
		current_bg = config.get_value("graphics", "current_bg", 0)
		bg_bloodying = config.get_value("graphics", "bg_bloodying", true)
		sfx_volume = config.get_value("audio", "sfx_volume", 1.0)
		bgm_volume = config.get_value("audio", "bgm_volume", 0.5)
		ui_volume = config.get_value("audio", "ui_volume", 0.5)

func save_config() -> void:
	config.set_value("game", "player_avatar", player_avatar)
	config.set_value("game", "flower_appearence", null)
	config.set_value("game", "partner_avatar", partner_avatar)
	config.set_value("game", "show_ui", show_ui)
	config.set_value("game", "classic_mode", classic_mode)
	config.set_value("game", "use_scan", use_scan)
	config.set_value("game", "screen_warp", screen_warp)
	config.set_value("game", "use_shader_glow", use_shader_glow)
	config.set_value("game", "skip_tutorials", skip_tutorials)
	config.set_value("game", "colour_blind_assist", colour_blind_assist)
	config.set_value("graphics", "fullscreen", fullscreen)
	config.set_value("graphics", "show_cursor", show_cursor)
	config.set_value("graphics", "screen_scale", screen_scale)
	config.set_value("graphics", "camera_shake", camera_shake)
	config.set_value("graphics", "background_enabled", background_enabled)
	config.set_value("graphics", "background_palette", background_palette)
	config.set_value("graphics", "background_speed", background_speed)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "bgm_volume", bgm_volume)
	config.set_value("audio", "ui_volume", ui_volume)
	config.set_value("graphics", "current_bg", current_bg)
	config.set_value("graphics", "bg_bloodying", bg_bloodying)
	config.save(CONFIG_PATH)

func _enter_tree() -> void:
	load_config()
	yield(get_tree().create_timer(0.25), "timeout")
	apply_config()
	OS.center_window()
