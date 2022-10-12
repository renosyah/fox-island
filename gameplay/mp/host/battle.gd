extends BaseGameplay

var _unit :BaseUnit

onready var fox = $players/fox
onready var fox_2 = $players/fox2

onready var enemy_spawner_timer = $enemy_spawner_timer
onready var enemy_holder = $enemies

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
	
	enemy_spawner_timer.start()
	
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
	
func _on_enemy_spawner_timer_timeout():
	enemy_spawner_timer.start()
	
	if enemy_holder.get_child_count() > 5:
		return
		
	spawn_enemy(enemy_holder.get_path(), _map.get_random_radius_pos(), fox.get_path())
























