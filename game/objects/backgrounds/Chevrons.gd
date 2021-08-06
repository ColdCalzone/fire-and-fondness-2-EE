extends Node2D

var time : float = 0.0
var force_bloody : bool = false

func _draw() -> void:
	if not Settings.background_enabled: return
	for x in range(1, 33):
		var scroll : Vector2 = Vector2(time*5.0, 0.0).posmodv(Vector2(192, 128)) + Vector2(16, 0)
		for y in range(0, 5):
			var stretch : float = cos(time)
			var offset : float = sin(time)/4.0 if x % 2 == 0 else -sin(time)/4.0
			draw_set_transform(Vector2(x*16, (y+offset)*50)-scroll, 0.0, Vector2.ONE * 8)
			var points : PoolVector2Array
			var colors : PoolColorArray
			var coefficient : Vector2 = Vector2.ONE if x % 2 == 0 else Vector2(1, -1)
			points.append(Vector2(1, 0) * coefficient)
			points.append(Vector2(0, 1) * coefficient)
			points.append(Vector2(0, 3+stretch) * coefficient)
			points.append(Vector2(1, 2+stretch) * coefficient)
			points.append(Vector2(2, 3+stretch) * coefficient)
			points.append(Vector2(2, 1) * coefficient)
			var colour_index : int = x % Settings.get_background_colours().size()
			for i in range(0, 6):
				if !force_bloody:
					colors.append(Settings.get_background_colours()[colour_index])
				else:
					colors.append(Settings.PALETTE_BLOODY[colour_index])
			draw_polygon(points, colors)

func _process(delta : float) -> void:
	time += delta * Settings.get_background_speed_amount()
	update()
