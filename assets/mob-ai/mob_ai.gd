extends Spatial
class_name MobAi

signal on_unit_dead(_ai, _unit)

export var margin :float = 2
export var attack_delay :float = 2
export var enable_ai = true
export var enable_manual_turning :bool = true

var move_to :Vector3 = Vector3.ZERO

var _unit :BaseUnit
onready var _attack_delay_timer = $attack_delay
onready var _pivot = $pivot

# Called when the node enters the scene tree for the first time.
func _ready():
	_attack_delay_timer.wait_time = attack_delay
	_pivot.set_as_toplevel(true)
	
	if get_parent() is BaseUnit:
		_unit = get_parent()
		_unit.connect("on_dead", self, "_on_unit_dead")
		
	if not is_instance_valid(_unit):
		return
		
	if _unit is BaseGroundUnit:
		_unit.enable_steering = true
		
func _on_unit_dead(_dead_unit :BaseUnit, _kill_by :PlayerData):
	emit_signal("on_unit_dead", self, _unit)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not enable_ai:
		return
		
	if not is_instance_valid(_unit):
		return
		
	var _is_arrive :bool = _is_arrive()
	var _is_blocked :bool = _check_target()
	
	_see_destination(_is_arrive, delta)
	_to_destination(_is_arrive or _is_blocked, delta)
	_pivot.translation = global_transform.origin
	
func _check_target() -> bool:
	if not _attack_delay_timer.is_stopped():
		return true
	
	if _unit.targets.empty():
		return false
		
	_unit_perform_attack()
	_attack_delay_timer.start()
	return true
	
func _is_arrive() -> bool:
	var unit_y :float = _unit.global_transform.origin.y
	var destination :Vector3 = Vector3(move_to.x, unit_y, move_to.z)
	var distance :float = global_transform.origin.distance_to(move_to)
	return distance < margin
	
func _see_destination(_is_arrive :bool, delta :float):
	if _is_arrive:
		return
		
	var unit_y :float = _unit.global_transform.origin.y
	var destination :Vector3 = Vector3(move_to.x, unit_y, move_to.z)
	var new_transform :Transform = _pivot.transform.looking_at(destination, Vector3.UP)
	_pivot.transform = _pivot.transform.interpolate_with(new_transform, 5 * delta)
	_pivot.rotation_degrees.y = wrapf(_pivot.rotation_degrees.y, 0.0, 360.0)
	_pivot.rotation_degrees.x = clamp(_pivot.rotation_degrees.x, -60, 40)
	
func _to_destination(_is_arrive :bool, delta :float):
	# simulate joystick to
	# make unit move foward only
	_unit.move_direction = Vector2.ZERO if _is_arrive else Vector2.UP
	
	if _unit is BaseGroundUnit:
		_unit.camera_basis = _pivot.transform.basis
		
		if enable_manual_turning:
			_unit.manual_turning = _is_arrive
			_unit.manual_turning_direction = move_to
	
func _unit_perform_attack():
	if randf() > 0.4:
		_unit.fast_attack()
	else:
		_unit.heavy_attack()
	
	
	






