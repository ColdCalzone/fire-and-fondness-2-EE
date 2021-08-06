extends Node

# Oh this is gonna suck
var SAVE_PATH : String = "user://save.json"

var level_progress : Dictionary
var tutorials_shown : Array
var new_game : bool

func init_level(level : String, modded_carryover : bool = false) -> void:
	var level_data : Dictionary = {
		"unlocked": false,
		"finished": false,
		"beaten": false,
		"best_time": -1,
		"got_flowers": false
	}
	if not modded_carryover:
		level_progress[level] = level_data
	else:
		if not level_progress.has(level):
			level_progress[level] = level_data

func new_game(modded_carryover : bool = false) -> void:
	if not modded_carryover:
		level_progress = {}
		tutorials_shown = []
		new_game = true
	for season in Levels.seasons:
		for level in Levels.get_season_levels(season):
			init_level(level, modded_carryover)
	level_progress["s1e1"]["unlocked"] = true
	save_game()

func load_game() -> void:
	var file : File = File.new()
	if file.file_exists(SAVE_PATH):
		file.open(SAVE_PATH, File.READ)
		var content : String = file.get_as_text()
		file.close()
		var json = JSON.parse(content).result
		level_progress = json["levels"]
		tutorials_shown = json["tutorials"]
		new_game = json["new_game"]
	else:
		if file.file_exists("user://save.json"):
			file.open("user://save.json", File.READ)
			var content : String = file.get_as_text()
			var json = JSON.parse(content).result
			file.close()
			level_progress = json["levels"]
			tutorials_shown = json["tutorials"]
			new_game = json["new_game"]
			if file.file_exists(OS.get_executable_path().get_base_dir() + "/mods/manifest.tres"):
				file.open(OS.get_executable_path().get_base_dir() + "/mods/manifest.tres", File.READ)
				
				var manifest = JSON.parse(file.get_as_text()).result

				new_game(manifest["carry_over"])
				file.close()
			else:
				file.open(SAVE_PATH, File.WRITE)
				file.store_string(content)
				file.close()
		else:
			new_game()

func save_game() -> void:
	var data : Dictionary = {
		"levels": level_progress,
		"tutorials": tutorials_shown,
		"new_game": new_game
	}
	var json = JSON.print(data)
	var file : File = File.new()
	file.open(SAVE_PATH, File.WRITE)
	file.store_string(json)
	file.close()

func get_level_best_time(level : String) -> int:
	return level_progress[level]["best_time"]

func update_level_progress(level : String, moves : int, flowers_collected : Array, flower_total : int) -> void:
	var progress : Dictionary = level_progress[level]
	progress["finished"] = true
	if moves < progress["best_time"] or progress["best_time"] == -1:
		progress["best_time"] = moves
		
	var flower_count : int 
	var best_flower_count : int
	flower_count = flowers_collected.count(true)
	if typeof(progress["got_flowers"]) == TYPE_ARRAY:
		best_flower_count = progress["got_flowers"].count(true)
	else:
		best_flower_count = 1 if progress["got_flowers"] else 0
	progress["beaten"] = true if flower_count >= flower_total or best_flower_count >= flower_total else false
	if flower_count > best_flower_count:
		if flower_total > 1:
			progress["got_flowers"] = flowers_collected
		else:
			progress["got_flowers"] = flowers_collected[0]
	level_progress[level] = progress
	new_game = false
	# Unlock the next level
	var next : String = Levels.get_next_scene(level)
	if Levels.scene_is_level(next):
		set_level_unlocked(next)
	else:
		# Really janky hack, but... is the scene _after_ the next one a level?
		var second_next : String = Levels.get_next_scene(next)
		if Levels.scene_is_level(second_next):
			set_level_unlocked(second_next)
		# Fine, whatever, just save the game
		else:
			save_game()

func set_level_unlocked(level : String) -> void:
	var progress : Dictionary = level_progress[level]
	progress["unlocked"] = true
	level_progress[level] = progress
	save_game()

func is_level_unlocked(level : String) -> bool:
	if level in level_progress:
		return level_progress[level]["unlocked"]
	else:
		return false

func is_level_finished(level : String) -> bool:
	if level in level_progress:
		return level_progress[level]["finished"]
	else:
		return false

func get_level_beat_par(level : String) -> bool:
	if level in level_progress:
		return get_level_best_time(level) <= Levels.get_level_par(level) and get_level_best_time(level) != -1
	else:
		return false

func get_level_got_flowers(level : String) -> Array:
	if level in level_progress:    
		if typeof(level_progress[level]["got_flowers"]) == TYPE_BOOL:
			return [level_progress[level]["got_flowers"]]
		else:
			return level_progress[level]["got_flowers"]
	else:
		return []

func get_level_is_beaten(level : String) -> bool:
	# there is no specific stat in the save for "beaten," so I have to add that
	# added
	if level in level_progress:    
		return level_progress[level]["beaten"]
	else:
		return false

func is_season_unlocked(season : String) -> bool:
	for level in Levels.get_season_levels(season):
		if is_level_unlocked(level):
			return true
	return false

func get_unlocked_levels_for_season(season : String) -> int:
	var result : int = 0
	for level in Levels.get_season_levels(season):
		if is_level_unlocked(level):
			result += 1
		else:
			break
	return result

func get_unlocked_seasons() -> int:
	var result : int = 0
	for season in Levels.seasons:
		if is_season_unlocked(season):
			result += 1
		else:
			break
	return result

func is_tutorial_shown(tutorial : String) -> bool:
	return tutorials_shown.has(tutorial)

func set_tutorial_shown(tutorial : String):
	tutorials_shown.append(tutorial)

func get_completion_rate() -> float:
	var total : float = 0
	var completed : float = 0
	for level in level_progress:
		if is_level_finished(level): completed += 1
		if get_level_beat_par(level): completed += 1
		if get_level_is_beaten(level): completed += 1
		if get_level_got_flowers(level).count(true) >= get_level_got_flowers(level).size(): completed += 1 
		total += 4
	return completed / total
	# magic number 5 = seasons in base game

func is_season_five_unlocked() -> bool:
	return get_completion_rate() >= 0.8

func is_season_six_unlocked() -> bool:
	return get_completion_rate() >= 1.0

func _ready() -> void:
	var file_name : String = "normal"
	var file = File.new()
	if file.file_exists(OS.get_executable_path().get_base_dir() + "/mods/manifest.tres"):
		file.open(OS.get_executable_path().get_base_dir() + "/mods/manifest.tres", File.READ)
		var manifest = JSON.parse(file.get_as_text()).result
		file.close()
		file_name = manifest["pack_name"].replace(" ", "_")
	SAVE_PATH = "user://save_" + file_name + ".json"
	load_game()
