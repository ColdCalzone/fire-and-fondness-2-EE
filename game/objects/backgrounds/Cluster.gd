extends Node2D

const SPRITE_PIXEL = preload("res://sprites/pixel.png")

var time : float = 0.0
var force_bloody : bool = false

func draw_cluster(x : int, y : int) -> void:
	var scroll : float = fmod(time / 5.0, 6.0)
	var pos : Vector2 = Vector2(x + 0.32, y + scroll if x % 2 == 0 else y + 0.5 - scroll) * 48
	var z : int = (x * 3) + (y * 5)
	var which : int = int(floor(time / 4.0)) + z
	var bounce_a : float = 1.0 + ease(fmod(time, 1.0), 2.0)
	var bounce_b : float = 2.0 - ease(fmod(time, 1.0), 0.5)
	var bounce : float = bounce_a if fmod(time, 2.0) < 1.0 else bounce_b
	var bounce_me : float = bounce if which % 7 == 0 else 1
	draw_set_transform(pos, (PI if x % 2 == 0 else -PI) / 4.0, Vector2.ONE * 8)
	if !force_bloody:
		draw_texture(SPRITE_PIXEL, Vector2(-0.75, -0.75), Settings.get_background_colours()[z % 3])
		draw_texture(SPRITE_PIXEL, Vector2(-0.75, 0.75) * bounce_me, Settings.get_background_colours()[(z + 1) % 3])
		draw_texture(SPRITE_PIXEL, Vector2(0.75, -0.75) * bounce_me, Settings.get_background_colours()[(z + 2) % 3])
		draw_texture(SPRITE_PIXEL, Vector2(0.75, 0.75), Settings.get_background_colours()[z % 3])
	else:
		draw_texture(SPRITE_PIXEL, Vector2(-0.75, -0.75), Settings.PALETTE_BLOODY[z % 3])
		draw_texture(SPRITE_PIXEL, Vector2(-0.75, 0.75) * bounce_me, Settings.PALETTE_BLOODY[(z + 1) % 3])
		draw_texture(SPRITE_PIXEL, Vector2(0.75, -0.75) * bounce_me, Settings.PALETTE_BLOODY[(z + 2) % 3])
		draw_texture(SPRITE_PIXEL, Vector2(0.75, 0.75), Settings.PALETTE_BLOODY[z % 3])

func _draw() -> void:
	if not Settings.background_enabled: return
	for x in range(0, 14):
		for y in range(-8, 20):
			draw_cluster(x, y)

func _process(delta : float) -> void:
	time += delta * Settings.get_background_speed_amount()
	update()
