extends BaseEntity
class_name BaseUnit

export var gravity_multiplier :float = 0.075

# represented of direction input from UI
# vector2.UP = foward, vector2.DOWN = reverse
# Vector2.LEFT = left, Vector2.RIGHT = right
export var move_direction :Vector2 = Vector2.ZERO

export var speed :float = 2.0
export var acceleration :float = 2.0
export var deceleration :float = 6.0

var targets :Array = []

var _velocity :Vector3 = Vector3.ZERO
var _snap :Vector3 = Vector3.ZERO
var _up_direction :Vector3 = Vector3.UP
var _stop_on_slope :bool = true
var _aim_direction :Vector3 = Vector3()

onready var _gravity :float = (ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_multiplier)
onready var _floor_max_angle: float = deg2rad(45.0)

################################################################
# multiplayer
func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if is_dead:
		return
		
	if _is_master():
		rset_unreliable("_puppet_translation", global_transform.origin)
		rset_unreliable("_puppet_rotation", global_transform.basis.get_euler())
		
puppet var _puppet_rotation :Vector3
puppet var _puppet_translation :Vector3
	
remotesync func _attack() -> void:
	if is_dead:
		return
		
################################################################
# function main
func _ready() -> void:
	pass
	
################################################################
# function action
func attack() -> void:
	if not _is_master():
		return
		
	if is_dead:
		return
		
	rpc_unreliable("_attack")
	
################################################################
# function common
func master_moving(delta :float) -> void:
	if is_dead:
		return
		
	.master_moving(delta)
	_direction_input()
	_accelerate(delta)
	_velocity = move_and_slide_with_snap(_velocity, _snap, _up_direction, _stop_on_slope, 4, _floor_max_angle)
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	global_transform.origin = global_transform.origin.linear_interpolate(_puppet_translation, 2.5 * delta)
	rotation.x = lerp_angle(rotation.x, _puppet_rotation.x, 5 * delta)
	rotation.y = lerp_angle(rotation.y, _puppet_rotation.y, 5 * delta)
	rotation.z = lerp_angle(rotation.z, _puppet_rotation.z, 5 * delta)
	
func _direction_input() -> void:
	_aim_direction = Vector3.ZERO
	var _aim: Basis = get_global_transform().basis
	_aim_direction = _aim.z * move_direction.y + _aim.x * move_direction.x
	
func _accelerate(delta: float) -> void:
	var temp_vel = _velocity
	temp_vel.y = 0.0
	
	var temp_accel: float
	var target: Vector3 = _aim_direction * speed
	
	if _aim_direction.dot(temp_vel) > 0:
		temp_accel = acceleration
	else:
		temp_accel = deceleration
	
	temp_vel = temp_vel.linear_interpolate(target, temp_accel * delta)
	
	_velocity.x = temp_vel.x
	_velocity.z = temp_vel.z
	
func validate_targets():
	var target_pos_to_erase = []
	var pos = 0
	
	for i in targets:
		if not is_instance_valid(i):
			target_pos_to_erase.append(pos)
			
		pos += 1
		
	if target_pos_to_erase.empty():
		return
		
	for i in target_pos_to_erase:
		targets.remove(i)
		
func get_velocity() -> Vector3:
	return _aim_direction
	
	
