extends Control

const FONT_BUTTON : Font = preload("res://fonts/paragraph_bold.tres")
const SPRITE_CURSOR = preload("res://sprites/ui/cursor.png")
const SPRITE_TICKBOX = preload("res://sprites/ui/tickbox.png")
const OLD_SPRITE_TICKBOX = preload("res://sprites/ui/old_tickbox.png")
const SPRITE_SLIDER = preload("res://sprites/ui/slider.png")
const SPRITE_CHARACTERS = preload("res://sprites/characters.png")

signal button_pressed
signal variable_changed
signal back_from_root

onready var tween : Tween = $Tween

const VOLUME_INCR : float = 0.125

var items : Dictionary
var variables : Dictionary

var current_item : String
var current_child : int = 0
onready var active : bool = true

var cursor_pos : float = 0.0

func get_current_item() -> Dictionary:
	if items.has(current_item):
		return items[current_item]
	return {}

func get_current_children() -> Array:
	var item : Dictionary = get_current_item()
	if item.has("children"):
		return item["children"]
	return []

func get_label_for_item(slug : String) -> String:
	if items.has(slug):
		var item : Dictionary = items[slug]
		if item.has("label"):
			return item["label"]
	# Special cases
	if slug == "back":
		return "Back"
	return ""

func get_current_menu_child_slug(position : int) -> String:
	var item : Dictionary = items[current_item]
	if not item.has("children"): return ""
	return item["children"][position]

func get_child_type(slug : String) -> String:
	if not items.has(slug): return "null"
	var item : Dictionary = items[slug]
	if item.has("type"):
		return item["type"]
	return "null"

func is_child_button(slug : String) -> bool:
	return get_child_type(slug) == "button"

func is_child_menu(slug : String) -> bool:
	return get_child_type(slug) == "menu"

func is_child_variable(slug : String) -> bool:
	return get_child_type(slug) == "variable"

func get_select_size(options : Array) -> float:
	var max_option_size : float = 0.0
	for option in options:
		var option_size : Vector2 = FONT_BUTTON.get_string_size(option)
		max_option_size = max(option_size.x, max_option_size)
	return max_option_size + 24.0

func get_menu_item_size(menu_item : Dictionary) -> Vector2:
	var label : String = menu_item["label"]
	var label_size : Vector2 = FONT_BUTTON.get_string_size(label)
	if menu_item["type"] == "variable":
		var variable_name : String = menu_item["variable_name"]
		var variable : Dictionary = variables[variable_name]
		match variable["type"]:
			"tickbox":
				label_size.x += 16
			"volume":
				label_size.x += 24
			"select":
				label_size.x += get_select_size(variable["options"])
			"avatar":
				label_size.x += 20
			"text":
				label_size.x += 20
			"warn":
				label_size.x += 20
			"number":
				label_size.x += 20
	return label_size

func resize(instant : bool = false) -> void:
	var size : Vector2 = Vector2(0, 4)
	var children : Array = get_current_children()
	for i in range(0, children.size()):
		var child : String = children[i]
		var menu_item : Dictionary = items[child]
		var child_size : Vector2 = get_menu_item_size(menu_item)
		size = Vector2(max(size.x, child_size.x), size.y + 16)
	if instant:
		rect_min_size = size
		rect_size = size
		update()
	else:
		# Tween it
		tween.interpolate_property(self, "rect_size", rect_size, size, 0.25, Tween.TRANS_QUINT, Tween.EASE_OUT)
		tween.interpolate_property(self, "rect_min_size", rect_min_size, size, 0.25, Tween.TRANS_QUINT, Tween.EASE_OUT)
		tween.start()

func draw_text_with_shadow(text : String, position : Vector2, color : Color) -> void:
	draw_string(FONT_BUTTON, position + Vector2(1, 1), text, Color("222034"))
	draw_string(FONT_BUTTON, position, text, color)

func draw_tickbox(variable : Dictionary, position : Vector2, is_current : bool) -> void:
	var value : bool = variable["value"]
	var tickbox_offset : float = (float(value) + (float(is_current) * 2)) * 8.0
	draw_texture_rect_region(SPRITE_TICKBOX if not Settings.classic_mode else OLD_SPRITE_TICKBOX, Rect2(position + Vector2(rect_size.x, 6), Vector2(8, 8)), Rect2(tickbox_offset, 0, 8, 8))

func draw_volume(variable : Dictionary, position : Vector2, is_current : bool) -> void:
	var empty_offset : float = ((float(is_current) * 2)) * 24.0
	var full_offset : float = (1 + (float(is_current) * 2)) * 24.0
	var fullness : float = variable["value"] * 24.0
	draw_texture_rect_region(SPRITE_SLIDER, Rect2(position + Vector2(rect_size.x - 12, 5), Vector2(24, 10)), Rect2(empty_offset, 0, 24, 10))
	draw_texture_rect_region(SPRITE_SLIDER, Rect2(position + Vector2(rect_size.x - 12, 5), Vector2(fullness, 10)), Rect2(full_offset, 0, fullness, 10))

func draw_select(variable : Dictionary, position : Vector2, is_current : bool) -> void:
	var color : Color = Color.white if is_current else Color("847e87")
	var value : int = variable["value"]
	var options : Array = variable["options"]
	var label : String = options[value]
	var label_size : Vector2 = FONT_BUTTON.get_string_size(label)
	var max_label_size : float = get_select_size(options)
	draw_text_with_shadow(label, position + Vector2(rect_size.x - label_size.x + 4, 13), color)
	draw_text_with_shadow("<", position + Vector2(rect_size.x - max_label_size + 20, 13), color)
	draw_text_with_shadow(">", position + Vector2(rect_size.x + 8, 13), color)

func draw_avatar(variable : Dictionary, position : Vector2, is_current : bool) -> void:
	var color : Color = Color.white if is_current else Color("847e87")
	var value : int = variable["value"]
	var tickbox_offset : Rect2 = Rect2(16 * value, 0, 16, 16)
	draw_texture_rect_region(SPRITE_CHARACTERS, Rect2(position + Vector2(rect_size.x - 4, 2), Vector2(-16, 16)), tickbox_offset, Color.white)
	draw_text_with_shadow("<", position + Vector2(rect_size.x - 7, 13), color)
	draw_text_with_shadow(">", position + Vector2(rect_size.x + 10, 13), color)

func draw_text(label : String, position : Vector2, is_current : bool, color : Color = Color("847e87")) -> void:
	var label_size : Vector2 = FONT_BUTTON.get_string_size(label)
	draw_text_with_shadow(label, position + Vector2(rect_size.x - label_size.x + 4, 13), color)

func draw_warn(label : String, position : Vector2, is_current : bool):
	draw_text(label, position, is_current, Color("e4454a"))

func draw_number(variable : Dictionary, position : Vector2, is_current : bool) -> void:
	var color : Color = Color.white if is_current else Color("847e87")
	var value : int = variable["value"]
	var tickbox_offset : Rect2 = Rect2(16 * value, 0, 16, 16)
	draw_texture_rect_region(SPRITE_CHARACTERS, Rect2(position + Vector2(rect_size.x - 4, 2), Vector2(-16, 16)), tickbox_offset, Color.white)
	draw_text_with_shadow("<", position + Vector2(rect_size.x - 7, 13), color)
	draw_text_with_shadow(">", position + Vector2(rect_size.x + 10, 13), color)

func draw_variable(variable_name : String, position : Vector2, is_current : bool) -> void:
	var variable : Dictionary = variables[variable_name]
	match variable["type"]:
		"tickbox":
			draw_tickbox(variable, position, is_current)
		"volume":
			draw_volume(variable, position, is_current)
		"select":
			draw_select(variable, position, is_current)
		"avatar":
			draw_avatar(variable, position, is_current)
		"number":
			draw_number(variable, position, is_current)

func draw_menu_item(menu_item : Dictionary, position : Vector2, is_current : bool) -> void:
	var label : String = menu_item["label"]
	var color : Color = Color.white if is_current else Color("847e87")
	draw_text_with_shadow(label, position + Vector2(4, 13), color)
	match menu_item["type"]:
		"variable":
			var variable_name = menu_item["variable_name"]
			draw_variable(variable_name, position, is_current)
		"text":
			var item_label = menu_item["label"]
			draw_text(item_label, position, is_current)
		"warn":
			var item_label = menu_item["label"]
			draw_warn(item_label, position, is_current)

func _draw() -> void:
	var offset : Vector2 = Vector2.ZERO
	var children : Array = get_current_children()
	for i in range(0, children.size()):
		var menu_item_name : String = children[i]
		var menu_item : Dictionary = items[menu_item_name]
		draw_menu_item(menu_item, offset, i == current_child)
		offset.y += 16
	# Draw cursor
	draw_texture(SPRITE_CURSOR, Vector2(-10, 6 + cursor_pos))

func _process(delta : float) -> void:
	if tween.is_active():
		update()

func move_cursor() -> void:
	tween.interpolate_property(self, "cursor_pos", cursor_pos, current_child * 16, 0.25, Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween.start()

func toggle_tickbox(variable_slug : String) -> void:
	var value : bool = variables[variable_slug]["value"]
	value = !value
	variables[variable_slug]["value"] = value
	emit_signal("variable_changed", variable_slug)

func increase_volume(variable_slug : String) -> void:
	var value : float = variables[variable_slug]["value"]
	if value < 1.0:
		value += VOLUME_INCR
		variables[variable_slug]["value"] = value
		emit_signal("variable_changed", variable_slug)

func decrease_volume(variable_slug : String) -> void:
	var value : float = variables[variable_slug]["value"]
	if value > 0.0:
		value -= VOLUME_INCR
		variables[variable_slug]["value"] = value
		emit_signal("variable_changed", variable_slug)

func next_option(variable_slug : String) -> void:
	var variable : Dictionary = variables[variable_slug]
	var option_count : int = variable["options"].size()
	var value : int = variable["value"]
	value += 1
	if value >= option_count:
		value = 0
	variable["value"] = value
	emit_signal("variable_changed", variable_slug)

func previous_option(variable_slug : String) -> void:
	var variable : Dictionary = variables[variable_slug]
	var option_count : int = variable["options"].size()
	var value : int = variable["value"]
	value -= 1
	if value < 0:
		value = option_count - 1
	variable["value"] = value
	emit_signal("variable_changed", variable_slug)

func next_avatar(variable_slug : String) -> void:
	var variable : Dictionary = variables[variable_slug]
	var option_count : int = SPRITE_CHARACTERS.get_size().x / 16.0
	var value : int = variable["value"]
	value += 1
	if value >= option_count:
		value = 0
	variable["value"] = value
	emit_signal("variable_changed", variable_slug)

func previous_avatar(variable_slug : String) -> void:
	var variable : Dictionary = variables[variable_slug]
	var option_count : int = SPRITE_CHARACTERS.get_size().x / 16.0
	var value : int = variable["value"]
	value -= 1
	if value < 0:
		value = option_count - 1
	variable["value"] = value
	emit_signal("variable_changed", variable_slug)

func up() -> void:
	current_child -= 1
	if current_child < 0:
		current_child = get_current_children().size() - 1
	if get_child_type(get_current_children()[current_child]) == "text" or get_child_type(get_current_children()[current_child]) == "warn":
		current_child = get_current_children().size() - 1
	move_cursor()
	SoundMaster.play_sound("ui_move")

func down() -> void:
	current_child += 1
	if current_child >= get_current_children().size():
		current_child = 0
	if get_child_type(get_current_children()[current_child]) == "text" or get_child_type(get_current_children()[current_child]) == "warn":
		current_child += 1
	move_cursor()
	SoundMaster.play_sound("ui_move")

func left_or_right(left : bool) -> void:
	var menu_item_name : String = get_current_children()[current_child]
	var menu_item : Dictionary = items[menu_item_name]
	if menu_item["type"] == "variable":
		var variable_name : String = menu_item["variable_name"]
		var variable : Dictionary = variables[variable_name]
		match variable["type"]:
			"volume":
				if left: decrease_volume(variable_name)
				else: increase_volume(variable_name)
			"select":
				if left: previous_option(variable_name)
				else: next_option(variable_name)
			"avatar":
				if left: previous_avatar(variable_name)
				else: next_avatar(variable_name)
		SoundMaster.play_sound("ui_move")

func accept() -> void:
	var slug : String = get_current_menu_child_slug(current_child)
	if slug == "back":
		back()
	elif is_child_variable(slug):
		var variable_name : String = items[slug]["variable_name"]
		var variable_type : String = variables[variable_name]["type"]
		if variable_type == "tickbox":
			toggle_tickbox(variable_name)
			SoundMaster.play_sound("ui_select")
	elif is_child_button(slug):
		emit_signal("button_pressed", slug)
		SoundMaster.play_sound("ui_select")
	elif is_child_menu(slug):
		current_item = slug
		current_child = 0
		if get_child_type(get_current_children()[current_child]) == "text" or get_child_type(get_current_children()[current_child]) == "warn":
			current_child += 1
		move_cursor()
		SoundMaster.play_sound("ui_select")

func back() -> void:
	var item : Dictionary = get_current_item()
	if item.has("parent"):
		current_item = item["parent"]
		current_child = 0
		move_cursor()
		SoundMaster.play_sound("ui_back")
	else:
		emit_signal("back_from_root")

func _input(event : InputEvent) -> void:
	if not active: return
	get_tree().set_input_as_handled()
	if Input.is_action_just_pressed("ui_up"):
		up()
	elif Input.is_action_just_pressed("ui_down"):
		down()
	elif Input.is_action_just_pressed("ui_left"):
		left_or_right(true)
	elif Input.is_action_just_pressed("ui_right"):
		left_or_right(false)
	elif Input.is_action_just_pressed("ui_accept"):
		accept()
	elif Input.is_action_just_pressed("ui_cancel"):
		back()
	resize()
	update()
