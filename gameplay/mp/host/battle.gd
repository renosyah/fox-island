extends BaseGameplay

onready var players_holder = $players
onready var enemy_spawner_timer = $enemy_spawner_timer
onready var enemy_holder = $enemies

# Called when the node enters the scene tree for the first time.
func _ready():
	NetworkLobbyManager.set_host_ready()
	
func all_player_ready():
	.all_player_ready()
	init_characters(players_holder)

func _process(delta):
	if not is_instance_valid(_unit):
		return
		
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
		
	if enemy_holder.get_child_count() > 2:
		return
		
	var target :NodePath = players_holder.get_child(rand_range(0, players_holder.get_child_count())).get_path()
		
	if randf() < 0.5:
		spawn_enemy_on_ship(GDUUID.v4(), enemy_holder.get_path(), _map.get_random_radius_pos(), target)
		return
		
	spawn_enemy_on_raft(GDUUID.v4(), enemy_holder.get_path(), _map.get_random_radius_pos(), target)
























