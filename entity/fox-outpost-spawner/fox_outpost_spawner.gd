extends Spatial

signal on_outpost_destroyed

const red_hood = preload("res://entity/unit/ground-unit/fox/Textures/fox_diffuse_red.png")
const fox_scene = preload("res://entity/unit/ground-unit/fox/fox.tscn")
const ai_mob_scene = preload("res://assets/mob-ai/mob_ai.tscn")

export var spawn_delay :float = 12
export var is_server :bool = false

var ai_mobs :Array = []

onready var outpost = $outpost
onready var unit_spotter = $unit_spotter
onready var spawn_delay_timer = $spawn_delay
onready var unit_holder = $unit_holder

# Called when the node enters the scene tree for the first time.
func _ready():
	unit_spotter.enemy_teams = [1]
	unit_spotter.ignores = []
	
	if not is_server:
		return
		
	spawn_delay_timer.wait_time = 4
	spawn_delay_timer.start()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_server:
		set_process(false)
		return
		
	var outpost_pos :Vector3 = outpost.global_transform.origin
	var target :BaseUnit = unit_spotter.get_target()
	for i in ai_mobs:
		if not i is MobAi:
			continue
			
		i.move_to = target.global_transform.origin if target != null else outpost_pos
		
func _on_spawn_delay_timeout():
	spawn_delay_timer.wait_time = spawn_delay
	spawn_delay_timer.start()
	
	if unit_holder.get_child_count() > 2:
		return
	
	rpc("_spawn", GDUUID.v4())
	
remotesync func _spawn(_name :String):
	var fox = fox_scene.instance()
	fox.player = PlayerData.new()
	fox.player.player_team = 2
	fox.name = _name
	fox.hood_texture = red_hood
	fox.attack_damage = 5
	fox.set_network_master(Network.PLAYER_HOST_ID)
	unit_holder.add_child(fox)
	fox.translation = get_spawn_pos()
	fox.set_as_toplevel(true)
	
	if is_server:
		var ai = ai_mob_scene.instance()
		ai.connect("on_unit_dead", self, "_on_unit_dead")
		fox.add_child(ai)
		ai_mobs.append(ai)
		
func _on_unit_dead(ai :MobAi, unit :BaseUnit):
	if not ai in ai_mobs:
		return
		
	set_process(false)
	ai_mobs.erase(ai)
	set_process(true)
	
	unit.queue_free()
	
func get_spawn_pos() -> Vector3:
	var angle := rand_range(0, TAU)
	var distance := rand_range(3, 6)
	var posv2 = polar2cartesian(distance, angle)
	var posv3 = outpost.global_transform.origin + Vector3(posv2.x, 1.0, posv2.y)
	return posv3
	
func _on_outpost_on_destroyed(_resources):
	emit_signal("on_outpost_destroyed")
	queue_free()



