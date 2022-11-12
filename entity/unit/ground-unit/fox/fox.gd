extends BaseGroundUnit

export var hood_texture :Texture = preload("res://entity/unit/ground-unit/fox/Textures/fox_diffuse.png")
export var enable_hp_bar :bool = true
export var enable_name_tag :bool = true

export var attack_damage :int = 15

onready var _collision_shape = $CollisionShape
onready var _animation_state = $pivot/AnimationTree.get("parameters/playback")
onready var _audio_stream_player_3d = $AudioStreamPlayer3D
onready var _pivot = $pivot

onready var _hood = $pivot/IdleDemo/Skeleton/Hood
onready var _hand_001 = $pivot/IdleDemo/Skeleton/Hand001
onready var _hand = $pivot/IdleDemo/Skeleton/Hand

onready var stun_timer = $stun_timer

var can_attack :bool = true
var can_roll :bool = true

var _hp_bar :HpBar3D
var _name_tag :Message3D
var _tween :Tween
var _hit_particle :HitParticle

onready var _walk_sound = preload("res://entity/unit/ground-unit/fox/sound/walk.wav")
onready var _jump_sound = preload("res://entity/unit/ground-unit/fox/sound/jump.wav")

onready var _hit_sounds = [
	preload("res://entity/unit/ground-unit/fox/sound/fight_1.wav"),
	preload("res://entity/unit/ground-unit/fox/sound/fight_2.wav"),
	preload("res://entity/unit/ground-unit/fox/sound/fight_3.wav")
]
onready var _dead_sounds = [
	preload("res://entity/unit/ground-unit/fox/sound/maledeath1.wav"),
	preload("res://entity/unit/ground-unit/fox/sound/maledeath2.wav"),
	preload("res://entity/unit/ground-unit/fox/sound/maledeath3.wav"),
	preload("res://entity/unit/ground-unit/fox/sound/maledeath4.wav")
]

var _node_not_move = ["Attack", "Jump", "ToucheGround", "Fall"]
var enable_walk_sound = false

################################################################
# multiplayer
func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if is_dead:
		return
		
	if _is_master():
		rset_unreliable("_puppet_move_direction", move_direction)
		
puppet var _puppet_move_direction :Vector2 setget _set_puppet_move_direction
	
func _set_puppet_move_direction(val :Vector2) -> void:
	_puppet_move_direction = val
		
	if _is_master():
		return
		
	move_direction = _puppet_move_direction
	
################################################################
	
# Called when the node enters the scene tree for the first time.
func _ready():
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
	
	if enable_hp_bar:
		_hp_bar = preload("res://assets/ui/bar-3d/hp_bar_3d.tscn").instance()
		add_child(_hp_bar)
		_hp_bar.translation.y = 2
		_hp_bar.modulate.a = 0
		_hp_bar.scale = Vector3.ONE * 0.4
		_hp_bar.update_bar(hp, max_hp)
		
	if enable_name_tag:
		_name_tag = preload("res://assets/ui/message-3d/message_3d.tscn").instance()
		add_child(_name_tag)
		_name_tag.translation.y = 1.5
		_name_tag.set_message(player.player_name)
		_name_tag.set_color(Color.white)
		
	_hit_particle = preload("res://assets/hit_particle/hit_particle.tscn").instance()
	add_child(_hit_particle)
	_hit_particle.set_as_toplevel(true)
	
remotesync func _knock_back(_from_velocity :Vector3) -> void:
	_velocity = _from_velocity
	
	if is_on_floor() and _enable_snap and _velocity.y > 0.0:
		_enable_snap = false
		_snap = Vector3.UP * _velocity.y
		
	stun_timer.start()
	
remotesync func _take_damage(_hp_left, _damage : int, _hit_by :Dictionary) -> void:
	._take_damage(_hp_left, _damage, _hit_by)
	
	var hit_sound = _hit_sounds[rand_range(0, _hit_sounds.size())]
	_audio_stream_player_3d.stream = hit_sound
	_audio_stream_player_3d.play()
	
	_hit_particle.display_hit(str(_damage))
	_hit_particle.translation = global_transform.origin + Vector3(0, 0.8, 0)
	
	_tween.interpolate_property(_pivot, "scale", Vector3.ONE * 0.6, Vector3.ONE, 0.3)
	_update_hp_bar(_hp_left, max_hp)
	
remotesync func _dead(_kill_by :Dictionary) -> void:
	#._dead(_kill_by)
	var _dead_sound = _dead_sounds[rand_range(0, _dead_sounds.size())]
	_audio_stream_player_3d.stream = _dead_sound
	_audio_stream_player_3d.play()
	
	_hit_particle.display_hit("Wack!")
	_hit_particle.translation = global_transform.origin + Vector3(0, 0.8, 0)
	
	is_dead = true
	set_process(false)
	hit_by_player.from_dictionary(_kill_by)
	
	_update_hp_bar(0, max_hp)
	_animation_state.travel("Dead")
	_collision_shape.set_deferred("disabled", true)
	
remotesync func _reset() -> void:
	._reset()
	_animation_state.travel("Idle")
	_collision_shape.set_deferred("disabled", false)
	
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
		
	if not stun_timer.is_stopped():
		return
		
	rpc("_attack")
	for target in targets:
		if target is BaseEntity:
			if target.team() == team():
				continue
			
		if target.has_method("take_damage"):
			target.take_damage(get_attack_damage(), player)
			
		if target.has_method("knock_back"):
			target.knock_back(global_transform.basis.z * -8.0)
	
func heavy_attack():
	if is_dead:
		return
		
	if not _is_master():
		return
		
	if not stun_timer.is_stopped():
		return
		
	rpc("_attack")
	for target in targets:
		if target is BaseEntity:
			if target.team() == team():
				continue
			
		if target.has_method("take_damage"):
			target.take_damage(get_attack_damage() * 2, player)
			
		if target.has_method("knock_back"):
			target.knock_back(
				global_transform.basis.z * -18.0 + global_transform.basis.y * 12.0
			)
	
func knock_back(_from_velocity :Vector3) -> void:
	rpc("_knock_back", _from_velocity)
	
func jump():
	if is_dead:
		return
	
	if not _is_master():
		return
		
	if not stun_timer.is_stopped():
		return
		
	if is_on_floor() and _enable_snap:
		_enable_snap = false
		_velocity.y += 10.0
		_snap = Vector3.UP * _velocity.y
		rpc("_jump")
		
func roll():
	if is_dead:
		return
	
	if not _is_master():
		return
		
	if move_direction.length() < 0.6:
		return
		
	if not stun_timer.is_stopped():
		return
		
	if is_on_floor():
		_velocity = _velocity * 4.0
		rpc("_roll")
	
func _walk():
	if not enable_walk_sound:
		return
		
	_audio_stream_player_3d.stream = _walk_sound
	_audio_stream_player_3d.play()
	
func master_moving(delta):
	.master_moving(delta)
	if not _enable_snap and is_on_floor():
		_enable_snap = true
		rpc_unreliable("_land")
		
	can_attack = stun_timer.is_stopped() and not targets.empty()
	can_roll = stun_timer.is_stopped() and move_direction.length() > 0.6
	
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
	
func get_attack_damage() -> int:
	var quarter_atk : float = attack_damage * 0.25
	return int(rand_range(
		attack_damage - quarter_atk, 
		attack_damage + quarter_atk
	))










