extends Spatial
class_name MobAi

export var unit :NodePath
export var margin :float = 2

var destination :Vector3 = Vector3.ZERO

onready var _unit :BaseUnit = get_node_or_null(unit)
onready var _pivot = $pivot

# Called when the node enters the scene tree for the first time.
func _ready():
	_pivot.set_as_toplevel(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_see_destination(delta)
	_to_destination(delta)
	_pivot.translation = global_transform.origin
	
func _is_arrive() -> bool:
	var distance = global_transform.origin.distance_to(destination)
	return distance <= margin
	
func _see_destination(delta :float):
	if _is_arrive():
		return
		
	var _new_transform = _pivot.transform.looking_at(destination, Vector3.UP)
	_pivot.transform = _pivot.transform.interpolate_with(_new_transform, 5 * delta)
	_pivot.rotation_degrees.y = wrapf(_pivot.rotation_degrees.y, 0.0, 360.0)
	_pivot.rotation_degrees.x = clamp(_pivot.rotation_degrees.x, -60, 40)
	
	_unit.facing_direction = Vector2(_pivot.rotation.x, _pivot.rotation.y)
	
func _to_destination(delta :float):
	if _is_arrive():
		_unit.move_direction  = Vector2.ZERO
		return
		
	_unit.move_direction = Vector2(0.0, -1.0)
	
	if _unit is BaseGroundUnit:
		_unit.camera_basis = _pivot.transform.basis
	
	
