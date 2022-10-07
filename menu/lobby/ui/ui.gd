extends Control

onready var _ip = $CanvasLayer/Control/VBoxContainer/ip
onready var _seed = $CanvasLayer/Control/VBoxContainer/seed

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
		
func on_back_pressed():
	get_tree().quit()
	
func _on_host_pressed():
	Network.connect("server_player_connected", self ,"_host_player_connected")
	var err = Network.create_server(Global.server.max_player, Global.server.port,OS.get_name())
	if err != OK:
		return
		
func _host_player_connected(_player_network_unique_id : int, _player :NetworkPlayer):
	Global.mp_game_data["seed"] = int(_seed.text)
	get_tree().change_scene("res://gameplay/mp/host/battle.tscn")
	
func _on_join_pressed():
	Network.connect("client_player_connected", self , "_client_player_connected")
	var err = Network.connect_to_server(_ip.text, Global.client.port , OS.get_name())
	if err != OK:
		return
		
func _client_player_connected(_player_network_unique_id : int, _player :NetworkPlayer):
	Global.mp_game_data["seed"] = int(_seed.text)
	get_tree().change_scene("res://gameplay/mp/client/battle.tscn")
	
