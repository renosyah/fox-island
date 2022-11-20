extends Node
class_name BaseGameplay

const fox_scene = preload("res://entity/unit/ground-unit/fox/fox.tscn")
const fox_on_raft_scene = preload("res://entity/fox-on-raft/fox-on-raft.tscn")
const fox_on_ship_scene = preload("res://entity/fox-on-ship/fox-on-ship.tscn")

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
	_map = preload("res://map/spring_island/spring_map.tscn").instance()
	_map.map_seed = NetworkLobbyManager.argument["seed"]
	_map.map_size = 200
	_map.connect("on_generate_map_completed", self, "on_generate_map_completed")
	_map.connect("on_generating_map", self, "on_generating_map")
	add_child(_map)
	_map.generate_map()
	
	_ui.loading(true)
	
func on_generate_map_completed():
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
	_ui.connect("on_call_ally", self, "on_call_ally")
	_ui.connect("on_command_ally", self, "on_command_ally")
	_ui.connect("on_command_follow", self, "on_command_follow")
	_ui.connect("on_respawn_press", self, "on_respawn_press")
	_ui.connect("on_exit", self, "on_exit_game_session")
	
func on_jump_on_press():
	pass # Replace with function body.
	
func on_dodge_on_press():
	pass # Replace with function body.
	
func on_fast_attack_on_press():
	pass # Replace with function body
	
func on_heavy_attack_on_press():
	pass # Replace with function body.

func on_call_ally():
	pass # Replace with function body.

func on_command_ally():
	pass # Replace with function body.

func on_command_follow():
	pass # Replace with function body.
	

func on_respawn_press():
	_unit.reset()
	_ui.update_bar(_unit.max_hp, _unit.max_hp)
	
	rpc("_respawn", _unit.get_path(), _map.get_recomended_spawn_position())
	
remotesync func _respawn(_unit_node_path :NodePath, _respawn_position :Vector3):
	var _unit_node :BaseUnit = get_node_or_null(_unit_node_path)
	if not is_instance_valid(_unit_node):
		return
		
	_unit_node.translation = _respawn_position
	
################################################################
# camera
var _camera :RotatingCamera

func setup_camera():
	_camera = preload("res://assets/rotating-camera/rotating-camera.tscn").instance()
	add_child(_camera)
	
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
	NetworkLobbyManager.connect("on_player_disconnected", self, "on_player_disconnected")
	
func on_player_disconnected(_player_network :NetworkPlayer):
	pass
	
func connection_closed():
	get_tree().change_scene("res://menu/main-menu/main_menu.tscn")
	
func on_host_disconnected():
	get_tree().change_scene("res://menu/main-menu/main_menu.tscn")
	
func all_player_ready():
	_ui.loading(false)
	
################################################################
# gameplay
var _unit :BaseUnit
	
func init_characters(_parent :Node):
	var players = NetworkLobbyManager.get_players()
	
	for i in players:
		var fox = fox_scene.instance()
		var id :String = str(i.player_network_unique_id)
		
		if i.player_network_unique_id == NetworkLobbyManager.get_id():
			_unit = fox
			_unit.enable_hp_bar = false
			_unit.enable_name_tag = false
			
		fox.player.player_id = i.player_network_unique_id
		fox.player.player_name = i.player_name
		fox.player.player_team = 1
		fox.name = id
		
		fox.set_network_master(i.player_network_unique_id)
		_parent.add_child(fox)
	
	_unit.is_dead = true
	_unit.enable_walk_sound = true
	_unit.connect("on_take_damage", self, "on_unit_on_take_damage")
	_unit.connect("on_dead", self ,"on_unit_on_dead")
	
	_ui.update_bar(_unit.max_hp, _unit.max_hp)
	_ui.set_player_name(_unit.player.player_name)
	
func on_unit_on_take_damage(_current_unit :BaseUnit, _damage : int, _hit_by :PlayerData):
	_ui.update_bar(_current_unit.hp, _current_unit.max_hp)
	
func on_unit_on_dead(_current_unit :BaseUnit, _hit_by :PlayerData):
	_ui.show_deadscreen()
	_ui.update_bar(0, _current_unit.max_hp)
	
	
# enemy
func spawn_enemy_on_raft(_name :String, _parent :NodePath, _at :Vector3, _target :NodePath):
	if not is_server():
		return
		
	rpc("_spawn_enemy_on_raft",_name, _parent, _at, _target)
	
remotesync func _spawn_enemy_on_raft(_name :String, _parent :NodePath, _at :Vector3, _target :NodePath):
	var parent :Node = get_node_or_null(_parent)
	if not is_instance_valid(parent):
		return
		
	var target :BaseUnit = get_node_or_null( _target)
	if not is_instance_valid(target):
		return
		
	var enemy = fox_on_raft_scene.instance()
	enemy.name = _name
	enemy.target = target
	enemy.is_server = is_server()
	enemy.enemy_level = _day_night_dome.day_passed + 1
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
		
	var target :BaseUnit = get_node_or_null( _target)
	if not is_instance_valid(target):
		return
		
	var enemy = fox_on_ship_scene.instance()
	enemy.name = _name
	enemy.target = target
	enemy.is_server = is_server()
	enemy.enemy_level = _day_night_dome.day_passed + 1
	parent.add_child(enemy)
	enemy.set_spawn_position(_at)
	
# outpost
func spawn_outpost(_outpost_parent :NodePath):
	var parent :Node = get_node_or_null(_outpost_parent)
	if not is_instance_valid(parent):
		return
		
	var rng = RandomNumberGenerator.new()
	rng.seed = NetworkLobbyManager.argument["seed"]
	
	var outpost_count = rng.randi_range(2, 4)
	for i in range(outpost_count):
		var outpos = preload("res://entity/fox-outpost-spawner/fox_outpost_spawner.tscn").instance()
		outpos.is_server = is_server()
		outpos.name = "outpost-" + str(i)
		outpos.connect("on_outpost_destroyed", self, "on_outpost_destroyed")
		parent.add_child(outpos)
		outpos.translation = _map.inland_positions[
			rng.randi_range(0 ,_map.inland_positions.size() - 1)
		]
	
func on_outpost_destroyed():
	pass
	
# ally
func spawn_ally(_owner: PlayerData, _node_name :String, _parent :NodePath, _at :Vector3):
	rpc("_spawn_ally", _owner.to_dictionary(),_node_name, _parent, _at)
	
remotesync func _spawn_ally(_owner : Dictionary, _node_name :String, _parent :NodePath, _at :Vector3):
	var parent :Node = get_node_or_null(_parent)
	if not is_instance_valid(parent):
		return
		
	var owner_data :PlayerData = PlayerData.new()
	owner_data.from_dictionary(_owner)
	owner_data.player_name = owner_data.player_name + "'s Party"
	
	var is_local_payer_is_owner :bool = (owner_data.player_id == NetworkLobbyManager.get_id())
	
	var fox = fox_scene.instance()
	fox.player = owner_data
	fox.name = _node_name
	fox.speed = 2
	fox.hp = 25
	fox.max_hp = 25
	fox.enable_name_tag = not is_local_payer_is_owner
	fox.enable_damage = true
	fox.set_network_master(owner_data.player_id)
	parent.add_child(fox)
	fox.translation = _at
	
	if is_local_payer_is_owner:
		var ai = preload("res://assets/mob-ai/mob_ai.tscn").instance()
		ai.enable_manual_turning = false
		ai.connect("on_unit_dead", self, "on_ally_unit_dead")
		fox.add_child(ai)
		
		ally_spawned(ai)
		
func ally_spawned(ai :MobAi):
	pass
	
func on_ally_unit_dead(_ai :MobAi, _ais_unit :BaseUnit):
	rpc("_despawn_ally", _ais_unit.get_path())
	
remotesync func _despawn_ally(_ally_unit_path :NodePath):
	var _ally_unit :BaseUnit = get_node_or_null(_ally_unit_path)
	if not is_instance_valid(_ally_unit):
		return
		
	_ally_unit.queue_free()
	
################################################################
# exit
func on_exit_game_session():
	Network.disconnect_from_server()
	
################################################################
# utils code
func get_rand_pos(from :Vector3) -> Vector3:
	var angle := rand_range(0, TAU)
	var distance := rand_range(3, 4)
	var posv2 = polar2cartesian(distance, angle)
	var posv3 = from + Vector3(posv2.x, 2.0, posv2.y)
	return posv3
	
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




















