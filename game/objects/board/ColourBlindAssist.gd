extends Node2D

const SPRITE_INDICATORS : Texture = preload("res://sprites/indicators.png")

const INDICATOR_SIZE : Vector2 = Vector2(8, 9)

func _draw() -> void:
	if Settings.colour_blind_assist != Settings.COLOUR_BLIND_ASSIST.INDICATORS: return
	for object_type in ["door", "switch", "hourglass", "pressure_plate"]:
		for object in get_tree().get_nodes_in_group(object_type):
			draw_indicator(object.position, object.door_type)
	for object_type in ["teleporter", "teleporter_target", "duplicator"]:
		for object in get_tree().get_nodes_in_group(object_type):
			draw_indicator(object.position, object.teleporter_type)

func draw_indicator(at : Vector2, which : int) -> void:
	draw_texture_rect_region(SPRITE_INDICATORS,
		Rect2(at - Vector2(2, 2), INDICATOR_SIZE),
		Rect2(Vector2(8 * which, 0), INDICATOR_SIZE))
