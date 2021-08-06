extends Control

const FONT_BUTTON : Font = preload("res://fonts/paragraph_bold.tres")
const FONT_PARAGRAPH : Font = preload("res://fonts/paragraph.tres")
const SPRITE_TICKBOX = preload("res://sprites/ui/cursor.png")
const SPRITE_ICONS = preload("res://sprites/ui/icons.png")

const COLOR_SHADOW : Color = Color("222034")
const COLOR_SHADE_A : Color = Color("847e87")
const COLOR_SHADE_B : Color = Color("595652")
const WINDOW_WIDTH : float = 182.0

onready var tween := $Tween

var mods : bool = false

var selected_season : int = 0
var selected_level : int = 0
var levels : Array

var unlocked_levels : int
var unlocked_seasons : int
var completion_percentage : float

var offset : Vector2 = Vector2.ZERO
var cursor_offset : Vector2 = Vector2.ZERO
var time : float = 0.0
var active : bool = true

var foreground_bg

onready var backgrounds = [
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

var overlay = preload("res://objects/Scanline_Overlay.tscn")

func draw_text_with_shadow(font : Font, text : String, position : Vector2, color : Color) -> void:
	draw_string(font, position + Vector2(1, 1), text, COLOR_SHADOW)
	draw_string(font, position, text, color)

func draw_level(number : int, title : String, subtitle : String, best : int, par : int, position : Vector2, unlocked : bool, finished : bool, beat_par : bool, got_flowers : bool, multiple_flowers : bool, beaten : bool, is_current : bool) -> void:
	var color_title : Color = Color.white if is_current else COLOR_SHADE_A
	var color_subtitle : Color = COLOR_SHADE_A if is_current else COLOR_SHADE_B
	if not unlocked:
		draw_text_with_shadow(FONT_BUTTON, str(number) + ":", position + Vector2(-WINDOW_WIDTH, 0), COLOR_SHADE_B)
		draw_text_with_shadow(FONT_BUTTON, "Locked", position + Vector2(16.0 - WINDOW_WIDTH, 0), COLOR_SHADE_B)
		return
	var par_and_best : String
	if finished:
		par_and_best = "Best/par: %d/%d" % [best, par]
	else:
		par_and_best = "Par: %d" % par
	var width_title : float = FONT_BUTTON.get_string_size(title).x
	var width_subtitle : float = FONT_PARAGRAPH.get_string_size(subtitle).x
	var width_par_and_best : float = FONT_PARAGRAPH.get_string_size(par_and_best).x
	draw_text_with_shadow(FONT_BUTTON, str(number) + ":", position + Vector2(-WINDOW_WIDTH, 0), color_title)
	draw_text_with_shadow(FONT_BUTTON, title, position + Vector2(16.0 - WINDOW_WIDTH, 0), color_title)
	draw_text_with_shadow(FONT_PARAGRAPH, subtitle, position + Vector2(16.0 - WINDOW_WIDTH, 12), color_subtitle)
	draw_text_with_shadow(FONT_PARAGRAPH, par_and_best, position + Vector2(WINDOW_WIDTH-width_par_and_best, 12), color_subtitle)
	# Draw icons
	if unlocked:
		draw_texture_rect_region(SPRITE_ICONS, Rect2(position + Vector2(166, -6), Vector2(8, 8)), Rect2(72 if beat_par else 80, 0, 8, 8), Color.white)
		draw_texture_rect_region(SPRITE_ICONS, Rect2(position + Vector2(174, -6), Vector2(8, 8)), Rect2(8 if got_flowers else 16, 0, 8, 8), Color.white)
		if multiple_flowers:
			draw_texture_rect_region(SPRITE_ICONS, Rect2(position + Vector2(182, -6), Vector2(8, 8)), Rect2(88 if beaten else 96, 0, 8, 8), Color.white)

func draw_season(season : String, season_number : int) -> void:
	var season_offset : Vector2 = offset + Vector2(640 * season_number, 0)
	# Draw box
	draw_rect(Rect2(season_offset + Vector2(109, 67), Vector2(422, 234)), COLOR_SHADE_B, true)
	draw_rect(Rect2(season_offset + Vector2(110, 68), Vector2(420, 232)), Color.black, true)
	# Draw text
	var season_title : String = Levels.get_season_title(season)
	var season_subtitle : String = Levels.get_season_subtitle(season)
	var season_title_width : float = FONT_BUTTON.get_string_size(season_title).x
	var season_subtitle_width : float = FONT_PARAGRAPH.get_string_size(season_subtitle).x
	var season_title_pos : Vector2 = season_offset + Vector2(320-(season_title_width/2.0), 32)
	draw_text_with_shadow(FONT_BUTTON, season_title, season_title_pos, Color.white)
	var arrow_wiggle : float = sin(time * 5.0) * 2.0
	
	# now you can loop through seasons!
	# wow I look back through the code and... this wasn't a feature before??
	# It wasn't. Wow.
	# Also I noticed all the levels are kinda... blank in the original. probably b'cuz of my new
	#save format. oop.
	# I'mma fix.
	
	if GameProgress.get_unlocked_seasons() - 1 > 0:
		draw_text_with_shadow(FONT_BUTTON, "<", season_title_pos + Vector2(-16 - arrow_wiggle, 0), Color.white)
	if GameProgress.get_unlocked_seasons() - 1 > 0:
		draw_text_with_shadow(FONT_BUTTON, ">", season_title_pos + Vector2(season_title_width + 12 + arrow_wiggle, 0), Color.white)
	draw_text_with_shadow(FONT_PARAGRAPH, season_subtitle, season_offset + Vector2(320-(season_subtitle_width/2.0), 44), COLOR_SHADE_A)
	var levels : Array = Levels.get_season_levels(season)
	for i in range(0, levels.size()):
		var level_slug : String = levels[i]
		var level : Dictionary = Levels.get_level_data(level_slug)
		var best_time : int = GameProgress.get_level_best_time(level_slug)
		var unlocked : bool = GameProgress.is_level_unlocked(level_slug)
		var beat_par : bool = GameProgress.get_level_beat_par(level_slug)
		var level_flowers : Array = GameProgress.get_level_got_flowers(level_slug)
		var got_flowers : bool = level_flowers.count(true) > 0
		var beaten : bool = GameProgress.get_level_is_beaten(level_slug)
		var multiple_flowers : bool = level_flowers.size() > 1
		var finished : bool = GameProgress.is_level_finished(level_slug)
		draw_level(i+1, level["title"], level["subtitle"], best_time, level["par"], season_offset + Vector2(320, 84 + (i*32)), unlocked, finished, beat_par, got_flowers, multiple_flowers, beaten, selected_level == i)
	var cursor_position : Vector2 = season_offset + Vector2(126, 78) + cursor_offset
	draw_texture_rect_region(SPRITE_TICKBOX, Rect2(cursor_position, Vector2(8, 8)), Rect2(0, 0, 8, 8))

func _draw() -> void:
	for i in range(0, Levels.seasons.size()):
		var season : String = Levels.get_season_slug_by_index(selected_season)
		draw_season(season, i)
	# Draw completion percentage
	var completion_label_pos : Vector2 = Vector2(320, 330) - (FONT_BUTTON.get_string_size("Total Completion") / 2.0)
	var completion_value_pos : Vector2 = Vector2(320, 342) - (FONT_BUTTON.get_string_size(str(completion_percentage) + "%") / 2.0)
	draw_text_with_shadow(FONT_BUTTON, "Total Completion", completion_label_pos, COLOR_SHADE_A)
	draw_text_with_shadow(FONT_BUTTON, str(completion_percentage) + "%", completion_value_pos, Color.white)

func do_season_transition() -> void:
	tween.interpolate_property(self, "offset", offset, Vector2(selected_season * -640.0, 0), 0.5, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()

func do_cursor_transition() -> void:
	tween.interpolate_property(self, "cursor_offset", cursor_offset, Vector2(0, selected_level * 32.0), 0.25, Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween.start()

func start_level(level : String) -> void:
	Levels.goto_scene(level)

func _input(event : InputEvent) -> void:
	if not active: return
	var unlocked_levels : int = GameProgress.get_unlocked_levels_for_season(Levels.get_season_slug_by_index(selected_season))
	if event.is_action_pressed("ui_up"):
		selected_level -= 1
		if selected_level < 0:
			selected_level = unlocked_levels - 1
		do_cursor_transition()
		SoundMaster.play_sound("ui_move")
	if event.is_action_pressed("ui_down"):
		selected_level += 1
		if selected_level >= unlocked_levels:
			selected_level = 0
		do_cursor_transition()
		SoundMaster.play_sound("ui_move")
	if event.is_action_pressed("ui_left"):
		if selected_season > 0:
			selected_season -= 1
			SoundMaster.play_sound("ui_move")
		else:
			selected_season = GameProgress.get_unlocked_seasons() - 1
			SoundMaster.play_sound("ui_move")
		selected_level = min(selected_level, GameProgress.get_unlocked_levels_for_season(
			Levels.get_season_slug_by_index(selected_season)
		) - 1)
		do_cursor_transition()
		do_season_transition()
	if event.is_action_pressed("ui_right"):
		if selected_season < GameProgress.get_unlocked_seasons() - 1:
			selected_season += 1
			# We might need to force the cursor up a bit
			selected_level = min(selected_level, GameProgress.get_unlocked_levels_for_season(
				Levels.get_season_slug_by_index(selected_season)
			) - 1)
			do_cursor_transition()
			SoundMaster.play_sound("ui_move")
		else:
			selected_season = 0
			SoundMaster.play_sound("ui_move")
		do_season_transition()
	if event.is_action_pressed("ui_accept"):
		active = false
		SoundMaster.play_sound("ui_select")
		SoundMaster.fade_out_music()
		Overlay.transition_out()
		yield(Overlay, "transition_finished")
		var level : String = Levels.get_level_slug_by_index(selected_season, selected_level)
		start_level(level)
	if event.is_action_pressed("ui_cancel"):
		active = false
		SoundMaster.play_sound("ui_back")
		SoundMaster.change_layer(0)
		Overlay.transition_out()
		yield(Overlay, "transition_finished")
		get_tree().change_scene("res://scenes/TitleScreen.tscn")
	update()

func _process(delta : float) -> void:
	if foreground_bg:
		foreground_bg.self_modulate.a = lerp(1, 0, selected_season/8.0)
	time += delta
	update()

func _ready() -> void:
	var season : String = Levels.get_season_slug_by_index(selected_season)
	levels = Levels.get_season_levels(season)
	completion_percentage = round(GameProgress.get_completion_rate() * 1000.0) / 10.0
	Overlay.transition_in()
	var selected_bg = backgrounds[Settings.current_bg].instance()
	var bloody_bg = backgrounds[Settings.current_bg].instance()
	yield(get_tree().create_timer(0.01), "timeout")
	selected_bg.name = "Background"
	bloody_bg.name = "Bloody_Background"
	if Settings.current_bg == 1 or Settings.current_bg == 2:
			selected_bg.set_scale(Vector2(2,2))
			bloody_bg.set_scale(Vector2(2,2))
	if Settings.bg_bloodying:
		bloody_bg.force_bloody = true
	add_child(bloody_bg, true)
	add_child(selected_bg, true)
	foreground_bg = get_node("Background")
	if Settings.classic_mode:
		var shader = overlay.instance()
		shader.name = "SHADER_OVERLAY"
		add_child(shader)
