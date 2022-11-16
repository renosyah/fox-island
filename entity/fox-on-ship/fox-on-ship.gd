extends Spatial

onready var raft = $raft
onready var foxs = [
	$raft/fox_enemy,
	$raft/fox_enemy2,
	$raft/fox_enemy3
]
	
onready var foxs_ai = [
	$raft/fox_enemy/mob_ai,
	$raft/fox_enemy2/mob_ai,
	$raft/fox_enemy3/mob_ai
]

var target :BaseUnit
var is_server :bool = false
var enemy_level :int = 1

func set_spawn_position(spawn_pos :Vector3):
	if not is_instance_valid(target):
		return
		
	translation = spawn_pos
	look_at(target.global_transform.origin, Vector3.UP)
	
	raft.destination = target.global_transform.origin
	raft.destination.y = spawn_pos.y
	
	raft.set_as_toplevel(true)
	raft.set_process(true)
	set_process(true)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	for fox in foxs:
		fox.max_hp = fox.max_hp * enemy_level
		fox.hp = fox.max_hp
		fox.player.player_team = 2
		fox.set_network_master(Network.PLAYER_HOST_ID)
		fox.set_process(false)
		
	raft.set_process(false)
	set_process(false)
	 
func _process(delta):
	if not is_server:
		set_process(false)
		return
		
	var move_to :Vector3 = target.global_transform.origin
	for ai in foxs_ai:
		ai.move_to = move_to
	
func _on_raft_hit_shore():
	for fox in foxs:
		fox.set_as_toplevel(true)
		fox.set_process(true)
		
	for ai in foxs_ai:
		ai.enable_ai = is_server
	
func on_fox_dead(_fox, _killed_by):
	for fox in foxs:
		if not fox.is_dead:
			return
			
	raft.dead(PlayerData.new())
	
func _on_raft_on_dead(_entity, _killed_by):
	queue_free()
