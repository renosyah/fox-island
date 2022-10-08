extends BaseGroundUnit

export var hood_texture :Texture = preload("res://entity/unit/ground-unit/fox/Textures/fox_diffuse.png")

onready var animation_state = $pivot/AnimationTree.get("parameters/playback")
onready var firing_delay = $firing_delay
onready var jump_delay = $jump_delay
onready var audio_stream_player_3d = $AudioStreamPlayer3D

onready var _walk_sound = preload("res://entity/unit/ground-unit/fox/sound/walk.wav")
onready var _jump_sound = preload("res://entity/unit/ground-unit/fox/sound/jump.wav")

var targets :Array = []

var node_not_move = ["Attack", "Jump", "ToucheGround", "Fall"]
var is_jump = false
var enable_walk_sound = false

onready var hood = $pivot/IdleDemo/Skeleton/Hood
onready var hand_001 = $pivot/IdleDemo/Skeleton/Hand001
onready var hand = $pivot/IdleDemo/Skeleton/Hand

# Called when the node enters the scene tree for the first time.
func _ready():
	var material :SpatialMaterial = preload("res://entity/unit/ground-unit/fox/Material.material").duplicate(true)
	material.albedo_texture = hood_texture
	
	hood.material_override = material
	hand_001.material_override = material
	hand.material_override = material
	
	audio_stream_player_3d.unit_db = Global.sound_amplified
	
remotesync func _attack():
	animation_state.travel("Attack")
	
remotesync func _jump():
	audio_stream_player_3d.stream = _jump_sound
	audio_stream_player_3d.play()
	
	animation_state.travel("Jump")
	
remotesync func _land():
	animation_state.travel("ToucheGround")
	
func attack():
	#.attack()
	
	if not _is_master():
		return
		
	if firing_delay.is_stopped():
		rpc("_attack")
		_attack_targets()
		firing_delay.start()
		
func _attack_targets():
	for target in targets:
		if target.has_method("take_damage"):
			target.take_damage(5, player)
		
func jump():
	if not _is_master():
		return
		
	if jump_delay.is_stopped() and is_on_floor() and not is_jump:
		is_jump = true
		_snap = Vector3.ZERO
		translation.y += 1.0
		_velocity.y = 15.0
		rpc("_jump")
		jump_delay.start()
		
func dodge():
	if not _is_master():
		return
		
	if jump_delay.is_stopped() and is_on_floor() and not is_jump:
		is_jump = true
		_snap = Vector3.ZERO
		_velocity = _velocity * 2.0
		rpc("_jump")
		jump_delay.start()
	
func _walk():
	if not enable_walk_sound:
		return
		
	audio_stream_player_3d.stream = _walk_sound
	audio_stream_player_3d.play()
	
func master_moving(delta):
	.master_moving(delta)
	
	if is_jump and is_on_floor():
		is_jump = false
		rpc_unreliable("_land")
	
func _on_animation_checker_timeout():
	if is_dead:
		return
	
	if animation_state.get_current_node() in node_not_move:
		return
		
	if move_direction != Vector2.ZERO:
		animation_state.travel("Run")
	else:
		animation_state.travel("Idle")
		
func _on_attack_area_body_entered(body):
	if body == self:
		return
		
	if body is MineableResource:
		targets.append(body)
		
	elif body is BaseUnit:
		targets.append(body)
		
func _on_attack_area_body_exited(body):
	targets.erase(body)
