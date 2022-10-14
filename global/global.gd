extends Node

################################################################
# sound
var sound_amplified :float = 5.0

################################################################
# player
const player_save_file = "player.data"
var player :PlayerData = PlayerData.new()

################################################################

func _ready():
	player.player_name = RandomNameGenerator.generate()
	#player.load_data(player_save_file)
