extends Node


################################################################
# sound
var sound_amplified :float = 5.0

################################################################
# multiplayer connection and data
const MODE_HOST = 0
const MODE_JOIN = 1
var mode = MODE_HOST
	
var server = {
	ip = '127.0.0.1',
	port = 31400,
	max_player = 4,
}
var client = {
	ip = '',
	port = 31400,
	network_unique_id = 0,
}
var mp_players = []
var mp_game_data = {
	"seed" : 1
}
var mp_exception_message = ""
