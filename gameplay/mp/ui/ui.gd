extends BaseUi
	
signal on_jump_on_press
signal on_dodge_on_press
signal on_fast_attack_on_press
signal on_heavy_attack_on_press
signal on_respawn_press
signal on_exit

onready var aim = $CanvasLayer/aim

onready var virtual_joystick = $CanvasLayer/Control/VBoxContainer/HBoxContainer/virtual_joystick
onready var camera_control = $CanvasLayer/Control/MarginContainer2/camera_control
onready var loading_bar =  $CanvasLayer/loading/VBoxContainer/loading_bar
onready var loading_label = $CanvasLayer/loading/VBoxContainer/Label
onready var hp_bar = $CanvasLayer/Control/VBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/hp_bar
onready var player_name = $CanvasLayer/Control/VBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/player_name

onready var control = $CanvasLayer/Control
onready var loading = $CanvasLayer/loading
onready var deadscreen = $CanvasLayer/deadscreen
onready var menu = $CanvasLayer/menu

onready var fast_attack_button = $CanvasLayer/Control/MarginContainer2/VBoxContainer2/HBoxContainer/VBoxContainer/fast_attack
onready var heavy_attack_button = $CanvasLayer/Control/MarginContainer2/VBoxContainer2/HBoxContainer/VBoxContainer/MarginContainer3/heavy_attack
onready var dodge = $CanvasLayer/Control/MarginContainer2/VBoxContainer2/HBoxContainer/VBoxContainer/MarginContainer3/dodge

func _ready():
	control.visible = true
	deadscreen.visible = false
	loading.visible = false
	menu.visible = false
	
	Global.connect("on_setting_update", self, "on_setting_update")
	camera_control.inverted_axis = Global.setting_data.is_invert_y
	
func on_setting_update():
	 camera_control.inverted_axis = Global.setting_data.is_invert_y
	
func set_action_enable(can_attack, can_roll :bool):
	fast_attack_button.enable_button = can_attack
	heavy_attack_button.enable_button = can_attack
	dodge.enable_button = can_roll
	
func set_player_name(_name :String):
	player_name.text = _name
	
func show_deadscreen():
	control.visible = false
	deadscreen.visible = true
	
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
