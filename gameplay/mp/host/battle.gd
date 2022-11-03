extends BaseGameplay

onready var players_holder = $players
onready var enemy_spawner_timer = $enemy_spawner_timer
onready var enemy_holder = $enemies

# aim arrow and location
onready var aim_locator = $aim_locator
onready var arrow = $arrow

# Called when the node enters the scene tree for the first time.
func _ready():
	.init_characters(players_holder)
	
func all_player_ready():
	.all_player_ready()
	_unit.is_dead = false
	_unit.translation = _map.get_recomended_spawn_position()
	enemy_spawner_timer.start()
	
	# exlude aim
	_camera.exclude_aim = [_unit]
	
func _process(delta):
	_camera.facing_direction = _ui.camera_facing_direction()
	_camera.translation = _unit.translation
	_unit.move_direction = _ui.joystick_move_direction()
	_unit.facing_direction = _camera.get_facing_direction()
	
	if _unit is BaseGroundUnit:
		_unit.camera_basis = _camera.get_camera_basis()
		
	# aim testing
	aim_locator.translation = _camera.get_camera_aim()
	arrow.translation = _camera.translation + Vector3(0, 5,-5)
	arrow.look_at(aim_locator.translation, Vector3.UP)
	
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
























