extends CanvasLayer

onready var transition = $Transition

signal transition_finished

func transition_in() -> void:
	transition.transition_in()
	yield(transition, "transition_finished")
	emit_signal("transition_finished")

func transition_out() -> void:
	transition.transition_out()
	yield(transition, "transition_finished")
	emit_signal("transition_finished")
