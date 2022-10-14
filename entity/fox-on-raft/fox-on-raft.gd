extends Spatial

export var target :NodePath

onready var raft = $raft
onready var foxs = [
	$raft/fox_enemy,
	$raft/fox_enemy2,
]
	
onready var foxs_ai = [
	$raft/fox_enemy/mob_ai,
	$raft/fox_enemy2/mob_ai,
]

var is_server :bool = false
onready var _target :BaseUnit = get_node_or_null(target)

func set_spawn_position(spawn_pos :Vector3):
	if not is_instance_valid(_target):
		return
		
	translation = spawn_pos
	look_at(_target.global_transform.origin, Vector3.UP)
	
	raft.destination = _target.global_transform.origin
	raft.destination.y = spawn_pos.y
	
	raft.set_as_toplevel(true)
	raft.set_process(true)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	for fox in foxs:
		fox.player.player_team = 2
		fox.set_process(false)
		
	raft.set_process(false)
	 
func _on_raft_hit_shore():
	for fox in foxs:
		fox.set_as_toplevel(true)
		fox.set_process(true)
		
	for ai in foxs_ai:
		ai.target = _target
		ai.enable_ai = is_server
	
func on_fox_dead(_fox, _killed_by):
	for fox in foxs:
		if not fox.is_dead:
			return
			
	raft.dead(PlayerData.new())
	
func _on_raft_on_dead(_entity, _killed_by):
	queue_free()
