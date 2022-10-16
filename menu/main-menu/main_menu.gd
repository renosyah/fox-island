extends Node

const fox_scene = preload("res://entity/unit/ground-unit/fox/fox.tscn")

const camera_main_menu = Vector3(0.661, 13.47, -25.33)
const camera_lobby_menu = Vector3(-11.667, 7.325, 1.276)

onready var players_spawn_pos = $players_spawn_pos
onready var players_holder = $players_holder
onready var ui = $ui
onready var camera = $Camera
onready var tween = $Tween
onready var day_night_dome = $main_menu_map/day_night_dome2

# Called when the node enters the scene tree for the first time.
func _ready():
	camera.translation = camera_main_menu
	day_night_dome.set_time(1.5, true)

func get_rand_pos() -> Vector3:
	var angle := rand_range(0, TAU)
	var distance := rand_range(0, 3)
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
		fox.set_network_master(1)
		fox.enable_hp_bar = false
		fox.enable_name_tag = true
		
		players_holder.add_child(fox)
		fox.translation = get_rand_pos()
		
func _on_ui_to_main_menu():
	tween.interpolate_property(camera, "translation", camera.translation, camera_main_menu, 1.0)
	tween.start()

func _on_ui_to_lobby_menu():
	tween.interpolate_property(camera, "translation", camera.translation, camera_lobby_menu, 1.0)
	tween.start()
