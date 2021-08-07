extends Node

onready var currently_editing : bool = false
onready var editing_level = null
onready var current_scene : String = ""
var joke_level : bool = false
var time_level : bool = false
var lol_level : bool = false

const season_files : Array = [
	"res://levels/season1.tres",
	"res://levels/season2.tres",
	"res://levels/season3.tres",
	"res://levels/season4.tres",
	"res://levels/season5.tres",
]

const level_files : Array = [
	"res://levels/season1/level1.tres",
	"res://levels/season1/level2.tres",
	"res://levels/season1/level3.tres",
	"res://levels/season1/level4.tres",
	"res://levels/season1/level5.tres",
	"res://levels/season1/level6.tres",
	"res://levels/season1/level7.tres",
	"res://levels/season2/level1.tres",
	"res://levels/season2/level2.tres",
	"res://levels/season2/level3.tres",
	"res://levels/season2/level4.tres",
	"res://levels/season2/level5.tres",
	"res://levels/season2/level6.tres",
	"res://levels/season2/level7.tres",
	"res://levels/season3/level1.tres",
	"res://levels/season3/level2.tres",
	"res://levels/season3/level3.tres",
	"res://levels/season3/level4.tres",
	"res://levels/season3/level5.tres",
	"res://levels/season3/level6.tres",
	"res://levels/season3/level7.tres",
	"res://levels/season4/level1.tres",
	"res://levels/season4/level2.tres",
	"res://levels/season4/level3.tres",
	"res://levels/season4/level4.tres",
	"res://levels/season4/level5.tres",
	"res://levels/season4/level6.tres",
	"res://levels/season4/level7.tres",
	"res://levels/season5/level1.tres",
	"res://levels/season5/level2.tres",
	"res://levels/season5/level3.tres",
	"res://levels/season5/level4.tres",
	"res://levels/season5/level5.tres",
	"res://levels/season5/level6.tres",
	"res://levels/season5/level7.tres"
]

const message_files : Array = [
	"res://levels/season1/s1end.tres",
	"res://levels/season2/s2end.tres",
	"res://levels/season3/s3end.tres",
	"res://levels/season4/s4end.tres",
	"res://levels/season4/s5teaser.tres",
	"res://levels/season4/s5unlocked.tres",
	"res://levels/season5/s5end.tres",
	"res://levels/season5/s5trueend.tres"
]

var modded_season_files : Array

var modded_level_files : Array

var modded_message_files : Array

var levels : Dictionary
var seasons : Dictionary
var messages : Dictionary

func load_data(path : String) -> Dictionary:
	var file := File.new()
	file.open(path, file.READ)
	var contents : String = file.get_as_text()
	var data : Dictionary = parse_json(contents)
	return data

func get_season_slug_by_index(index : int) -> String:
	return seasons.keys()[index]

func get_season_data(slug : String) -> Dictionary:
	return seasons[slug]

func get_season_title(slug : String) -> String:
	return get_season_data(slug)["title"]

func get_season_subtitle(slug : String) -> String:
	return get_season_data(slug)["subtitle"]

func get_season_levels(slug : String) -> Array:
	return get_season_data(slug)["levels"]

func get_season_level_count(slug : String) -> int:
	return get_season_data(slug)["levels"].size()

func get_level_slug_by_index(season_index : int, level_index : int) -> String:
	var season_slug : String = get_season_slug_by_index(season_index)
	var levels : Array = get_season_levels(season_slug)
	return levels[level_index]

func get_level_data(slug : String) -> Dictionary:
	return levels[slug]

func get_level_title(slug : String) -> int:
	return get_level_data(slug)["title"]

func get_level_subtitle(slug : String) -> int:
	return get_level_data(slug)["subtitle"]

func get_level_supertitle(slug : String) -> int:
	return get_level_data(slug)["supertitle"]

func get_level_par(slug : String) -> int:
	return get_level_data(slug)["par"]

func get_level_next(slug : String) -> String:
	# s5e7 is a special case, as there are two messages that we could go to
	if slug == "s5e7":
		if GameProgress.get_completion_rate() >= 1.0:
			return "s5trueend"
		else:
			return "s5end"
	return get_level_data(slug)["next"]

func get_message_data(slug : String) -> Dictionary:
	return messages[slug]

func get_message_title(slug : String) -> String:
	return get_message_data(slug)["title"]

func get_message_body(slug : String) -> String:
	return get_message_data(slug)["body"]

func get_message_next(slug : String) -> String:
	# s4end is a special case: if we've 100%'d the first four seasons, unlock s5 - if not, tease it
	if slug == "s4end":
		if GameProgress.is_season_five_unlocked():
			return "s5unlocked"
		else:
			return "s5teaser"
	# If not, process the message as usual
	var data : Dictionary = get_message_data(slug)
	if data.has("next"):
		return data["next"]
	return "NONE"

func message_has_next(slug : String) -> bool:
	# Again, special consideration for s4end
	if slug == "s4end":
		return true
	return get_message_data(slug).has("next")

func scene_is_level(slug : String) -> bool:
	return levels.has(slug)

func scene_is_message(slug : String) -> bool:
	return messages.has(slug)

func get_next_scene(slug : String) -> String:
	if scene_is_level(slug):
		return get_level_next(slug)
	elif scene_is_message(slug):
		return get_message_next(slug)
	return ""

func goto_scene(slug : String) -> void:
	current_scene = slug
	if scene_is_level(slug):
		GameProgress.set_level_unlocked(slug)
		get_tree().change_scene("res://scenes/LevelIntro.tscn")
	elif scene_is_message(slug):
		get_tree().change_scene("res://scenes/Message.tscn")

func new_game() -> void:
	current_scene = "s1e1"
	get_tree().change_scene("res://scenes/LevelIntro.tscn")

func dir_contents(path):
	var files : Array = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if file_name != ".." and file_name != ".":
					files += dir_contents(path + "/" + file_name)
			else:
				files.append(path + "/" + file_name)
			file_name = dir.get_next()
		return files
	else:
		print("An error occurred when trying to access the path.")
		

func _ready() -> void:
		
	for season_file in season_files:
		var data : Dictionary = load_data(season_file)
		seasons[data["slug"]] = data
	for level_file in level_files:
		var data : Dictionary = load_data(level_file)
		levels[data["slug"]] = data
	for message_file in message_files:
		var data : Dictionary = load_data(message_file)
		messages[data["slug"]] = data
	
	var mod_folder_content = dir_contents(OS.get_executable_path().get_base_dir() + "/mods")
	var filee = File.new()
	if mod_folder_content == null or mod_folder_content.empty():
		# Just in case, recursively make directories
		Directory.new().make_dir_recursive(OS.get_executable_path().get_base_dir() + "/mods")
		filee.open(OS.get_executable_path().get_base_dir() + "/mods/manifest_template.tres", File.WRITE)
		filee.store_string("{\n	\"pack_name\": \"name here\",\n	\"version\": \"0.0.0\",\n	\"subtitles\": [\"woah, this isn\'t normal!\", \"This is a mod!\", \"use this file as a template for creating mods\"],\n	\"carry_over\": false\n}")
		filee.close()
	elif filee.file_exists(OS.get_executable_path().get_base_dir() + "/mods/manifest.tres"):
		for file in mod_folder_content:
			var file_name = file.rsplit("/", true, 2)
			if file_name.size() > 1:
				if file_name[2].find("level") == 0:
					modded_level_files.append(file)
				if file_name[2].find("season") == 0:
					modded_season_files.append(file)
				if file_name[2].find("end") > -1:
					modded_message_files.append(file)
		modded_level_files.sort()
		modded_message_files.sort()
		modded_season_files.sort()
		for season_file in modded_season_files:
			var data : Dictionary = load_data(season_file)
			seasons[data["slug"]] = data
		for level_file in modded_level_files:
			var data : Dictionary = load_data(level_file)
			levels[data["slug"]] = data
		for message_file in modded_message_files:
			var data : Dictionary = load_data(message_file)
			messages[data["slug"]] = data
		#print(modded_messages)
