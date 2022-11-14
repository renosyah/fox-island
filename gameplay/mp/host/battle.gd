extends BaseGameplay

onready var players_holder = $players
onready var enemy_holder = $enemies

onready var ally_holder = $allies
var allies_ai = []

onready var enemy_spawner_timer = $enemy_spawner_timer
onready var enemy_target_update_timer = $enemy_target_update_timer

# Called when the node enters the scene tree for the first time.
func _ready():
	.init_characters(players_holder)
	
	enemy_spawner_timer.connect("timeout", self, "on_enemy_spawner_timer_timeout")
	enemy_target_update_timer.connect("timeout", self, "on_enemy_target_update_timer_timeout")
	
func _process(delta):
	_camera.facing_direction = _ui.camera_input_direction()
	_camera.translation = _unit.translation
	_unit.move_direction = _ui.joystick_move_direction()
	
	if _unit is BaseGroundUnit:
		_unit.camera_basis = _camera.get_camera_basis()
		
	_ui.set_action_enable(_unit.can_attack, _unit.can_roll)
	
	# ally test orders
	var order_pos = _camera.get_camera_aiming_at(_ui.get_crosshair_position())
	var order_distance = _unit.global_transform.origin.distance_to(order_pos)
	if order_distance < 100:
		for i in allies_ai:
			i.move_to = order_pos
	
func all_player_ready():
	.all_player_ready()
	_unit.is_dead = false
	_unit.translation = _map.get_recomended_spawn_position()
	enemy_spawner_timer.start()
	enemy_target_update_timer.start()
	
	# ally test
	for i in range(5):
		var fox = fox_scene.instance()
		var id :String = "ally-" + str(i)
		fox.player.player_id = id
		fox.player.player_name = "ally"
		fox.player.player_team = 1
		fox.name = id
		fox.speed = 2
		fox.enable_name_tag = false
		fox.enable_damage = false
		fox.set_network_master(Network.PLAYER_HOST_ID)
		ally_holder.add_child(fox)
		fox.translation = _map.get_recomended_spawn_position()

		var ai = preload("res://assets/mob-ai/mob_ai.tscn").instance()
		ai.enable_manual_turning = false
		fox.add_child(ai)
		allies_ai.append(ai)
		
	
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
	
func get_player_as_target() ->NodePath:
	var players = []
	
	for player in players_holder.get_children():
		if player.is_dead:
			continue 
			
		players.append(player)
		
	if players.empty():
		return NodePath("")
		
	players.shuffle()
	
	return players[0].get_path()
	
	
func on_enemy_spawner_timer_timeout():
	var max_enemy :int = 1
	var big_ship :bool = false
	
	match (_day_night_dome.current_time):
		DayNightDome.TIME_MORNING:
			max_enemy = 1
			big_ship = false
			enemy_spawner_timer.wait_time = 20
			enemy_spawner_timer.start()
			
		DayNightDome.TIME_NIGHT:
			max_enemy = 2
			big_ship = true
			enemy_spawner_timer.wait_time = 10
			enemy_spawner_timer.start()
		
	if enemy_holder.get_child_count() >= max_enemy:
		return
		
	var id :String = GDUUID.v4()
	var parent :NodePath = enemy_holder.get_path()
	var spawn_pos :Vector3 = _map.get_random_radius_pos()
	var target :NodePath = get_player_as_target()
		
	if big_ship:
		spawn_enemy_on_ship(id, parent, spawn_pos, target)
	else:
		spawn_enemy_on_raft(id, parent, spawn_pos, target)
	
	
func on_enemy_target_update_timer_timeout():
	enemy_target_update_timer.start()
	
	for attack_wave in enemy_holder.get_children():
		if not is_instance_valid(attack_wave):
			continue
			
		if not is_instance_valid(attack_wave.target):
			continue
		
		if not attack_wave.target.is_dead:
			continue
		
		var target :BaseUnit = get_node_or_null(
			get_player_as_target()
		)
		
		if is_instance_valid(target):
			attack_wave.target = target
	






















