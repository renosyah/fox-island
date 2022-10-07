extends BaseGameplay

var _unit :BaseUnit

onready var fox = $fox
onready var fox_2 = $fox2

# Called when the node enters the scene tree for the first time.
func _ready():
	_unit = fox_2
	init_client()
	
func on_generate_map_completed():
	.on_generate_map_completed()
	fox.is_dead = false
	fox_2.is_dead = false
	
func _process(delta):
	_camera.facing_direction = _ui.camera_control.get_facing_direction()
	_camera.translation = _unit.translation
	
func on_client_pool_network_request():
	if not is_network_on():
		return
		
	var command :Dictionary = {
		"command_move_direction": _ui.joystick_move_direction(),
		"command_facing_direction": _camera.get_facing_direction(),
		"command_atack": _ui.is_fire_pressed(),
		"command_jump" :_ui.is_jump_pressed(),
		"command_camera_basis": _camera.get_camera_basis(),
	}
	rpc_unreliable_id(Network.PLAYER_HOST_ID, "_send_command", _unit.get_path(), command)
	
