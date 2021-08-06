extends Node

onready var audio_flamethrower_fire = $Audio_Flamethrower_Fire
onready var audio_door_close = $Audio_Door_Close
onready var audio_door_open = $Audio_Door_Open
onready var audio_player_step1 = $Audio_Player_Step1
onready var audio_player_step2 = $Audio_Player_Step2
onready var audio_player_step3 = $Audio_Player_Step3
onready var audio_player_step4 = $Audio_Player_Step4
onready var audio_switch_pull1 = $Audio_Switch_Pull1
onready var audio_switch_pull2 = $Audio_Switch_Pull2
onready var audio_switch_pull3 = $Audio_Switch_Pull3
onready var audio_flower_pickup = $Audio_Flower_Pickup
onready var audio_teleport = $Audio_Teleport
onready var audio_mover_move = $Audio_Mover_Move
onready var audio_bomb_wick = $Audio_Bomb_Wick
onready var audio_bomb_explosion = $Audio_Bomb_Explosion
onready var audio_rock_break = $Audio_Rock_Break
onready var audio_ice_hiss = $Audio_Ice_Hiss
onready var audio_ice_melt = $Audio_Ice_Melt
onready var audio_trapdoor_click = $Audio_Trapdoor_Click
onready var audio_trapdoor_open = $Audio_Trapdoor_Open
onready var audio_squish = $Audio_Squish
onready var audio_fall = $Audio_Fall
onready var audio_rewind = $Audio_Rewind
onready var audio_dog_alert = $Audio_Dog_Alert
onready var audio_dog_catch = $Audio_Dog_Catch
onready var audio_dog_lose = $Audio_Dog_Lose
onready var audio_dog_nevermind = $Audio_Dog_Nevermind
onready var audio_dog_wake = $Audio_Dog_Wake
onready var audio_flamethrower_fake = $Audio_Flamethrower_Fake
onready var audio_intro = $Audio_Intro
onready var audio_ui_select = $Audio_UI_Select
onready var audio_ui_move = $Audio_UI_Move
onready var audio_ui_back = $Audio_UI_Back
onready var audio_youwin = $Audio_YouWin
onready var audio_gameover = $Audio_GameOver
onready var audio_bgm_a = $Audio_BGM_A
onready var audio_bgm_b = $Audio_BGM_B
onready var tween = $Tween

onready var sounds : Dictionary = {
	"flamethrower_fire": {"sound": audio_flamethrower_fire, "override": true},
	"door_close": {"sound": audio_door_close, "override": true},
	"door_open": {"sound": audio_door_open, "override": true},
	"teleport": {"sound": audio_teleport, "override": true},
	"mover_move": {"sound": audio_mover_move, "override": true},
	"flower_pickup": {"sound": audio_flower_pickup, "override": true},
	"bomb_wick": {"sound": audio_bomb_wick, "override": true},
	"bomb_explosion": {"sound": audio_bomb_explosion, "override": true},
	"rock_break": {"sound": audio_rock_break, "override": true},
	"ice_hiss": {"sound": audio_ice_hiss, "override": false},
	"ice_melt": {"sound": audio_ice_melt, "override": false},
	"trapdoor_click": {"sound": audio_trapdoor_click, "override": true},
	"trapdoor_open": {"sound": audio_trapdoor_open, "override": true},
	"squish": {"sound": audio_squish, "override": true},
	"fall": {"sound": audio_fall, "override": true},
	"rewind": {"sound": audio_rewind, "override": true},
	"dog_alert": {"sound": audio_dog_alert, "override": true},
	"dog_catch": {"sound": audio_dog_catch, "override": true},
	"dog_lose": {"sound": audio_dog_lose, "override": true},
	"dog_nevermind": {"sound": audio_dog_nevermind, "override": true},
	"dog_wake": {"sound": audio_dog_wake, "override": true},
	"flamethrower_fake": {"sound": audio_flamethrower_fake, "override": true},
	"level_intro": {"sound": audio_intro, "override": true},
	"ui_select": {"sound": audio_ui_select, "override": true},
	"ui_move": {"sound": audio_ui_move, "override": true},
	"ui_back": {"sound": audio_ui_back, "override": true},
	"you_win": {"sound": audio_youwin, "override": true},
	"gameover": {"sound": audio_gameover, "override": true}
}

onready var random_sounds : Dictionary = {
	"player_step": [audio_player_step1, audio_player_step2, audio_player_step3, audio_player_step4],
	"switch_pull": [audio_switch_pull1, audio_switch_pull2, audio_switch_pull3]
}

var music : Dictionary

var tracks : Array = ["title", "title_alt", "ingame_a", "ingame_b", "ingame_c", "ingame_d", "ingame_e"]
var ingame_tracks : Array = ["ingame_a", "ingame_b", "ingame_c", "ingame_d", "ingame_e"]
var ingame_track_number : int = 0

enum MUSIC_STATE {NOT_PLAYING, TITLE_MUSIC, INGAME_MUSIC}

var music_state : int = 0
var current_layer : int = 0

func play_sound(id : String) -> void:
	if sounds.has(id):
		if sounds[id]["sound"].playing == false or sounds[id]["override"] == true:
			sounds[id]["sound"].play()
	elif random_sounds.has(id):
		var sounds = random_sounds[id]
		var index = rand_range(0, sounds.size())
		sounds[index].play()

func stop_all_sounds() -> void:
	for sound in sounds:
		sounds[sound]["sound"].stop()

func play_title_music() -> void:
	# If we're already playing the title music, we don't need to do anything
	if music_state == MUSIC_STATE.TITLE_MUSIC:
		return
	tween.stop_all()
	change_layer_immediately(0)
	audio_bgm_a.stream = music["title"]
	audio_bgm_b.stream = music["title_alt"]
	audio_bgm_a.play()
	audio_bgm_b.play()
	music_state = MUSIC_STATE.TITLE_MUSIC

func start_ingame_music() -> void:
	# Music doesn't play on joke levels
	if Levels.joke_level:
		return
	music_state = MUSIC_STATE.INGAME_MUSIC
	change_layer_immediately(0)
	tween.stop_all()
	audio_bgm_a.stop()
	audio_bgm_b.stop()
	next_ingame_track()

func next_ingame_track() -> void:
	ingame_track_number += 1
	if ingame_track_number >= ingame_tracks.size():
		ingame_track_number = 0
		ingame_tracks.shuffle()
	tween.stop_all()
	var track : String = ingame_tracks[ingame_track_number]
	audio_bgm_a.stream = music[track]
	audio_bgm_a.play()

func change_layer(layer : int) -> void:
	current_layer = layer
	if layer == 0:
		tween.interpolate_property(audio_bgm_a, "volume_db", audio_bgm_a.volume_db, 0.0, 2.0, Tween.TRANS_QUAD, Tween.EASE_OUT)
		tween.interpolate_property(audio_bgm_b, "volume_db", audio_bgm_b.volume_db, -80.0, 2.0, Tween.TRANS_QUAD, Tween.EASE_IN)
	else:
		tween.interpolate_property(audio_bgm_a, "volume_db", audio_bgm_a.volume_db, -80.0, 2.0, Tween.TRANS_QUAD, Tween.EASE_IN)
		tween.interpolate_property(audio_bgm_b, "volume_db", audio_bgm_b.volume_db, 0.0, 2.0, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()

func change_layer_immediately(layer : int) -> void:
	current_layer = layer
	tween.stop_all()
	audio_bgm_a.volume_db = 0.0 if layer == 0 else -80.0
	audio_bgm_b.volume_db = 0.0 if layer == 1 else -80.0

func fade_out_music() -> void:
	tween.interpolate_property(audio_bgm_a, "volume_db", audio_bgm_a.volume_db, -80.0, 1.0, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.interpolate_property(audio_bgm_b, "volume_db", audio_bgm_b.volume_db, -80.0, 1.0, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()
	music_state = MUSIC_STATE.NOT_PLAYING

func stop_music() -> void:
	music_state = MUSIC_STATE.NOT_PLAYING
	tween.stop_all()
	audio_bgm_a.stop()
	audio_bgm_b.stop()

func _on_Audio_BGM_finished():
	if music_state == MUSIC_STATE.INGAME_MUSIC:
		next_ingame_track()

func load_track(name : String) -> AudioStream:
	var stream : AudioStream
	if OS.has_feature("web"):
		stream = load("res://music/web/" + name + ".ogg")
	else:
		stream = load("res://music/desktop/" + name + ".ogg")
	return stream

func load_music() -> void:
	for track_name in tracks:
		var stream : AudioStream = load_track(track_name)
		music[track_name] = stream

func _ready() -> void:
	load_music()
	ingame_tracks.shuffle()
