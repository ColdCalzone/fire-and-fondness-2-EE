extends Node2D

const SPRITE_PIXEL = preload("res://sprites/pixel.png")

# I'm no good at ascii art

#  ______    ______
# /      \  /      \
#/        \/        \
#\                  /
# \                /
#  \              /
#   \            /
#    \          /
#     \        /
#      \      /
#       \    /
#        \  /
#         \/

const PATTERN_TRANS : Array = [
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2],
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2],
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2],
	[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
	[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
	[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
]

const PATTERN_ACE : Array = [
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2],
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2],
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
	[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
	[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
]

const PATTERN_ARO : Array = [
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
	[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
	[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2],
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2],
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2]
]

const PATTERN_NB : Array = [
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
	[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
	[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2],
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2],
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2]
]

const PATTERN_LESBIAN : Array = [
	[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
	[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
	[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2],
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2],
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2]
]

const PATTERN_DEMI : Array = [
	[3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0],
	[3,3,3,3,3,1,1,1,1,1,1,1,1,1,1,1],
	[3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2],
	[3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2],
	[3,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2],
	[3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2]
]

const PATTERN_BI : Array = [
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2],
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2],
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2],
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2]
]

var time : float = 0.0
var force_bloody : bool = false

func _draw() -> void:
	if not Settings.background_enabled: return
	for y in range(0, 9):
		for x in range(0, 16):
			var transform : Vector2 = Vector2(x*40, y*40) + Vector2(20, 10)
			var rotate : float = 0.0
			var scale : float = sin((time+x*2)/4.0) * 28.0
			var colour_index : int = (x) % 3
			var colour : Color
			if !force_bloody:
				match Settings.background_palette:
					5: colour = Settings.get_background_colours()[PATTERN_ACE[y][x]]
					6: colour = Settings.get_background_colours()[PATTERN_ARO[y][x]]
					7: colour = Settings.get_background_colours()[PATTERN_TRANS[y][x]]
					8: colour = Settings.get_background_colours()[PATTERN_NB[y][x]]
					9: colour = Settings.get_background_colours()[PATTERN_LESBIAN[y][x]]
					10: 
						# I just wanted black
						if PATTERN_DEMI[y][x] == 3:
							colour = Color.black
						else:
							colour = Settings.get_background_colours()[PATTERN_DEMI[y][x]]
					11: colour = Settings.get_background_colours()[PATTERN_BI[y][x]]
					_: colour = Settings.get_background_colours()[colour_index]
			else:
				match Settings.background_palette:
					5: colour = Settings.PALETTE_BLOODY[PATTERN_ACE[y][x]]
					6: colour = Settings.PALETTE_BLOODY[PATTERN_ARO[y][x]]
					7: colour = Settings.PALETTE_BLOODY[PATTERN_TRANS[y][x]]
					8: colour = Settings.PALETTE_BLOODY[PATTERN_NB[y][x]]
					9: colour = Settings.PALETTE_BLOODY[PATTERN_LESBIAN[y][x]]
					10:
					# I just wanted black
						if PATTERN_DEMI[y][x] == 3:
							colour = Color.black
						else:
							colour = Settings.PALETTE_BLOODY[PATTERN_DEMI[y][x]]
					11: colour = Settings.PALETTE_BLOODY[PATTERN_BI[y][x]]
					_: colour = Settings.PALETTE_BLOODY[colour_index]
			draw_set_transform(transform, rotate, Vector2.ONE * scale)
			draw_texture(SPRITE_PIXEL, Vector2(-0.5, sin(8)), colour)

func _process(delta):
	time += delta * Settings.get_background_speed_amount()*2
	update()
