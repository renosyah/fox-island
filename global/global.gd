extends Node

const DEKSTOP =  ["Server", "Windows", "WinRT", "X11"]

################################################################
# sound
var sound_amplified :float = 5.0 if OS.get_name() in DEKSTOP else 10.0

################################################################
# player
const player_save_file = "player.data"
var player :PlayerData = PlayerData.new()

################################################################

func _ready():
	player.player_name = RandomNameGenerator.generate()
	#player.load_data(player_save_file)
