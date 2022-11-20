extends BaseUi
	
signal on_jump_on_press
signal on_dodge_on_press
signal on_fast_attack_on_press
signal on_heavy_attack_on_press

signal on_call_ally
signal on_command_ally
signal on_command_follow

signal on_respawn_press
signal on_exit

onready var aim = $CanvasLayer/aim

onready var virtual_joystick = $CanvasLayer/Control/VBoxContainer/HBoxContainer/virtual_joystick
onready var camera_control = $CanvasLayer/Control/Control/camera_control
onready var loading_bar = $CanvasLayer/loading/VBoxContainer/loading_bar
onready var loading_label = $CanvasLayer/loading/VBoxContainer/Label
onready var hp_bar = $CanvasLayer/Control/VBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/hp_bar
onready var player_name = $CanvasLayer/Control/VBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/player_name

onready var control = $CanvasLayer/Control
onready var loading = $CanvasLayer/loading
onready var deadscreen = $CanvasLayer/deadscreen
onready var winscreen = $CanvasLayer/winscreen
onready var menu = $CanvasLayer/menu


onready var fast_attack_button = $CanvasLayer/Control/Control/VBoxContainer2/HBoxContainer/VBoxContainer/fast_attack
onready var heavy_attack_button = $CanvasLayer/Control/Control/VBoxContainer2/HBoxContainer/VBoxContainer/MarginContainer3/heavy_attack
onready var dodge = $CanvasLayer/Control/Control/VBoxContainer2/HBoxContainer/VBoxContainer/MarginContainer3/dodge

onready var follow = $CanvasLayer/Control/Control/VBoxContainer2/MarginContainer4/VBoxContainer/follow
onready var command = $CanvasLayer/Control/Control/VBoxContainer2/MarginContainer4/VBoxContainer/command
onready var call = $CanvasLayer/Control/Control/VBoxContainer2/MarginContainer4/VBoxContainer/call

onready var mission_info = $CanvasLayer/VBoxContainer
onready var mission_info_label = $CanvasLayer/VBoxContainer/Label2

onready var tween = $Tween

func _ready():
	control.visible = true
	deadscreen.visible = false
	loading.visible = false
	menu.visible = false
	
	aim.visible = false
	follow.visible = false
	command.visible = true
	
	Global.connect("on_setting_update", self, "on_setting_update")
	camera_control.inverted_axis = Global.setting_data.is_invert_y
	
func on_setting_update():
	 camera_control.inverted_axis = Global.setting_data.is_invert_y
	
func set_action_enable(can_attack, can_roll :bool):
	fast_attack_button.enable_button = can_attack
	heavy_attack_button.enable_button = can_attack
	dodge.enable_button = can_roll
	
func show_call_ally_button(_show :bool):
	call.visible = _show
	
func update_mission_info(outpost_count :int):
	if outpost_count == 0:
		show_winscreen()
		return
		
	mission_info_label.text = str(outpost_count) + " Remaining"
	_on_show_mission_pressed()
	
func set_player_name(_name :String):
	player_name.text = _name
	
func show_deadscreen():
	control.visible = false
	deadscreen.visible = true
	
func show_winscreen():
	control.visible = false
	winscreen.visible = true
	
func update_bar(hp, max_hp : int):
	hp_bar.update_bar(hp, max_hp)

func loading(_show :bool):
	.loading(_show)
	loading.visible = _show
	
func _on_jump_on_press():
	emit_signal("on_jump_on_press")
	
func _on_dodge_on_press():
	emit_signal("on_dodge_on_press")
	
func _on_fast_attack_on_press():
	emit_signal("on_fast_attack_on_press")
	
func _on_heavy_attack_on_press():
	emit_signal("on_heavy_attack_on_press")
	
func _on_respawn_pressed():
	control.visible = true
	deadscreen.visible = false
	emit_signal("on_respawn_press")
	
func loading_message(message :String, progress, max_progress :int):
	.loading_message(message, progress, max_progress)
	var prog = (float(progress) / float(max_progress)) * 100.0
	loading_label.text = "Generating island ({progress}%)".format({"progress": stepify(prog, 1.0)})
	loading_bar.update_bar(progress, max_progress)
	
func joystick_move_direction() -> Vector2:
	return virtual_joystick.get_output()
	
func camera_input_direction() -> Vector2:
	return camera_control.get_input_direction()
	
func get_crosshair_position() -> Vector2:
	return aim.rect_position
	
func _on_menu_pressed():
	menu.visible = true
	
func _on_menu_on_main_menu_press():
	emit_signal("on_exit")
	
func _on_call_on_press():
	emit_signal("on_call_ally")
	
func _on_command_pressed():
	aim.visible = true
	follow.visible = true
	command.visible = false
	emit_signal("on_command_ally")
	
func _on_follow_pressed():
	aim.visible = false
	follow.visible = false
	command.visible = true
	emit_signal("on_command_follow")
	
func _on_show_mission_pressed():
	tween.interpolate_property(mission_info, "modulate:a", 1.0, 0.0, 4.5, Tween.TRANS_SINE)
	tween.start()
	
func _on_win_exit_pressed():
	emit_signal("on_exit")
