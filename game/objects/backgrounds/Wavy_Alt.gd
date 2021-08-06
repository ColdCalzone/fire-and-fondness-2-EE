extends Node2D

const SPRITE_PIXEL = preload("res://sprites/pixel.png")

var time : float = 0.0
var force_bloody : bool = false

func _draw() -> void:
	if not Settings.background_enabled: return
	for y in range(0, 9):
		for x in range(-1, 17):
			var transform : Vector2 = Vector2(x*40, y*40) + Vector2(20, 20)
			var rotate : float = 0.0
			var scale : float = sin((time+x+x)/4.0) * 28.0
			var colour_index : int = (x) % 3
			var colour : Color 
			if !force_bloody:
				colour = Settings.get_background_colours()[colour_index]
			else:
				colour = Settings.PALETTE_BLOODY[colour_index]
			draw_set_transform(transform, rotate, Vector2.ONE * scale)
			draw_texture(SPRITE_PIXEL, Vector2(sin(8), -0.5), colour)

func _process(delta):
	time += delta * Settings.get_background_speed_amount()*2
	update()
