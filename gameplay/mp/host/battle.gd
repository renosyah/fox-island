extends BaseGameplay

var _unit :BaseUnit

onready var fox = $fox
onready var fox_2 = $fox2
onready var fox_on_raft = $"fox-on-raft"

# Called when the node enters the scene tree for the first time.
func _ready():
	_unit = fox
	_unit.enable_walk_sound = true
	
func on_generate_map_completed():
	.on_generate_map_completed()
	fox.is_dead = false
	fox_2.is_dead = false
	
	_unit.set_network_master(Network.get_local_network_player().player_network_unique_id)
	_unit.translation = _map.get_recomended_spawn_position()
	
	fox_on_raft.set_spawn_pos(Vector3(-50, _map.get_water_height(), -50))
	
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
	






















