extends Control

const SPRITE_PIXEL = preload("res://sprites/pixel.png")

onready var label_supertitle = $Label_Supertitle
onready var label_title = $Label_Title
onready var label_subtitle = $Label_Subtitle
onready var tween = $Tween

var overlay = preload("res://objects/Scanline_Overlay.tscn")

var transition_level : float = 1.0
var time : float = 0.0

func draw_stripe(between_bits : float, size : float, speed : float, y : float, initial_offset : float, colour : Color) -> void:
	var max_offset : float = 640.0 + (between_bits * 2.0)
	var offset : float = fmod(initial_offset, between_bits)
	while offset < max_offset:
		var x : float = wrapf(offset + (time * speed), -between_bits, 640.0 + between_bits)
		draw_set_transform(Vector2(x, y), deg2rad(45.0), Vector2(size, size))
		draw_texture(SPRITE_PIXEL, Vector2(-0.5, -0.5), colour)
		offset += between_bits

func draw_stripes() -> void:
	draw_rect(Rect2(0.0, 0.0, 640.0, 100.0), Settings.get_background_colours()[0])
	draw_rect(Rect2(0.0, 260.0, 640.0, 100.0), Settings.get_background_colours()[1])
	draw_stripe(64.0, 64.0, 64.0, 100.0, label_title.rect_position.x / 4.0, Settings.get_background_colours()[0])
	draw_stripe(64.0, 64.0, -64.0, 260.0, label_subtitle.rect_position.x / 4.0, Settings.get_background_colours()[1])

func _draw() -> void:
	draw_stripes()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_rect(Rect2(0.0, 0.0, 640.0, 180.0 * transition_level), Color.black)
	draw_rect(Rect2(0.0, 360.0 - (180.0 * transition_level), 640.0, 360.0), Color.black)

func _process(delta : float) -> void:
	time += delta * Settings.get_background_speed_amount()
	update()

func do_transition() -> void:
	tween.interpolate_property(label_supertitle, "percent_visible", 0.0, 1.0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.5)
	tween.interpolate_property(label_title, "rect_position", Vector2(-480, 172), Vector2(160, 172), 1.0, Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween.interpolate_property(label_subtitle, "rect_position", Vector2(720, 192), Vector2(80, 192), 1.0, Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween.interpolate_property(label_supertitle, "percent_visible", 1.0, 0.0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT, 2.0)
	tween.interpolate_property(label_title, "rect_position", Vector2(160, 172), Vector2(720, 172), 1.0, Tween.TRANS_QUINT, Tween.EASE_IN, 2.0)
	tween.interpolate_property(label_subtitle, "rect_position", Vector2(80, 192), Vector2(-560, 192), 1.0, Tween.TRANS_QUINT, Tween.EASE_IN, 2.0)
	tween.interpolate_property(self, "transition_level", 1.0, 0.0, 0.5, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.interpolate_property(self, "transition_level", 0.0, 1.0, 1.0, Tween.TRANS_CIRC, Tween.EASE_IN, 2.0)
	tween.start()
	SoundMaster.play_sound("level_intro")
	yield(tween, "tween_all_completed")
	yield(get_tree().create_timer(0.25), "timeout")
	transition_finished()

func transition_finished() -> void:
	get_tree().change_scene("res://scenes/Game.tscn")

func _ready() -> void:
	if Settings.classic_mode:
		var shader = overlay.instance()
		shader.name = "SHADER_OVERLAY"
		add_child(shader)
	yield(get_tree().create_timer(0.25), "timeout")
	label_supertitle.text = Levels.get_level_supertitle(Levels.current_scene)
	label_title.text = Levels.get_level_title(Levels.current_scene)
	label_subtitle.text = Levels.get_level_subtitle(Levels.current_scene)
	do_transition()
