extends BaseGameplay

var _unit :BaseUnit

onready var fox = $fox
onready var fox_2 = $fox2

# Called when the node enters the scene tree for the first time.
func _ready():
	_unit = fox
	_unit.enable_walk_sound = true
	
func on_generate_map_completed():
	.on_generate_map_completed()
	
	fox.player = PlayerData.new()
	
	fox.is_dead = false
	fox_2.is_dead = false
	
	fox.translation = _map.get_recomended_spawn_position()
	fox_2.translation = _map.get_recomended_spawn_position()
	
func _process(delta):
	_camera.facing_direction = _ui.camera_facing_direction()
	_camera.translation = _unit.translation
	var command :Dictionary = {
		"command_move_direction": _ui.joystick_move_direction(),
		"command_facing_direction":_camera.get_facing_direction(),
		"command_atack": _ui.is_fire_pressed(),
		"command_jump" :_ui.is_jump_pressed(),
		"command_camera_basis": _camera.get_camera_basis(),
	}
	_send_command(_unit.get_path(), command)
	
remote func _send_command(_to_unit :NodePath, _command : Dictionary):
	var to_unit = get_node_or_null(_to_unit)
	if not is_instance_valid(to_unit):
		return
		
	if to_unit is BaseGroundUnit:
		to_unit.camera_basis = _command["command_camera_basis"]
		
	to_unit.move_direction = _command["command_move_direction"]
	to_unit.facing_direction = _command["command_facing_direction"]
	
	if _command["command_atack"]:
		to_unit.attack()
		
	if _command["command_jump"] and to_unit.has_method("jump"):
		to_unit.jump()

