extends BaseGameplay

var _unit :BaseUnit

onready var players_holder = $players

# Called when the node enters the scene tree for the first time.
func _ready():
	init_characters()
	
func init_characters():
	var players = NetworkLobbyManager.get_players()
	for i in players:
		var fox = fox_scene.instance()
		var id :String = str(i.player_network_unique_id)
		
		if i.player_network_unique_id == NetworkLobbyManager.get_id():
			_unit = fox
			_unit.enable_hp_bar = false
			_unit.enable_name_tag = false
			
		fox.player.player_id = id
		fox.player.player_name = i.player_name
		fox.player.player_team = 1
		fox.name = id
		fox.set_network_master(i.player_network_unique_id)
		players_holder.add_child(fox)
		
	_unit.enable_walk_sound = true
	_unit.connect("on_take_damage", self, "on_unit_on_take_damage")
	_unit.connect("on_dead", self ,"on_unit_on_dead")
	_ui.update_bar(_unit.hp, _unit.max_hp)
	_ui.set_player_name(_unit.player.player_name)
	
func on_unit_on_take_damage(_current_unit :BaseUnit, _damage : int, _hit_by :PlayerData):
	_ui.update_bar(_current_unit.hp, _current_unit.max_hp)
	
func on_unit_on_dead(_current_unit :BaseUnit, _hit_by :PlayerData):
	_ui.show_deadscreen()
	_ui.update_bar(0, _current_unit.max_hp)
	
func on_respawn_press():
	_unit.reset()
	_unit.translation = _map.get_recomended_spawn_position()
	
func all_player_ready():
	.all_player_ready()
	
	_unit.translation = _map.get_recomended_spawn_position()
	
func _process(delta):
	_camera.facing_direction = _ui.camera_facing_direction()
	_camera.translation = _unit.translation
	_unit.move_direction = _ui.joystick_move_direction()
	_unit.facing_direction = _camera.get_facing_direction()
	
	if _unit is BaseGroundUnit:
		_unit.camera_basis = _camera.get_camera_basis()
	
func on_jump_on_press():
	.on_jump_on_press()
	_unit.jump()
	
func on_dodge_on_press():
	.on_dodge_on_press()
	_unit.roll()
	
func on_fast_attack_on_press():
	.on_fast_attack_on_press()
	_unit.fast_attack()
	
func on_heavy_attack_on_press():
	.on_heavy_attack_on_press()
	_unit.heavy_attack()
	

