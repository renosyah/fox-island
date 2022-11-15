extends BaseGameplay

onready var players_holder = $players

onready var ally_holder = $allies
var allies_ai :Array = []
var mode_follow :bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	.init_characters(players_holder)
	
func _process(delta):
	_camera.facing_direction = _ui.camera_input_direction()
	_camera.translation = _unit.translation
	_unit.move_direction = _ui.joystick_move_direction()
	
	if _unit is BaseGroundUnit:
		_unit.camera_basis = _camera.get_camera_basis()
		
	_ui.set_action_enable(_unit.can_attack, _unit.can_roll)
	_ui.show_call_ally_button(allies_ai.size() < 3)
	
	if _unit.is_dead:
		return
		
	if mode_follow:
		for i in allies_ai:
			i.move_to = _unit.global_transform.origin + _unit.get_velocity() * 6
	else:
		var aiming_data :CameraAimingData = _camera.get_camera_aiming_at(
		_ui.get_crosshair_position()
		)
		if aiming_data.distance < 100:
			for i in allies_ai:
				i.move_to = aiming_data.position
				
func all_player_ready():
	.all_player_ready()
	_unit.is_dead = false
	_unit.translation = _map.get_recomended_spawn_position()
	
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
	
func on_call_ally():
	.on_call_ally()
	var node_name :String = GDUUID.v4()
	var parent :NodePath = ally_holder.get_path()
	var spawn_pos :Vector3 = _map.get_recomended_spawn_position()
	.spawn_ally(_unit.player, node_name, parent, spawn_pos)
	
func ally_spawned(ai :MobAi):
	.ally_spawned(ai)
	allies_ai.append(ai)
	
func on_ally_unit_dead(_ai :MobAi, _ais_unit :BaseUnit):
	set_process(false)
	allies_ai.erase(_ai)
	set_process(true)
	
	.on_ally_unit_dead(_ai, _ais_unit)
	
func on_command_ally():
	.on_command_ally()
	mode_follow = false
	
func on_command_follow():
	.on_command_follow()
	mode_follow = true
	

