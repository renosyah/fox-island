extends BaseGameplay

onready var players_holder = $players
onready var outpost_holder = $outpost

onready var aim_indicator = $aim_indicator
onready var ally_holder = $allies
onready var unit_spotter = $unit_spotter

var allies_ai :Array = []
var mode_follow :bool = true
var outpost_remaining :int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	.init_characters(players_holder)
	unit_spotter.enemy_teams = [2]
	unit_spotter.ignores = [_map]
	
func _process(delta):
	_camera.facing_direction = _ui.camera_input_direction()
	_camera.translation = _unit.translation
	_unit.move_direction = _ui.joystick_move_direction()
	
	if _unit is BaseGroundUnit:
		_unit.camera_basis = _camera.get_camera_basis()
		
	_ui.set_action_enable(_unit.can_attack, _unit.can_roll)
	_ui.show_call_ally_button(allies_ai.size() <= 3)
	
	if _unit.is_dead:
		return
		
	if mode_follow:
		var player_pos :Vector3 = _unit.global_transform.origin + _unit.get_velocity() * 6
		unit_spotter.translation = player_pos
		
		var target :BaseUnit = unit_spotter.get_target()
		
		for i in allies_ai:
			i.move_to = target.global_transform.origin if target != null else player_pos
	else:
		var aiming_data :CameraAimingData = _camera.get_camera_aiming_at(
			_ui.get_crosshair_position(),
			players_holder.get_children() + 
			ally_holder.get_children()
		)
		var is_in_range :bool = aiming_data.distance < 25
		aim_indicator.show_aim_at(
			aiming_data, is_in_range
		)
		
		if not is_in_range:
			return
			
		for i in allies_ai:
			i.move_to = aiming_data.position
		
		 
func all_player_ready():
	.all_player_ready()
	_unit.is_dead = false
	_unit.translation = _map.get_recomended_spawn_position()
	
	.spawn_outpost(outpost_holder.get_path())
	outpost_remaining = outpost_holder.get_child_count()
	_ui.update_mission_info(outpost_remaining)
	
func on_outpost_destroyed():
	.on_outpost_destroyed()
	outpost_remaining -= 1
	_ui.update_mission_info(outpost_remaining)
	
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
	var spawn_pos :Vector3 = .get_rand_pos(_unit.transform.origin)
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
	aim_indicator.visible = true
	mode_follow = false
	
func on_command_follow():
	.on_command_follow()
	aim_indicator.visible = false
	mode_follow = true
	
func on_morning():
	.on_morning()
	for outpost in outpost_holder.get_children():
		outpost.outpost_light(false)
	
func on_night():
	.on_night()
	for outpost in outpost_holder.get_children():
		outpost.outpost_light(true)
	
	
	

