extends Spatial
class_name RotatingCamera

export var vertical_rotation_speed :float = 0.024
export var horizontal_rotation_speed :float = 0.050
export var facing_direction :Vector2 = Vector2.ZERO
export var crosshair :NodePath
var exclude_aim :Array = []

onready var _crosshair :Control = get_node_or_null(crosshair)
onready var _camera :Camera = $SpringArm/Camera

func get_facing_direction():
	return Vector2(rotation.x, rotation.y)
	
func get_camera_basis() -> Basis:
	return get_global_transform().basis
	
func get_camera_aim() -> Vector3:
	if not is_instance_valid(_crosshair):
		return Vector3.ZERO
		
	var ch_pos :Vector2 = _crosshair.rect_position + _crosshair.rect_size * 0.5
	var ray_from :Vector3 = _camera.project_ray_origin(ch_pos)
	var ray_dir :Vector3 = _camera.project_ray_normal(ch_pos)
	var ray_cast_to :Vector3 = ray_from + ray_dir * 1000
	var shoot_target :Vector3 = ray_cast_to
	
	var col :Dictionary = get_world().direct_space_state.intersect_ray(
		ray_from, ray_cast_to, exclude_aim, 0b11
	)
	if not col.empty():
		shoot_target = col["position"]
		
	return shoot_target
	
	
func _process(delta):
	rotation_degrees.y += -facing_direction.x * horizontal_rotation_speed * delta
	rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
	rotation_degrees.x += facing_direction.y * vertical_rotation_speed * delta
	rotation_degrees.x = clamp(rotation_degrees.x, -60, 40)

