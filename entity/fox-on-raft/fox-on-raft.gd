extends Spatial

export var target :NodePath

onready var raft = $raft
onready var mob_ai = $fox_enemy/mob_ai
onready var fox = $fox_enemy

onready var _target :BaseUnit = get_node_or_null(target)

func set_spawn_position(spawn_pos :Vector3):
	if not is_instance_valid(_target):
		return
		
	translation = spawn_pos
	
	fox.set_as_toplevel(true)
	raft.set_as_toplevel(true)
	
	raft.destination = _target.global_transform.origin
	raft.destination.y = spawn_pos.y
	fox.look_at(raft.destination, Vector3.UP)
	
	raft.set_physics_process(true)
	fox.set_physics_process(true)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	raft.set_physics_process(false)
	fox.set_physics_process(false)
	mob_ai.enable_ai = false
	
	fox.connect("on_dead", self, "on_fox_dead")
	
func _on_raft_hit_shore():
	mob_ai.target = _target
	mob_ai.enable_ai = true
	
func on_fox_dead(_fox, _killed_by):
	queue_free()
	
