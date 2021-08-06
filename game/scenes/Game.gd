extends Node2D

const OBJ_TUTORIAL = preload("res://objects/Tutorial.tscn")
const OBJ_PAUSE = preload("res://objects/PauseScreen.tscn")
const OBJ_BACKGROUND_CHEVRONS = preload("res://objects/backgrounds/Chevrons.tscn")
const OBJ_BACKGROUND_DIAMONDS = preload("res://objects/backgrounds/Diamonds.tscn")
const OBJ_BACKGROUND_MINES = preload("res://objects/backgrounds/Mines.tscn")
const OBJ_BACKGROUND_WORMS = preload("res://objects/backgrounds/Worms.tscn")
const OBJ_BACKGROUND_CLUSTERS = preload("res://objects/backgrounds/Cluster.tscn")
const OBJ_BACKGROUND_WAVY = preload("res://objects/backgrounds/Wavy.tscn")
const OBJ_BACKGROUND_SQUARES = preload("res://objects/backgrounds/Squares.tscn")
const OBJ_BACKGROUND_WONK = preload("res://objects/backgrounds/Wonks.tscn")
const OBJ_BACKGROUND_FLAG = preload("res://objects/backgrounds/Flag.tscn")
const OBJ_BACKGROUND_LINES = preload("res://objects/backgrounds/Lines.tscn")
const OBJ_BACKGROUND_WAVY_ALT = preload("res://objects/backgrounds/Wavy_Alt.tscn")
const OBJ_BACKGROUND_PLANE = preload("res://objects/backgrounds/Wavy_Plane.tscn")

const OVERLAY = preload("res://objects/Scanline_Overlay.tscn")


var backgrounds = {
	"chevrons": OBJ_BACKGROUND_CHEVRONS,
	"diamonds": OBJ_BACKGROUND_DIAMONDS,
	"mines": OBJ_BACKGROUND_MINES,
	"worms": OBJ_BACKGROUND_WORMS,
	"clusters": OBJ_BACKGROUND_CLUSTERS,
	"wavy": OBJ_BACKGROUND_WAVY,
	"squares": OBJ_BACKGROUND_SQUARES,
	"wonks": OBJ_BACKGROUND_WONK,
	"flag": OBJ_BACKGROUND_FLAG,
	"lines": OBJ_BACKGROUND_LINES,
	"wavy_alt": OBJ_BACKGROUND_WAVY_ALT,
	"plane": OBJ_BACKGROUND_PLANE
}

onready var board = $Board
onready var loader = $Loader
onready var ui = $UI/InGameUI
# onready var ui = $InGameUI

var level_data : Dictionary

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("pause") and board.any_player_can_move():
		var pause = OBJ_PAUSE.instance()
		add_child(pause)
		get_tree().paused = true
	if event.is_action_pressed("restart_level") and board.any_player_can_move():
		get_tree().paused = true
		Overlay.transition_out()
		yield(Overlay, "transition_finished")
		get_tree().paused = false
		get_tree().reload_current_scene()

func check_for_tutorials() -> void:
	# Check to see if need to show a tutorial before we get started
	if level_data.has("tutorial") and not Settings.skip_tutorials and not level_data["tutorial"] == {}:
		var tutorial_data : Dictionary = level_data["tutorial"]
		var tutorial_slug : String = level_data["slug"]
		if not GameProgress.is_tutorial_shown(tutorial_slug) or Levels.currently_editing:
			var tutorial = OBJ_TUTORIAL.instance()
			tutorial.slug = tutorial_slug
			add_child(tutorial)
			tutorial.set_label_title(tutorial_data["title"])
			tutorial.set_label_body(tutorial_data["body"])
			tutorial.resize()
			get_tree().paused = true

func check_for_backgrounds() -> void:
	if level_data.has("background") and level_data.flags.has("joke") and not level_data.flags.joke:
		var background_slug : String = level_data["background"]
		if backgrounds.has(background_slug):
			var background = backgrounds[background_slug].instance()
			if background_slug == "flag" or background_slug == "lines" or background_slug == "wavy_alt" or background_slug == "plane" or background_slug == "wavy" or background_slug == "squares" or background_slug == "wonks":
				background.scale = Vector2(0.5,0.5)
			add_child(background)

func start_game() -> void:
	check_for_tutorials()
	board.start_game()

func _ready() -> void:
	level_data = Levels.get_level_data(Levels.current_scene)
	loader.load_level(level_data)
	loader.setup_level()
	check_for_backgrounds()
	ui.show_turn_count = GameProgress.is_level_finished(Levels.current_scene)
	# carrying over flowers between plays of a level
	if GameProgress.get_level_got_flowers(Levels.current_scene).size() > GameProgress.get_level_got_flowers(Levels.current_scene).count(true):
		for i in range(GameProgress.get_level_got_flowers(Levels.current_scene).size()):
			# haha code go brrr
			board.get_tree().get_nodes_in_group("flower")[i].collected = GameProgress.get_level_got_flowers(Levels.current_scene)[i]
			board.get_tree().get_nodes_in_group("flower")[i].refresh_on_board()
	board.ui = ui
	board.update_ui()
	if Settings.classic_mode:
		var shader = OVERLAY.instance()
		shader.position = Vector2(-100,-100)
		shader.name = "SHADER_OVERLAY"
		add_child(shader)
	SoundMaster.start_ingame_music()
	Overlay.transition_in()
	yield(Overlay, "transition_finished")
	start_game()
