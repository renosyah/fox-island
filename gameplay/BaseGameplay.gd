extends Node
class_name BaseGameplay

export var ui :Resource

func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	init_connection_watcher()
	load_map()
	setup_ui()
	setup_camera()
	setup_day_night_dome()
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
		
func on_back_pressed():
	on_exit_game_session()
	
################################################################
# map
var _map :BaseMap

func load_map():
	_map = preload("res://map/test_map/test_map.tscn").instance()
	add_child(_map)
	_map.connect("on_generate_map_completed", self, "on_generate_map_completed")
	_map.map_seed = Global.mp_game_data["seed"]
	_map.generate_map()
	
func on_generate_map_completed():
	pass
	
################################################################
# ui
var _ui :BaseUi

func setup_ui():
	_ui = preload("res://gameplay/mp/ui/ui.tscn").instance()
	add_child(_ui)
	
################################################################
# camera
var _camera :RotatingCamera

func setup_camera():
	_camera = preload("res://assets/rotating-camera/rotating-camera.tscn").instance()
	add_child(_camera)
	_camera.translation.y = 5.0
	
################################################################
# directional light
var _day_night_dome : DayNightDome

func setup_day_night_dome():
	_day_night_dome = preload("res://assets/day-night/day_night_dome.tscn").instance()
	add_child(_day_night_dome)

################################################################
# network connection watcher
# for both client and host
func init_connection_watcher():
	Network.connect("server_disconnected", self , "_server_disconnected")
	Network.connect("connection_closed", self , "_connection_closed")
	
	# if some player decide or happen to be disconect
	Network.connect("player_disconnected", self, "_on_player_disconnected")
	Network.connect("receive_player_info", self,"_on_receive_player_info")
	
func _on_player_disconnected(_player_network_unique_id : int):
	Network.request_player_info(_player_network_unique_id)
	
func _on_receive_player_info(_player_network_unique_id : int, data :NetworkPlayer):
	on_player_disynchronize(data.player_name)
	
func _server_disconnected():
	on_host_disconnected()
	
func _connection_closed():
	pass
	
func on_player_disynchronize(_player_name : String):
	pass
	
func on_host_disconnected():
	pass
	
################################################################
# client pooling request
onready var latency_delay = Network.LATENCY_DELAY
var network_timmer : Timer

func init_client():
	if is_server():
		return
		
	network_timmer = Timer.new()
	network_timmer.wait_time = latency_delay
	network_timmer.connect("timeout", self , "on_client_pool_network_request")
	network_timmer.autostart = true
	add_child(network_timmer)
	
func on_client_pool_network_request():
	# send request every latency
	# to server for commanding
	# client unit
	pass
	
################################################################
# exit
func on_exit_game_session():
	Network.disconnect_from_server()
	get_tree().change_scene("res://menu/lobby/lobby.tscn")
	
################################################################
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
	
################################################################




















