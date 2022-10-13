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
	var configuration = NetworkServer.new()
	configuration.max_player = 4
	
	NetworkLobbyManager.player_name = "host"
	NetworkLobbyManager.configuration = configuration
	NetworkLobbyManager.connect("on_host_player_connected", self,"on_host_player_connected")
	NetworkLobbyManager.init_lobby()
	
func on_host_player_connected():
	NetworkLobbyManager.argument["seed"] = int(_seed.text)
	get_tree().change_scene("res://gameplay/mp/host/battle.tscn")
	
func _on_join_pressed():
	var configuration = NetworkClient.new()
	configuration.ip = _ip.text
	
	NetworkLobbyManager.player_name = "client"
	NetworkLobbyManager.configuration = configuration
	NetworkLobbyManager.connect("on_client_player_connected", self,"on_client_player_connected")
	NetworkLobbyManager.init_lobby()
	
func on_client_player_connected():
	NetworkLobbyManager.argument["seed"] = int(_seed.text)
	get_tree().change_scene("res://gameplay/mp/client/battle.tscn")
	
