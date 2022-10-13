extends BaseUi

signal lobby_player_update(players)

onready var loading_bar = $CanvasLayer/loading/VBoxContainer/loading_bar
onready var loading_label = $CanvasLayer/loading/VBoxContainer/Label
onready var loading = $CanvasLayer/loading

onready var main_menu_control = $CanvasLayer/main_menu_control
onready var lobby_menu_control = $CanvasLayer/lobby_menu_control2
onready var server_browser = $CanvasLayer/server_browser

onready var seed_input = $CanvasLayer/lobby_menu_control2/HBoxContainer/MarginContainer4/HBoxContainer/VBoxContainer/seed
onready var play_button = $CanvasLayer/lobby_menu_control2/HBoxContainer/MarginContainer4/HBoxContainer/VBoxContainer/play_button

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	main_menu_control.visible = true
	lobby_menu_control.visible = false
	NetworkLobbyManager.connect("lobby_player_update", self, "on_lobby_player_update")
	NetworkLobbyManager.connect("on_leave", self, "on_leave")
	NetworkLobbyManager.connect("on_host_ready", self ,"on_host_ready")
	
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
	
func _on_host_button_pressed():
	var configuration = NetworkServer.new()
	configuration.max_player = 4
	
	NetworkLobbyManager.player_name = "host"
	NetworkLobbyManager.configuration = configuration
	NetworkLobbyManager.connect("on_host_player_connected", self,"on_host_player_connected")
	NetworkLobbyManager.init_lobby()
	
func on_host_player_connected():
	main_menu_control.visible = false
	lobby_menu_control.visible = true
	seed_input.visible = true
	play_button.visible = true
	
func _on_join_button_pressed():
	server_browser.start_finding()
	server_browser.show()
	
func _on_server_browser_on_join(info :Dictionary):
	var configuration = NetworkClient.new()
	configuration.ip = info["ip"]
	
	NetworkLobbyManager.player_name = "client"
	NetworkLobbyManager.configuration = configuration
	NetworkLobbyManager.connect("on_client_player_connected", self,"on_client_player_connected")
	NetworkLobbyManager.init_lobby()
	
func on_client_player_connected():
	main_menu_control.visible = false
	lobby_menu_control.visible = true
	seed_input.visible = false
	play_button.visible = false
	
func on_lobby_player_update(players :Array):
	emit_signal("lobby_player_update", players)

func _on_play_button_pressed():
	NetworkLobbyManager.argument["seed"] = int(seed_input.text)
	get_tree().change_scene("res://gameplay/mp/host/battle.tscn")
	
func on_host_ready():
	get_tree().change_scene("res://gameplay/mp/client/battle.tscn")
	
func _on_leave_button_pressed():
	NetworkLobbyManager.leave()
	
func on_leave():
	main_menu_control.visible = true
	lobby_menu_control.visible = false


















