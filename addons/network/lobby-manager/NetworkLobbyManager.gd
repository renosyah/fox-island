extends Node

const host_id = 1

# broadcast signal with data
# array of network player
signal lobby_player_update(players)
signal all_player_ready

signal on_host_player_connected
signal on_client_player_connected
signal on_player_disconnected(networkPlayer)
signal on_host_disconnected
signal connection_closed

var player_name :String = ""
var configuration :NetworkConfiguration
var argument :Dictionary = {}

# array of player joined in lobby
# in dictionary format
var _network_player :NetworkPlayer = NetworkPlayer.new()
var _lobby_players :Array = []
var _server_advertiser :ServerAdvertiser
var _exit_delay :Timer

onready var _network :Node = get_node_or_null("/root/Network")

# call to initiate lobby
func init_lobby():
	_lobby_players.clear()
	
	if is_any_params_null():
		return
		
	_network_player.player_name = player_name
		
	if configuration is NetworkServer:
		_init_host()
		
	elif configuration is NetworkClient:
		_init_join()
		
# call if player ready
func set_ready():
	if is_any_params_null():
		return
		
	if not is_network_on():
		return
		
	if is_server():
		_request_update_player_joined_status(
			_network_player.player_network_unique_id, _network_player.to_dictionary()) 
	else:
		rpc_id(host_id, "_request_update_player_joined_status",
			_network_player.player_network_unique_id, _network_player.to_dictionary())
	
func get_players() ->Array:
	var players :Array = []
	for i in _lobby_players:
		var player = NetworkPlayer.new()
		player.from_dictionary(i)
		players.append(player)
		
	return players
	
func get_id() -> int:
	return _network_player.player_network_unique_id
	
func _ready():
	_setup_lobby()
	
func _setup_lobby():
	add_child(_network_player)
	
	_server_advertiser = preload("res://addons/LANServerBroadcast/server_advertiser/server_advertiser.tscn").instance()
	add_child(_server_advertiser)
	
	_exit_delay = Timer.new()
	_exit_delay.one_shot = true
	_exit_delay.wait_time = 1.0
	add_child(_exit_delay)
	
	
################################################################
# host player section
func _init_host():
	if not _network.is_connected("server_player_connected", self ,"_server_player_connected"):
		_network.connect("server_player_connected", self ,"_server_player_connected")
		
	var _configuration :NetworkServer = configuration as NetworkServer
	var err = _network.create_server(_configuration.max_player, _configuration.port, _network_player.player_name)
	if err != OK:
		return
		
	init_connection_watcher()
	
func _server_player_connected(_player_network_unique_id : int, _network_player :NetworkPlayer):
	_network_player.player_network_unique_id = _player_network_unique_id
	
	_server_advertiser.setup()
	_server_advertiser.serverInfo["name"] = _network_player.player_name
	_server_advertiser.serverInfo["port"] = configuration.port
	_server_advertiser.serverInfo["public"] = true
	_server_advertiser.serverInfo["player"] = _lobby_players.size()
	_server_advertiser.serverInfo["max_player"] = configuration.max_player
	
	_request_append_player_joined(_player_network_unique_id, _network_player.to_dictionary())
	emit_signal("on_host_player_connected")
	
################################################################
# join player section
func _init_join():
	if not _network.is_connected("client_player_connected", self , "_client_player_connected"):
		_network.connect("client_player_connected", self , "_client_player_connected")
	
	var _configuration :NetworkClient = configuration as NetworkClient
	var err = _network.connect_to_server(_configuration.ip, _configuration.port, _network_player.player_name)
	if err != OK:
		return
		
	init_connection_watcher()
	
	
func _client_player_connected(_player_network_unique_id : int, _network_player :NetworkPlayer):
	_network_player.player_network_unique_id = _player_network_unique_id
	rpc_id(host_id, "_request_append_player_joined", _player_network_unique_id, _network_player.to_dictionary())
	emit_signal("on_client_player_connected")
	
################################################################
# lobby rpc function
remote func _request_append_player_joined(from : int, data :Dictionary):
	for i in _lobby_players:
		if i["player_network_unique_id"] == data["player_network_unique_id"]:
			_lobby_players.erase(i)
			break
			
	_lobby_players.append(data)
	_server_advertiser.serverInfo["player"] = _lobby_players.size()
	
	rpc("_update_player_joined", _lobby_players)
	
remote func _request_erase_player_joined(data : Dictionary):
	for i in _lobby_players:
		if i["player_network_unique_id"] == data["player_network_unique_id"]:
			_lobby_players.erase(i)
			break
			
	_server_advertiser.serverInfo["player"] = _lobby_players.size()
	rpc("_update_player_joined", _lobby_players)
	
remote func _request_update_player_joined_status(from : int, data : Dictionary):
	for i in _lobby_players:
		if i["player_network_unique_id"] == data["player_network_unique_id"]:
			i["player_status"] = NetworkPlayer.PLAYER_STATUS_READY
			break
			
	rpc("_update_player_joined", _lobby_players)
	
remotesync func _update_player_joined(data : Array):
	if not is_server():
		_lobby_players = data
		
	_lobby_players.sort_custom(MyCustomSorter, "sort")
	_broadcast_players_update()
	
remotesync func _kick_player(data : Dictionary):
	for i in _lobby_players:
		if i["player_network_unique_id"] == data["player_network_unique_id"]:
			_lobby_players.erase(i)
			break
			
	if data["player_network_unique_id"] == _network_player.player_network_unique_id:
		_network.disconnect_from_server()
		return
		
	_broadcast_players_update()
	
func _broadcast_players_update():
	emit_signal("lobby_player_update", get_players())
	
	for i in _lobby_players:
		if i["player_status"] != NetworkPlayer.PLAYER_STATUS_READY:
			return
			
	emit_signal("all_player_ready")

################################################################
# network connection watcher
# for both client and host
func init_connection_watcher():
	if not _network.is_connected("server_disconnected", self , "_server_disconnected"):
		_network.connect("server_disconnected", self , "_server_disconnected")
	
	if not _network.is_connected("connection_closed", self , "_connection_closed"):
		_network.connect("connection_closed", self , "_connection_closed")
	
	if not _network.is_connected("player_disconnected", self, "_on_player_disconnected"):
		_network.connect("receive_player_info", self,"_on_receive_player_info")
	
func _on_player_disconnected(_player_network_unique_id : int):
	_network.request_player_info(_player_network_unique_id)
	
func _on_receive_player_info(_player_network_unique_id : int, data :NetworkPlayer):
	emit_signal("on_player_disconnected", data)
	
func _server_disconnected():
	_network_player = null
	configuration = null
	emit_signal("on_host_disconnected")
	
func _connection_closed():
	_network_player = null
	configuration = null
	emit_signal("connection_closed")
	
################################################################
# utils
class MyCustomSorter:
	static func sort(a, b):
		if a["player_network_unique_id"] < b["player_network_unique_id"]:
			return true
		return false
		
# network utils code
func is_server():
	if not is_network_on():
		return false
		
	if not get_tree().is_network_server():
		return false
		
	return true
	
func is_network_on() -> bool:
	if not get_tree().network_peer:
		return false
		
	if get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED:
		return false
		
	return true
	
func is_any_params_null() -> bool:
	var checks = [
		is_instance_valid(_network),
		is_instance_valid(configuration)
	]
	return (false in checks)
	
