extends CanvasLayer

class_name GameOver

enum CauseOfGameOver {
	PLAYER_BURNED, PLAYER_FALLEN, PLAYER_CRUSHED, CAUGHT_BY_DOG, CAUGHT_BY_CAT, CAUGHT_BY_INLAW,
	PARTNER_DIED, DOG_DIED, CAT_DIED, INLAW_DIED, NO_POSSIBLE_MOVES, DEFAULT
}

const quips : Dictionary = {
	CauseOfGameOver.PLAYER_BURNED: [
		"Maybe being single isn't so bad...",
		"How unromantic.",
		"Your insurance won't cover this.",
		"Forever alone. And somewhat charred.",
		"The course of true love usually doesn't involve third-degree burns.",
		"If you would be loved, remain uncauterised.",
		"What is love, if not a concerted effort to not catch fire?",
		"Toasty."
	],
	CauseOfGameOver.PLAYER_FALLEN: [
		"I have fallen and I cannot get up.",
		"You've really fallen for me, haven't you?"
	],
	CauseOfGameOver.PLAYER_CRUSHED: [
		"Don't let it hit you on the way out.",
		"You walked right into that one."
	],
	CauseOfGameOver.CAUGHT_BY_DOG: [
		"How unromantic.",
		"That's not what 'dogging' means!",
		"Woof."
	],
	CauseOfGameOver.CAUGHT_BY_CAT: [
		"How unromantic.",
		":3",
		"Meow."
	],
	CauseOfGameOver.CAUGHT_BY_INLAW: [
		"Have you been eating properly? You're so thin!",
		"You may be here for a while...",
		"Honestly, she has a point. You could ring her up every so often."
	],
	CauseOfGameOver.PARTNER_DIED: [
		"Maybe being single isn't so bad...",
		"How unromantic.",
		"The course of true love usually doesn't involve third-degree burns.",
		"I smell burning romance."
	],
	CauseOfGameOver.DOG_DIED: [
		"No animals were harmed in the making of this gameover.",
		"A dog is for life; not just for gameshows."
	],
	CauseOfGameOver.CAT_DIED: [
		"No animals were harmed in the making of this gameover."
	],
	CauseOfGameOver.INLAW_DIED: [
		"Maybe being single isn't so bad...",
		"How unromantic.",
		"From inlaw to outlaw."
	],
	CauseOfGameOver.NO_POSSIBLE_MOVES: [
		"Less 'careless whisper' and more 'careless step'.",
		"How are you going to get out of this one, then?"
	],
	CauseOfGameOver.DEFAULT: [
		"Please tell ColdCalzone#3996 what you did to get here."
	]
}

onready var menu = $Menu
onready var label_quip = $Label_Quip
onready var anim_player = $AnimationPlayer

var quip_type : int

func _ready() -> void:
	menu.items = {
		"game_over": {
			"type": "menu",
			"children": [
				"restart",
				"quit"
			]
		},
		"undo": {
			"type": "button",
			"label": "Undo a Turn"
		},
		"restart": {
			"type": "button",
			"label": "Restart Level"
		},
		"quit": {
			"type": "button",
			"label": "Back to Title Screen"
		}
	}
	menu.current_item = "game_over"
	menu.resize(true)
	var quips_of_type : Array = quips[quip_type]
	label_quip.text = quips_of_type[rand_range(0, quips_of_type.size())]
	anim_player.play("game_over")
	SoundMaster.stop_music()
	SoundMaster.play_sound("gameover")

func _on_Menu_button_pressed(slug : String) -> void:
	match slug:
		"undo":
			get_tree().call_group("board_object", "revert_to_previous_state")
			get_tree().paused = false
			queue_free()
		"restart":
			menu.active = false
			Overlay.transition_out()
			yield(Overlay, "transition_finished")
			get_tree().paused = false
			get_tree().reload_current_scene()
		"quit":
			menu.active = false
			Overlay.transition_out()
			yield(Overlay, "transition_finished")
			get_tree().paused = false
			get_tree().change_scene("res://scenes/TitleScreen.tscn")
