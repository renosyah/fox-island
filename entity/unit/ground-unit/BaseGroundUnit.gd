extends BaseUnit
class_name BaseGroundUnit

var camera_basis :Basis
export var rotation_speed :float = 6.25
export var enable_steering :bool = false

export var manual_turning :bool = false
export var manual_turning_direction :Vector3 = Vector3.ZERO

var _enable_snap = true
var _raycast :RayCast

func _ready() -> void:
	camera_basis = transform.basis
	gravity_multiplier = 1.2
	_gravity = (ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_multiplier)
	
	_raycast = RayCast.new()
	add_child(_raycast)
	_raycast.cast_to = Vector3(0, -2, 0)
	_raycast.enabled = true
	_raycast.exclude_parent = true
	
func _direction_input() -> void:
	# full override
	# dont remove comment
	#._direction_input()
	if is_dead:
		return
		
	_aim_direction = Vector3.ZERO
	_aim_direction = camera_basis.z * move_direction.y + camera_basis.x * move_direction.x
	_aim_direction.y = 0.0
	
func master_moving(delta :float) -> void:
	# full override
	# dont remove comment
	#.master_moving(delta)
	_direction_input()
	
	var _is_on_floor :bool = is_on_floor()
	var _inverse_floor_normal :Vector3 = - get_floor_normal()
	var _pos = global_transform.origin
	
	if manual_turning:
		var turning_direction :Vector3 = manual_turning_direction
		turning_direction.y = _pos.y
		_transform_turning(turning_direction, delta)
		
	else:
		if _aim_direction != Vector3.ZERO and _velocity != Vector3.ZERO:
			var turning_direction :Vector3 = _aim_direction if not enable_steering else _velocity
			turning_direction = turning_direction * 100 + _pos
			turning_direction.y = _pos.y
			_transform_turning(turning_direction, delta)
		
	if _is_on_floor and _enable_snap:
		_snap = _inverse_floor_normal - get_floor_velocity() * delta
		_transform_elevation(_raycast.get_collision_normal(), delta)
		
	else:
		_snap = Vector3.ZERO
		_velocity.y -= _gravity * delta
		
	_accelerate(delta)
	_velocity = move_and_slide_with_snap(_velocity, _snap, _up_direction, _stop_on_slope, 4, _floor_max_angle)
	
############################################################
# utils
func _transform_turning(look_direction :Vector3, delta :float) -> void:
	var new_transform :Transform = transform.looking_at(look_direction, Vector3.UP)
	transform = transform.interpolate_with(new_transform, rotation_speed * delta)
	
func _transform_elevation(collision_normal :Vector3, delta :float) -> void:
	var xform = align_with_y(global_transform, collision_normal)
	global_transform = global_transform.interpolate_with(xform, rotation_speed * delta)
	
func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
	

