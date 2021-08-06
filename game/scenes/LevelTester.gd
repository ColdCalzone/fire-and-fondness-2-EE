extends Node2D

onready var board = $Board
onready var loader = $Loader
onready var ui = $UI/InGameUI
#This feels unclean but idk what else to do
var player = false
var partner = false

const OBJ_TUTORIAL = preload("res://objects/Tutorial.tscn")

const BACKGROUNDS = {
	"squares" : preload("res://objects/backgrounds/Squares.tscn"),
	"chevrons" : preload("res://objects/backgrounds/Chevrons.tscn"),
	"diamonds" : preload("res://objects/backgrounds/Diamonds.tscn"),
	"mines" : preload("res://objects/backgrounds/Mines.tscn"),
	"cluster" : preload("res://objects/backgrounds/Cluster.tscn"),
	"worm" : preload("res://objects/backgrounds/Worms.tscn"),
	"wavy" : preload("res://objects/backgrounds/Wavy.tscn"),
	"wavy_alt" : preload("res://objects/backgrounds/Wavy_Alt.tscn"),
	"wonks" : preload("res://objects/backgrounds/Wonks.tscn"),
	"lines" : preload("res://objects/backgrounds/Lines.tscn"),
	"plane" : preload("res://objects/backgrounds/Wavy_Plane.tscn"),
	"flag" : preload("res://objects/backgrounds/Flag.tscn"),
	"none" : null
}

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		#Levels.currently_editing = false
		get_tree().change_scene("res://scenes/LevelEditor.tscn")

func _ready():
	if Levels.currently_editing:
		#this checks for the existance of players and partners,
		#without them the level crashes
		for item in Levels.editing_level["objects"]:
			if item["type"] == "player":
				if item.has("fake_partner") and item["fake_partner"] == true:
					partner = true
				else:
					player=true
			if item["type"] == "partner":
				partner=true
		if player and partner:
			loader.load_level(Levels.editing_level)
			loader.setup_level()
			board.ui = ui
			# T U T O R I A L S
			if Levels.editing_level.has("tutorial") and not Settings.skip_tutorials and not (Levels.editing_level["tutorial"].empty()):
				#print(Levels.editing_level["tutorial"] == {})
				#print(Levels.editing_level["tutorial"])
				var tutorial_data : Dictionary = Levels.editing_level["tutorial"]
				var tutorial_slug : String = Levels.editing_level["slug"]
				var tutorial = OBJ_TUTORIAL.instance()
				tutorial.slug = tutorial_slug
				add_child(tutorial)
				tutorial.set_label_title(tutorial_data["title"])
				tutorial.set_label_body(tutorial_data["body"])
				tutorial.resize()
				get_tree().paused = true
			# A A  A A  AA A A A A 
			board.start_game()
			if Settings.background_enabled:
				if not Levels.editing_level["flags"]["joke"]:
					var background = BACKGROUNDS[Levels.editing_level["background"]].instance() if not Levels.editing_level["background"] == "none" else null
					if not background == null:
						add_child(background)
					var background_slug = Levels.editing_level["background"]
					# Oh I hate this. When did I write this? I deserve the death
					#sentence.
					if background_slug == "flag" or background_slug == "lines" or background_slug == "wavy_alt" or background_slug == "plane" or background_slug == "wavy" or background_slug == "squares" or background_slug == "wonks":
						background.scale = Vector2(0.5, 0.5)
		#return to the editor if you're dumb enough to not make a real level
		else:
			get_tree().change_scene("res://scenes/LevelEditor.tscn")
