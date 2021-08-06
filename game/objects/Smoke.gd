extends Sprite

const ANIM_SPEED : float = 10.0

var anim_index : float = 0.0
var velocity : Vector2

func _process(delta : float) -> void:
	position += velocity * delta
	velocity = lerp(velocity, Vector2.ZERO, delta * 8.0)
	anim_index += ANIM_SPEED * delta
	if anim_index >= 4.0:
		queue_free()
	else:
		frame = int(floor(anim_index))
