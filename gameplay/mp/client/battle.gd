extends BaseGameplay

onready var players_holder = $players

# Called when the node enters the scene tree for the first time.
func _ready():
	.init_characters(players_holder)
	
func all_player_ready():
	.all_player_ready()
	_unit.is_dead = false
	_unit.translation = _map.get_recomended_spawn_position()
	
func _process(delta):
	_camera.facing_direction = _ui.camera_input_direction()
	_camera.translation = _unit.translation
	_unit.move_direction = _ui.joystick_move_direction()
	
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
	

