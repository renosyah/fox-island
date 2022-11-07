extends Spatial
class_name RotatingCamera

export var vertical_rotation_speed :float = 0.024
export var horizontal_rotation_speed :float = 0.050
export var facing_direction :Vector2 = Vector2.ZERO

onready var _camera :Camera = $SpringArm/Camera

# will returning position of camera looking at
# instead of using value facing direction
# this can be use for more accurate aiming
func get_camera_aiming_at(_crosshair :Vector2, exclude_body :Array = []) -> Vector3:
	var ray_from :Vector3 = _camera.project_ray_origin(_crosshair)
	var ray_dir :Vector3 = _camera.project_ray_normal(_crosshair)
	var ray_cast_to :Vector3 = ray_from + ray_dir * 1000
	var shoot_target :Vector3 = ray_cast_to
		
	var col :Dictionary = get_world().direct_space_state.intersect_ray(
		ray_from, ray_cast_to, exclude_body, 0b11
	)
	if not col.empty():
		shoot_target = col["position"]
		
	return shoot_target
	
func get_camera_basis() -> Basis:
	return get_global_transform().basis
	
func _process(delta):
	rotation_degrees.y += -facing_direction.x * horizontal_rotation_speed * delta
	rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
	rotation_degrees.x += facing_direction.y * vertical_rotation_speed * delta
	rotation_degrees.x = clamp(rotation_degrees.x, -60, 40)

