extends CanvasLayer

onready var menu = $Menu
onready var label_steps = $Grid/Label_Steps_Value
onready var texture_flower1 = $Grid/Control/TextureRect_Flower1_Value
onready var texture_flower2 = $Grid/Control/TextureRect_Flower2_Value
onready var texture_flower3 = $Grid/Control/TextureRect_Flower3_Value
onready var texture_flower4 = $Grid/Control/TextureRect_Flower4_Value
onready var label_quip = $Label_Quip
onready var anim_player = $AnimationPlayer

const quips_with_flower : Array = [
	"Rose acquired, sweetheart uncooked. Mission accomplished.",
	"True romance achieved.",
	"You've got the touch! You've got the floweeeer!",
	"How romantic!"
]

const quips_without_flower : Array = [
	"Disregarded roses; escaped burning building.",
	"The flowers were wilting, anyway.",
	"Anna Jarvis would be so proud."
]

var steps_taken : int
var par : int
var flowers_collected : Array
var flowers_total : int

func _ready() -> void:
	menu.items = {
		"you_win": {
			"type": "menu",
			"children": [
				"continue",
				"restart",
				"select",
				"quit"
			]
		},
		"continue": {
			"type": "button",
			"label": "Continue"
		},
		"restart": {
			"type": "button",
			"label": "Restart"
		},
		"select": {
			"type": "button",
			"label": "Back to Level Select"
		},
		"quit": {
			"type": "button",
			"label": "Back to Menu"
		}
	}
	menu.current_item = "you_win"
	# Set level stats
	label_steps.text = "%d/%d" % [steps_taken, par]
	var flower_count = get_tree().get_nodes_in_group("flower").size()
	
	if flower_count >= 1:
		texture_flower1.texture.region.position.x = 8 if flowers_collected[0] else 16
	if flower_count >= 2:
		texture_flower2.texture.region.position.x = 24 if flowers_collected[1] else 32
	if flower_count >= 3:
		texture_flower3.texture.region.position.x = 40 if flowers_collected[2] else 48
	if flower_count >= 4:
		texture_flower4.texture.region.position.x = 56 if flowers_collected[3] else 64
	# and now to yeet delete
	if flower_count < 4:
		texture_flower4.visible = false
	if flower_count < 3:
		texture_flower3.visible = false
	if flower_count < 2:
		texture_flower2.visible = false
	if flower_count < 1:
		texture_flower1.visible = false
	menu.resize(true)
	SoundMaster.play_sound("you_win")
	SoundMaster.fade_out_music()
	if flowers_collected.size() >= flowers_total:
		label_quip.text = quips_with_flower[rand_range(0, quips_with_flower.size())]
		SoundMaster.play_sound("bgm_win2")
	else:
		label_quip.text = quips_without_flower[rand_range(0, quips_without_flower.size())]
		SoundMaster.play_sound("bgm_win1")
	anim_player.play("appear")

func next_level() -> void:
	Overlay.transition_out()
	yield(Overlay, "transition_finished")
	Levels.goto_scene(Levels.get_next_scene(Levels.current_scene))
	get_tree().paused = false
	queue_free()

func _on_Menu_button_pressed(slug : String) -> void:
	match slug:
		"continue":
			menu.active = false
			if not Levels.currently_editing:
				next_level()
			else:
				Overlay.transition_out()
				yield(Overlay, "transition_finished")
				SoundMaster.play_title_music()
				get_tree().paused = false
				SoundMaster.change_layer_immediately(1)
				get_tree().change_scene("res://scenes/LevelEditor.tscn")
		"restart":
			menu.active = false
			Overlay.transition_out()
			yield(Overlay, "transition_finished")
			get_tree().paused = false
			get_tree().reload_current_scene()
		"select":
			menu.active = false
			Overlay.transition_out()
			yield(Overlay, "transition_finished")
			get_tree().paused = false
			SoundMaster.play_title_music()
			SoundMaster.change_layer_immediately(1)
			Levels.currently_editing = false
			get_tree().change_scene("res://scenes/LevelSelect.tscn")
		"quit":
			menu.active = false
			Overlay.transition_out()
			yield(Overlay, "transition_finished")
			get_tree().paused = false
			SoundMaster.play_title_music()
			SoundMaster.change_layer_immediately(1)
			Levels.currently_editing = false
			get_tree().change_scene("res://scenes/TitleScreen.tscn")
