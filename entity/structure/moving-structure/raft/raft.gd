extends MovingStructure

signal hit_shore

export var destination :Vector3
export var margin :float = 1.0
export var speed :float = 1.0

onready var _ray_cast = $RayCast
onready var _collision_shape = $CollisionShape
onready var _animation_player = $AnimationPlayer

remotesync func _hit_shore():
	emit_signal("hit_shore")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
remotesync func _dead(_kill_by :Dictionary) -> void:
	#._dead(_kill_by)
	is_dead = true
	set_process(false)
	hit_by_player.from_dictionary(_kill_by)
	_collision_shape.set_deferred("disabled", true)
	_animation_player.play("dead")
	
func _on_dead_animation_finish():
	._dead(hit_by_player.to_dictionary())
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func master_moving(delta):
	.master_moving(delta)
	
	if is_dead:
		return
		
	var _destination = Vector3(destination.x, global_transform.origin.y, destination.z)
	var direction_to_waypoint = global_transform.origin.direction_to(_destination)
	var distance_to_target = global_transform.origin.distance_to(_destination)
		
	var new_transform :Transform = transform.looking_at(_destination, Vector3.UP)
	transform = transform.interpolate_with(new_transform, 5 * delta)
	
	if distance_to_target > margin:
		move_and_slide(direction_to_waypoint * speed)
		
	if is_colliding_with_land():
		rpc("_hit_shore")
		set_process(false)
		return
		
func is_colliding_with_land():
	if not _ray_cast.is_colliding():
		return false
		
	if not _ray_cast.get_collider() is BaseMap:
		return false
		
	return true
