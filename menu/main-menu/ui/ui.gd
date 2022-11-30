extends BaseUi

signal lobby_player_update(players)
signal to_main_menu
signal to_lobby_menu

onready var loading_bar = $CanvasLayer/SafeArea/loading/VBoxContainer/loading_bar
onready var loading_label = $CanvasLayer/SafeArea/loading/VBoxContainer/Label
onready var loading = $CanvasLayer/SafeArea/loading

onready var main_menu_control = $CanvasLayer/SafeArea/main_menu_control
onready var lobby_menu_control = $CanvasLayer/SafeArea/lobby_menu_control2
onready var server_browser = $CanvasLayer/SafeArea/server_browser
onready var input_name = $CanvasLayer/SafeArea/input_name
onready var player_name = $CanvasLayer/SafeArea/main_menu_control/HBoxContainer/MarginContainer4/HBoxContainer/VBoxContainer/change_name_button/HBoxContainer/player_name

onready var seed_input = $CanvasLayer/SafeArea/lobby_menu_control2/HBoxContainer/MarginContainer4/HBoxContainer/VBoxContainer/seed
onready var play_button = $CanvasLayer/SafeArea/lobby_menu_control2/HBoxContainer/MarginContainer4/HBoxContainer/VBoxContainer/play_button

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	main_menu_control.visible = true
	lobby_menu_control.visible = false
	
	NetworkLobbyManager.connect("on_client_player_connected", self,"on_client_player_connected")
	NetworkLobbyManager.connect("on_host_player_connected", self,"on_host_player_connected")
	NetworkLobbyManager.connect("lobby_player_update", self, "on_lobby_player_update")
	NetworkLobbyManager.connect("on_host_disconnected", self, "on_leave")
	NetworkLobbyManager.connect("on_leave", self, "on_leave")
	NetworkLobbyManager.connect("on_host_ready", self ,"on_host_ready")
	
	player_name.text = Global.player.player_name
	
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
	
func loading(_show :bool):
	.loading(_show)
	loading.visible = _show
	
func loading_message(message :String, progress, max_progress :int):
	.loading_message(message, progress, max_progress)
	loading_label.text = "Loading ({progress}/{max_progress})".format({"progress": progress, "max_progress" :max_progress})
	loading_bar.update_bar(progress, max_progress)
	
func _on_change_name_button_pressed():
	input_name.visible = true
	
func _on_input_name_on_continue(_player_name, html_color):
	Global.player.player_name = _player_name
	#Global.player.save_data(Global.player_save_file)
	player_name.text = Global.player.player_name
	
func _on_host_button_pressed():
	var configuration = NetworkServer.new()
	configuration.max_player = 4
	
	NetworkLobbyManager.player_name = Global.player.player_name
	NetworkLobbyManager.configuration = configuration
	NetworkLobbyManager.init_lobby()
	
func on_host_player_connected():
	main_menu_control.visible = false
	lobby_menu_control.visible = true
	
	seed_input.visible = true
	play_button.visible = true
	
	emit_signal("to_lobby_menu")
	
func _on_join_button_pressed():
	server_browser.start_finding()
	server_browser.show()
	
func _on_server_browser_on_join(info :Dictionary):
	var configuration = NetworkClient.new()
	configuration.ip = info["ip"]
	
	NetworkLobbyManager.player_name = Global.player.player_name
	NetworkLobbyManager.configuration = configuration
	NetworkLobbyManager.init_lobby()
	
func on_client_player_connected():
	main_menu_control.visible = false
	lobby_menu_control.visible = true
	seed_input.visible = false
	play_button.visible = false
	
	emit_signal("to_lobby_menu")
	
func on_lobby_player_update(players :Array):
	emit_signal("lobby_player_update", players)
	
func _on_play_button_pressed():
	var seed_value :int =  int(seed_input.text) if seed_input.text != "" else int(rand_range(-100,100))
	NetworkLobbyManager.argument["seed"] = seed_value
	NetworkLobbyManager.set_host_ready()
	get_tree().change_scene("res://gameplay/mp/host/battle.tscn")
	
func on_host_ready():
	get_tree().change_scene("res://gameplay/mp/client/battle.tscn")
	
func _on_leave_button_pressed():
	NetworkLobbyManager.leave()
	
func on_leave():
	main_menu_control.visible = true
	lobby_menu_control.visible = false
	emit_signal("to_main_menu")























