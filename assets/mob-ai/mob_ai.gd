extends Spatial
class_name MobAi

export var margin :float = 2
export var attack_delay :float = 2
export var enable_ai = true

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
		
	if not is_instance_valid(_unit):
		return
		
	if _unit is BaseGroundUnit:
		_unit.enable_steering = true
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not enable_ai:
		return
		
	if not is_instance_valid(_unit):
		return
		
	_check_target()
	_see_destination(delta)
	_to_destination(delta)
	_pivot.translation = global_transform.origin
	
func _check_target():
	if not _attack_delay_timer.is_stopped():
		return
		
	var unit_team :int = _unit.player.player_team
	var is_enemy_in_range :bool = false
	
	for target in _unit.targets:
		if not target is BaseEntity:
			continue
			
		if target.player.player_team != unit_team:
			is_enemy_in_range = true
			break
			
	if is_enemy_in_range:
		_unit.fast_attack()
		_attack_delay_timer.start()
	
func _is_arrive() -> bool:
	var unit_y :float = _unit.global_transform.origin.y
	var destination :Vector3 = Vector3(move_to.x, unit_y, move_to.z)
	var distance :float = global_transform.origin.distance_to(move_to)
	return distance < margin
	
func _see_destination(delta :float):
	if _is_arrive():
		return
		
	var unit_y :float = _unit.global_transform.origin.y
	var destination :Vector3 = Vector3(move_to.x, unit_y, move_to.z)
	var _new_transform = _pivot.transform.looking_at(destination, Vector3.UP)
	_pivot.transform = _pivot.transform.interpolate_with(_new_transform, 5 * delta)
	_pivot.rotation_degrees.y = wrapf(_pivot.rotation_degrees.y, 0.0, 360.0)
	_pivot.rotation_degrees.x = clamp(_pivot.rotation_degrees.x, -60, 40)
	
func _to_destination(delta :float):
	if _is_arrive():
		_unit.move_direction  = Vector2.ZERO
		return
		
	# simulate joystick to
	# make unit move foward only
	_unit.move_direction = Vector2.UP
	
	if _unit is BaseGroundUnit:
		_unit.camera_basis = _pivot.transform.basis
	
	
