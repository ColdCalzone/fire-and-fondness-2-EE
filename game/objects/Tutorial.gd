extends CanvasLayer

const COLOR_OUTLINE = Color("595652")

onready var label_title = $Center/Rect_Outline/Rect_Inner/VBox/Label_Title
onready var label_body = $Center/Rect_Outline/Rect_Inner/VBox/Label_Body
onready var label_prompt = $Center/Rect_Outline/Rect_Inner/VBox/Label_Prompt
onready var rect_outline = $Center/Rect_Outline
onready var rect_inner = $Center/Rect_Outline/Rect_Inner
onready var vbox = $Center/Rect_Outline/Rect_Inner/VBox
onready var center = $Center
onready var background = $Background
onready var tween = $Tween

var showing : bool
var slug : String

func set_label_title(text : String) -> void:
	label_title.text = text

func set_label_body(text : String) -> void:
	label_body.text = text

func resize() -> void:
	var body_height = label_body.get_line_count() * label_body.get_line_height()
	rect_outline.rect_min_size.y = body_height + 72

func transition_in() -> void:
	tween.interpolate_property(background, "color", Color(0.0, 0.0, 0.0, 0.0), Color(0.0, 0.0, 0.0, 0.5), 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(center, "rect_position", Vector2(0, 360), Vector2.ZERO, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	yield(get_tree().create_timer(0.5), "timeout") # Prevent the player from accidentally dismissing the tutorial too soon
	showing = true

func transition_out() -> void:
	tween.interpolate_property(background, "color", Color(0.0, 0.0, 0.0, 0.5), Color(0.0, 0.0, 0.0, 0.0), 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(center, "rect_position", Vector2.ZERO, Vector2(0, 360), 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	get_tree().paused = false
	queue_free()

func _input(event : InputEvent) -> void:
	if event is InputEventKey or InputEventJoypadButton and showing:
		showing = false
		transition_out()

func _ready() -> void:
	GameProgress.set_tutorial_shown(slug)
	showing = false
	transition_in()
