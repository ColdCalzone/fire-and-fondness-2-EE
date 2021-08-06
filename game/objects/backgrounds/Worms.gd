extends Node2D

const RENDER_INCR : float = 0.05

var time : float = 0.0
var force_bloody : bool = false

func pingpong(i : float) -> float:
	i = fmod(i, 4.0)
	if i > 3.0:
		return i - 4.0
	if i > 1.0:
		return 1 - (i - 1.0)
	return i

func draw_diamond(angle_a : float, angle_b : float, size : float, color : Color) -> void:
	var points : PoolVector2Array
	var colors : PoolColorArray
	points.append(Vector2.ZERO)
	points.append(Vector2(pingpong(angle_a), pingpong(angle_a + 1.0)) * size)
	points.append(Vector2(pingpong(ceil(angle_a)), pingpong(ceil(angle_a) + 1.0)) * size)
	points.append(Vector2(pingpong(angle_b), pingpong(angle_b + 1.0)) * size)
	for i in range(0, 4):
		colors.append(color)
	draw_polygon(points, colors)

func draw_diamond_hole(size : float) -> void:
	var points : PoolVector2Array
	var colors : PoolColorArray
	for point in [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]:
		points.append(point * size)
		colors.append(Color.black)
	draw_polygon(points, colors)

func _draw() -> void:
	if not Settings.background_enabled: return
	for x in range(0, 11):
		var scroll : Vector2 = Vector2(0.0, 0.0 * 2.0).posmodv(Vector2(192, 128)) + Vector2(16, 0)
		for y in range(0, 6):
			var wibble : float = sin(time)*0.25 if x % 3 == 0 else -sin(time)*0.25 if x % 3 == 1 else 0.0
			draw_set_transform(Vector2(x*64, (y+wibble)*64)-scroll, 0.0, Vector2(Vector2.ONE * 16))
			var j : float = time+x+y
			var k : float = (time+x+y)*2.0
			if !force_bloody:
				var colour_index_a : int = (x+y) % Settings.get_background_colours().size()
				var colour_index_b : int = (x+y+2) % Settings.get_background_colours().size()
				draw_diamond(j, j+1.0, 1.5, Settings.get_background_colours()[colour_index_a])
				draw_diamond_hole(1.25)
				draw_diamond(k, k+1.0, 1.0, Settings.get_background_colours()[colour_index_b])
				draw_diamond_hole(0.75)
			else:
				var colour_index_a : int = (x+y) % Settings.PALETTE_BLOODY.size()
				var colour_index_b : int = (x+y+2) % Settings.PALETTE_BLOODY.size()
				draw_diamond(j, j+1.0, 1.5, Settings.PALETTE_BLOODY[colour_index_a])
				draw_diamond_hole(1.25)
				draw_diamond(k, k+1.0, 1.0, Settings.PALETTE_BLOODY[colour_index_b])
				draw_diamond_hole(0.75)

func _process(delta : float) -> void:
	time += delta * Settings.get_background_speed_amount() * 0.5
	update()
