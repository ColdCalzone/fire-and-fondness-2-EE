extends CanvasLayer

onready var background = $Background
onready var bar = $Bar
onready var label_paused = $Label_Paused
onready var label_quip = $Label_Quip
onready var level_info1 = $Label_LevelInfo1
onready var level_info2 = $Label_LevelInfo2
onready var menu = $Menu
onready var tween = $Tween

const QUIPS : Array = [
	"Don't forget to pace yourself.",
	"I think we should take a break.",
	"Take your time."
]

func _ready() -> void:
	menu.items = {
		"pause_screen": {
			"type": "menu",
			"children": [
				"resume",
				"restart",
				"select",
				"return_to_menu"
			]
		},
		"resume": {
			"type": "button",
			"label": "Resume"
		},
		"restart": {
			"type": "button",
			"label": "Restart Level"
		},
		"select": {
			"type": "button",
			"label": "Return to Level Select"
		},
		"return_to_menu": {
			"type": "button",
			"label": "Return to Title Screen"
		}
	}
	menu.current_item = "pause_screen"
	menu.resize(true)
	SoundMaster.play_sound("ui_back")
	# Set label body
	label_quip.text = QUIPS[rand_range(0, QUIPS.size())]
	level_info1.text = Levels.get_level_supertitle(Levels.current_scene)
	level_info2.text = Levels.get_level_title(Levels.current_scene)
	# Animate the appearance
	tween.interpolate_property(background, "modulate", Color.transparent, Color.white, 0.25)
	tween.interpolate_property(bar, "rect_size", Vector2(640, 0), Vector2(640, 48), 0.5, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.interpolate_property(bar, "rect_position", Vector2(0, 180), Vector2(0, 156), 0.5, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.interpolate_property(label_paused, "rect_position", Vector2(293, -32), Vector2(293, 168), 0.5, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.interpolate_property(label_quip, "percent_visible", 0.0, 1.0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.25)
	tween.interpolate_property(menu, "rect_position", Vector2(240, 380), Vector2(240, 260), 0.5, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()

func _on_Menu_button_pressed(slug : String) -> void:
	match slug:
		"resume":
			get_tree().paused = false
			queue_free()
		"restart":
			menu.active = false
			Overlay.transition_out()
			yield(Overlay, "transition_finished")
			get_tree().paused = false
			get_tree().reload_current_scene()
		"select":
			menu.active = false
			SoundMaster.stop_all_sounds()
			SoundMaster.fade_out_music()
			Overlay.transition_out()
			yield(Overlay, "transition_finished")
			SoundMaster.play_title_music()
			SoundMaster.change_layer_immediately(1)
			Levels.currently_editing = false
			get_tree().paused = false
			get_tree().change_scene("res://scenes/LevelSelect.tscn")
		"return_to_menu":
			menu.active = false
			SoundMaster.stop_all_sounds()
			SoundMaster.fade_out_music()
			Overlay.transition_out()
			yield(Overlay, "transition_finished")
			Levels.currently_editing = false
			get_tree().paused = false
			get_tree().change_scene("res://scenes/TitleScreen.tscn")

func _on_Menu_back_from_root() -> void:
	SoundMaster.play_sound("ui_back")
	get_tree().paused = false
	queue_free()
