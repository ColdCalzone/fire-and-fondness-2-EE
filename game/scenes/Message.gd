extends Control

const FONT_PARAGRAPH : Font = preload("res://fonts/paragraph.tres")

onready var menu = $Center_Menu/Menu
onready var vbox = $Center_Message/VBox
onready var label_title = $Center_Message/VBox/Label_Title
onready var label_body = $Center_Message/VBox/Label_Body
onready var center_menu = $Center_Menu
onready var background_outline = $Center_Message/Background_Outline
onready var tween = $Tween
onready var timer_typewriter = $Timer_Typewriter

var overlay = preload("res://objects/Scanline_Overlay.tscn")

var message_body : String = ""
var chars_visible : int = 0
var finished_typing : bool = false

func show_menu() -> void:
	menu.items = {
		"season_end": {
			"type": "menu",
			"children": [
				"continue",
				"return_to_menu"
			]
		},
		"season_end_no_next": {
			"type": "menu",
			"children": [
				"return_to_menu"
			]
		},
		"continue": {
			"type": "button",
			"label": "Continue"
		},
		"return_to_menu": {
			"type": "button",
			"label": "Return to Title Screen"
		}
	}
	if Levels.message_has_next(Levels.current_scene):
		menu.current_item = "season_end"
	else:
		menu.current_item = "season_end_no_next"
	menu.resize(true)
	menu.show()

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
			next_level()
		"return_to_menu":
			menu.active = false
			SoundMaster.stop_all_sounds()
			Overlay.transition_out()
			yield(Overlay, "transition_finished")
			get_tree().paused = false
			get_tree().change_scene("res://scenes/TitleScreen.tscn")

func finished_typing_message() -> void:
	finished_typing = true
	tween.interpolate_property(center_menu, "rect_position", Vector2(0, 360), Vector2(0, 240), 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.5)
	tween.start()
	yield(tween, "tween_all_completed")
	menu.active = true

func _on_Timer_Typewriter_timeout():
	var current_char : String = message_body[chars_visible]
	chars_visible += 1
	label_body.text = message_body.substr(0, chars_visible)
	# Are we done?
	if chars_visible == message_body.length():
		# Here ends the reading
		finished_typing_message()
	else:
	# Set up the delay for the next character. To make the text type in a more "speechy" way,
	# alter the delay if it's at a natural break in the sentence.
		var delay : float
		match current_char:
			",": delay = 0.25
			":": delay = 0.25
			".": delay = 0.25
			"?": delay = 0.25
			"!": delay = 0.25
			"\n": delay = 0.15
			_: delay = 1.0 / 60.0
		timer_typewriter.start(delay)

# The player might want to skip the reading of the message
func _input(event : InputEvent) -> void:
	# Don't bother if we've already finished typing
	if finished_typing:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		label_body.text = message_body
		timer_typewriter.stop()
		finished_typing_message()

func _ready() -> void:
	SoundMaster.stop_music()
	Overlay.transition_in()
	menu.active = false
	label_title.text = Levels.get_message_title(Levels.current_scene)
	label_body.text = ""
	message_body = Levels.get_message_body(Levels.current_scene)
	var message_height : float = FONT_PARAGRAPH.get_wordwrap_string_size(message_body, 520.0).y
	background_outline.rect_min_size.y = message_height + 80.0
	label_body.rect_min_size.y = message_height + 24.0
	timer_typewriter.start(1.0)
	show_menu()
	var text_time : float = float(label_body.text.length() / 60.0)
	if Settings.classic_mode:
		var shader = overlay.instance()
		shader.name = "SHADER_OVERLAY"
		add_child(shader)
