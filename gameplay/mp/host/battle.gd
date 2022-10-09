extends BaseGameplay

var _unit :BaseUnit

onready var fox = $fox
onready var fox_2 = $fox2
onready var fox_3 = $fox3
onready var fox_3_mob_ai = $fox3/mob_ai

# Called when the node enters the scene tree for the first time.
func _ready():
	_unit = fox
	_unit.enable_walk_sound = true
	
func on_generate_map_completed():
	.on_generate_map_completed()
	fox.is_dead = false
	fox_2.is_dead = false
	fox_3.is_dead = false
	
	_unit.set_network_master(Network.get_local_network_player().player_network_unique_id)
	_unit.translation = _map.get_recomended_spawn_position()
	fox_3.translation = _map.get_recomended_spawn_position()
	
func _process(delta):
	_camera.facing_direction = _ui.camera_facing_direction()
	_camera.translation = _unit.translation
	_unit.move_direction = _ui.joystick_move_direction()
	_unit.facing_direction = _camera.get_facing_direction()
	
	if _unit is BaseGroundUnit:
		_unit.camera_basis = _camera.get_camera_basis()
		
	if _ui.is_fire_pressed():
		_unit.attack()
		
	if _ui.is_jump_pressed() and _unit.has_method("jump"):
		_unit.jump()
		
	if _ui.is_dodge_pressed() and _unit.has_method("dodge"):
		_unit.dodge()
		
	fox_3_mob_ai.destination = fox.translation
























