extends Node

const fox_scene = preload("res://entity/unit/ground-unit/fox/fox.tscn")

onready var players_holder = $players
onready var players_spawn_pos = $Camera/players_spawn_pos
onready var ui = $ui

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func get_rand_pos() -> Vector3:
	var angle := rand_range(0, TAU)
	var distance := rand_range(0, 5)
	var posv2 = polar2cartesian(distance, angle)
	var posv3 = players_spawn_pos.global_transform.origin + Vector3(posv2.x, 1.0, posv2.y)
	return posv3
	
func _on_ui_lobby_player_update(players :Array):
	for child in players_holder.get_children():
		players_holder.remove_child(child)
		child.queue_free()
		
	for player in players:
		var fox = fox_scene.instance()
		var id :String = str(player.player_network_unique_id)
		
		fox.player.player_id = id
		fox.player.player_name = player.player_name
		fox.name = id
		fox.set_network_master(player.player_network_unique_id)
		fox.enable_hp_bar = false
		fox.enable_name_tag = true
		players_holder.add_child(fox)
		fox.translation = get_rand_pos()
	
	
	
