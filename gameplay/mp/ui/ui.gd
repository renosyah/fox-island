extends BaseUi

onready var virtual_joystick = $CanvasLayer/Control/VBoxContainer/HBoxContainer/virtual_joystick
onready var camera_control = $CanvasLayer/Control/MarginContainer2/camera_control
onready var fire = $CanvasLayer/Control/MarginContainer2/VBoxContainer2/HBoxContainer/VBoxContainer/fire
onready var jump = $CanvasLayer/Control/MarginContainer2/VBoxContainer2/HBoxContainer/VBoxContainer/MarginContainer3/jump2
onready var loading = $CanvasLayer/loading
onready var dodge = $CanvasLayer/Control/MarginContainer2/VBoxContainer2/HBoxContainer/VBoxContainer/MarginContainer3/dodge

func _ready():
	pass

func loading(_show :bool):
	.loading(_show)
	loading.visible = _show
	
func is_fire_pressed():
	return fire.pressed
	
func is_jump_pressed():
	return jump.pressed
	
func is_dodge_pressed():
	return dodge.pressed
	
func joystick_move_direction() -> Vector2:
	return virtual_joystick.get_output()
	
func camera_facing_direction() -> Vector2:
	return camera_control.get_facing_direction()
	
