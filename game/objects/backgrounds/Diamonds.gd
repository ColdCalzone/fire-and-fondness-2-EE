extends Node2D

const SPRITE_PIXEL = preload("res://sprites/pixel.png")

var time : float = 0.0

var rotate : float = deg2rad(45.0)

var fore_color : Color
var back_color : Color = Color.black

var current_index : float = 0.0

var stop : bool = false

var force_bloody : bool = false

func _draw() -> void:
	if not Settings.background_enabled: return
	var number_of_colours : int = Settings.get_background_colours().size()
	var color_index : int = int(floor(current_index))
	if !force_bloody:
		fore_color = Settings.get_background_colours()[color_index]
	else:
		fore_color = Settings.PALETTE_BLOODY[color_index]
	draw_rect(Rect2(-64, -64, 425, 295), change_back() if fmod(time, 4.0) > 2.0 else change_fore())
	for y in range(0, 5):
		for x in range(0, 8):
			var transform : Vector2 = Vector2(x*45, y*45) + Vector2(22.5, 22.5)
			var scale : float = fmod(time, 2.0)
			scale = clamp(scale - ((x+y)/12.0), 0.0, 2.0) * 56.0
			var colour : Color = fore_color if fmod(time, 4.0) > 2.0 else back_color
			draw_set_transform(transform, rotate, Vector2.ONE * scale)
			draw_texture(SPRITE_PIXEL, Vector2(-0.5, -0.5), colour)

func _process(delta):
	time += delta * Settings.get_background_speed_amount()/1.5
	update()

func change_fore() -> Color:
	stop = false
	return fore_color

func change_back() -> Color:
	if !stop: current_index += 1
	if current_index > 2.5: current_index = 0
	stop = true
	
	return back_color
