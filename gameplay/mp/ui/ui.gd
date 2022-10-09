extends BaseUi

onready var virtual_joystick = $CanvasLayer/Control/VBoxContainer/HBoxContainer/virtual_joystick
onready var camera_control = $CanvasLayer/Control/MarginContainer2/camera_control
onready var fire = $CanvasLayer/Control/MarginContainer2/VBoxContainer2/HBoxContainer/VBoxContainer/fire
onready var jump = $CanvasLayer/Control/MarginContainer2/VBoxContainer2/HBoxContainer/VBoxContainer/MarginContainer3/jump2
onready var loading = $CanvasLayer/loading
onready var dodge = $CanvasLayer/Control/MarginContainer2/VBoxContainer2/HBoxContainer/VBoxContainer/MarginContainer3/dodge
onready var loading_bar =  $CanvasLayer/loading/VBoxContainer/loading_bar
onready var loading_label = $CanvasLayer/loading/VBoxContainer/Label

func _ready():
	pass

func loading(_show :bool):
	.loading(_show)
	loading.visible = _show
	
func loading_message(message :String, progress, max_progress :int):
	.loading_message(message, progress, max_progress)
	if message == BaseMap.GENERATING_RESOURCE:
		loading_label.text = "Spawn resources ({progress}/{max_progress})".format({"progress": progress, "max_progress" :max_progress})
		
	elif message == BaseMap.GENERATING_LAND:
		loading_label.text = "Generate island ({progress}/{max_progress})".format({"progress": progress, "max_progress" :max_progress})
		
	loading_bar.update_bar(progress, max_progress)
	
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
	
