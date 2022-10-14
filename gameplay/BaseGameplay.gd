extends Node
class_name BaseGameplay

const fox_scene = preload("res://entity/unit/ground-unit/fox/fox.tscn")
const fox_on_raft_scene = preload("res://entity/fox-on-raft/fox-on-raft.tscn")
const fox_on_ship_scene = preload("res://entity/fox-on-ship/fox-on-ship.tscn")

export var ui :Resource

func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	init_connection_watcher()
	setup_ui()
	load_map()
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
#	var rng :RandomNumberGenerator  = RandomNumberGenerator.new()
#	rng.seed = Global.mp_game_data["seed"]
	
	_map = preload("res://map/spring_island/spring_map.tscn").instance()
	#_map.map_land_color = Color(rng.randf(),rng.randf(),rng.randf(),1.0)
	#_map.map_sand_color = Color(randf(),randf(),randf(),1.0)
	add_child(_map)
	_map.connect("on_generate_map_completed", self, "on_generate_map_completed")
	_map.connect("on_generating_map", self, "on_generating_map")
	_map.map_seed = NetworkLobbyManager.argument["seed"]
	_map.map_size = 200
	_map.generate_map()
	
	_ui.loading(true)
	
func on_generate_map_completed():
	_ui.loading(false)
	NetworkLobbyManager.set_ready()
	
func on_generating_map(message :String, progress, max_progress :int):
	_ui.loading_message(message, progress, max_progress)
	
	
################################################################
# ui
var _ui :BaseUi

func setup_ui():
	_ui = preload("res://gameplay/mp/ui/ui.tscn").instance()
	add_child(_ui)
	_ui.connect("on_jump_on_press", self, "on_jump_on_press")
	_ui.connect("on_dodge_on_press", self, "on_dodge_on_press")
	_ui.connect("on_fast_attack_on_press", self, "on_fast_attack_on_press")
	_ui.connect("on_heavy_attack_on_press", self, "on_heavy_attack_on_press")
	_ui.connect("on_respawn_press", self, "on_respawn_press")
	
func on_jump_on_press():
	pass # Replace with function body.
	
func on_dodge_on_press():
	pass # Replace with function body.
	
func on_fast_attack_on_press():
	pass # Replace with function body
	
func on_heavy_attack_on_press():
	pass # Replace with function body.
	
func on_respawn_press():
	pass
	
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
	_day_night_dome.connect("morning", self, "on_morning")
	_day_night_dome.connect("night", self, "on_night")
	
func on_morning():
	pass
	
func on_night():
	pass
	
################################################################
# network connection watcher
# for both client and host
func init_connection_watcher():
	NetworkLobbyManager.connect("on_host_disconnected", self, "on_host_disconnected")
	NetworkLobbyManager.connect("connection_closed", self, "connection_closed")
	NetworkLobbyManager.connect("all_player_ready", self, "all_player_ready")
	
	# if some player decide or happen to be disconect
	Network.connect("player_disconnected", self, "on_player_disconnected")
	Network.connect("receive_player_info", self,"on_receive_player_info")
	
func on_player_disconnected(_player_network_unique_id : int):
	Network.request_player_info(_player_network_unique_id)
	
func on_receive_player_info(_player_network_unique_id : int, data :NetworkPlayer):
	on_player_disynchronize(data.player_name)
	
func connection_closed():
	get_tree().change_scene("res://menu/main-menu/main_menu.tscn")
	
func on_player_disynchronize(_player_name : String):
	pass
	
func on_host_disconnected():
	get_tree().change_scene("res://menu/main-menu/main_menu.tscn")
	
func all_player_ready():
	pass
	
################################################################
# gameplay
func spawn_enemy_on_raft(_name :String, _parent :NodePath, _at :Vector3, _target :NodePath):
	if not is_server():
		return
		
	rpc("_spawn_enemy_on_raft",_name, _parent, _at, _target)

remotesync func _spawn_enemy_on_raft(_name :String, _parent :NodePath, _at :Vector3, _target :NodePath):
	var parent :Node = get_node_or_null(_parent)
	if not is_instance_valid(parent):
		return
		
	var enemy = fox_on_raft_scene.instance()
	enemy.name = _name
	enemy.target = _target
	enemy.is_server = is_server()
	parent.add_child(enemy)
	enemy.set_spawn_position(_at)
	
func spawn_enemy_on_ship(_name :String, _parent :NodePath, _at :Vector3, _target :NodePath):
	if not is_server():
		return
		
	rpc("_spawn_enemy_on_ship",_name, _parent, _at, _target)

remotesync func _spawn_enemy_on_ship(_name :String, _parent :NodePath, _at :Vector3, _target :NodePath):
	var parent :Node = get_node_or_null(_parent)
	if not is_instance_valid(parent):
		return
		
	var enemy = fox_on_ship_scene.instance()
	enemy.name = _name
	enemy.target = _target
	enemy.is_server = is_server()
	parent.add_child(enemy)
	enemy.set_spawn_position(_at)
	
	
################################################################
# exit
func on_exit_game_session():
	Network.disconnect_from_server()
	
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




















