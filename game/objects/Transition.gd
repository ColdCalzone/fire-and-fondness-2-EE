extends Control

const SPRITE_TRANSITION = preload("res://sprites/ui/transition.png")

var transition_amount : float = 0.0
var transition_out : bool = false
var transition_active : bool = false

signal transition_finished

func _process(delta : float) -> void:
	if not transition_active: return
	transition_amount += delta
	if transition_amount > 1.0:
		emit_signal("transition_finished")
		transition_active = false
	update()

func _draw() -> void:
	if not transition_active: return
	for y in range(0, 12):
		var row_speed : float = 1.0
		if y % 2 == 0:
			row_speed = -1.0
		draw_set_transform(Vector2(transition_amount * row_speed * 128.0, 0), 0.0, Vector2(2, 2))
		for x in range(-16, 32):
			var frame = transition_amount
			frame = (frame*2.0) - (x/32.0)
			if transition_out:
				frame = round((frame)*16)*16
			else:
				frame = round((1.0-frame)*16)*16
			draw_texture_rect_region(SPRITE_TRANSITION, Rect2(x*16, y*16, 16, 16), Rect2(frame, 0, 16, 16), Color.black)

func transition_in() -> void:
	transition_out = false
	transition_amount = 0.0
	transition_active = true
	update()

func transition_out() -> void:
	transition_out = true
	transition_amount = 0.0
	transition_active = true
	update()
	
