extends BaseGroundUnit

export var hood_texture :Texture = preload("res://entity/unit/ground-unit/fox/Textures/fox_diffuse.png")
export var enable_hp_bar :bool = true

onready var _animation_state = $pivot/AnimationTree.get("parameters/playback")
onready var _audio_stream_player_3d = $AudioStreamPlayer3D
onready var _pivot = $pivot

onready var _hood = $pivot/IdleDemo/Skeleton/Hood
onready var _hand_001 = $pivot/IdleDemo/Skeleton/Hand001
onready var _hand = $pivot/IdleDemo/Skeleton/Hand

var _hp_bar :HpBar3D
var _tween :Tween

onready var _walk_sound = preload("res://entity/unit/ground-unit/fox/sound/walk.wav")
onready var _jump_sound = preload("res://entity/unit/ground-unit/fox/sound/jump.wav")

var _node_not_move = ["Attack", "Jump", "ToucheGround", "Fall"]
var _is_jump = false
var _is_roll = false

var enable_walk_sound = false

# Called when the node enters the scene tree for the first time.
func _ready():
	player = PlayerData.new()
	
	var material :SpatialMaterial = preload("res://entity/unit/ground-unit/fox/Material.material").duplicate(true)
	material.albedo_texture = hood_texture
	
	_hood.material_override = material
	_hand_001.material_override = material
	_hand.material_override = material
	
	_audio_stream_player_3d.unit_db = Global.sound_amplified
	
	_tween = Tween.new()
	add_child(_tween)
	
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.autostart = true
	add_child(timer)
	
	yield(timer,"timeout")
	timer.queue_free()
	
	if not enable_hp_bar:
		return
		
	_hp_bar = preload("res://assets/ui/bar-3d/hp_bar_3d.tscn").instance()
	add_child(_hp_bar)
	_hp_bar.translation.y = 2
	_hp_bar.modulate.a = 0
	_hp_bar.scale = Vector3.ONE * 0.4
	_hp_bar.update_bar(hp, max_hp)
	
remotesync func _knock_back(_from_velocity :Vector3) -> void:
	_velocity = _from_velocity
	
remotesync func _take_damage(_hp_left, _damage : int, _hit_by :Dictionary) -> void:
	._take_damage(_hp_left, _damage, _hit_by)

	_update_hp_bar(_hp_left, max_hp)
	_tween.interpolate_property(_pivot, "scale", Vector3.ONE * 0.6, Vector3.ONE, 0.3)
	
remotesync func _dead(_kill_by :Dictionary) -> void:
	#._dead(_kill_by)
	is_dead = true
	set_physics_process(false)
	hit_by_player.from_dictionary(_kill_by)
	
	_update_hp_bar(0, max_hp)
	_animation_state.travel("Dead")
	
func _on_dead_animation_finish():
	._dead(hit_by_player.to_dictionary())
	
remotesync func _attack():
	_animation_state.travel("Attack")
	
remotesync func _jump():
	_audio_stream_player_3d.stream = _jump_sound
	_audio_stream_player_3d.play()
	
	_animation_state.travel("Jump")
	
remotesync func _roll():
	_audio_stream_player_3d.stream = _jump_sound
	_audio_stream_player_3d.play()
	
	_animation_state.travel("Roll")
	
remotesync func _land():
	_animation_state.travel("ToucheGround")
	
func fast_attack():
	if is_dead:
		return
		
	if not _is_master():
		return
		
	rpc("_attack")
	for target in targets:
		if target.has_method("take_damage"):
			target.take_damage(5, player)
	
func heavy_attack():
	if is_dead:
		return
		
	if not _is_master():
		return
		
	rpc("_attack")
	for target in targets:
		if target.has_method("take_damage"):
			target.take_damage(15, player)
			
		if target.has_method("knock_back"):
			target.knock_back(global_transform.basis.z * -8.0)
	
func knock_back(_from_velocity :Vector3) -> void:
	rpc("_knock_back", _from_velocity)
	
func jump():
	if is_dead:
		return
	
	if not _is_master():
		return
		
	if is_on_floor() and not _is_jump:
		_is_jump = true
		_snap = Vector3.ZERO
		translation.y += 1.0
		_velocity.y = 10.0
		rpc("_jump")
		
func roll():
	if is_dead:
		return
	
	if not _is_master():
		return
		
	if move_direction.length() < 0.6:
		return
		
	if is_on_floor() and not _is_roll:
		_is_roll  = true
		_velocity = _velocity * 6.0
		rpc("_roll")
	
func _walk():
	if not enable_walk_sound:
		return
		
	_audio_stream_player_3d.stream = _walk_sound
	_audio_stream_player_3d.play()
	
func master_moving(delta):
	.master_moving(delta)
	
	# fall below map
	if translation.y < -25.0:
		emit_signal("on_dead", self, hit_by_player)
		set_physics_process(false)
		queue_free()
		return
		
	if _is_jump and is_on_floor():
		_is_jump = false
		rpc_unreliable("_land")
		
	if _is_roll and is_on_floor():
		_is_roll = false
		
		
func _on_animation_checker_timeout():
	if is_dead:
		return
	
	if _animation_state.get_current_node() in _node_not_move:
		return
		
	if move_direction != Vector2.ZERO:
		_animation_state.travel("Run")
	else:
		_animation_state.travel("Idle")
		
func _on_attack_area_body_entered(body):
	if body == self:
		return
		
	if is_dead:
		return
	
	if body is MineableResource:
		targets.append(body)
		
	elif body is BaseUnit:
		targets.append(body)
		
func _on_attack_area_body_exited(body):
	targets.erase(body)
	
func _update_hp_bar(_hp, _max_hp :int):
	if not is_instance_valid(_hp_bar):
		return
		
	_hp_bar.update_bar(_hp, _max_hp)
	_tween.interpolate_property(_hp_bar, "modulate:a", 1, 0, 4)
	_tween.start()
