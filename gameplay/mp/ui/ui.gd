extends BaseUi
	
signal on_jump_on_press
signal on_dodge_on_press
signal on_fast_attack_on_press
signal on_heavy_attack_on_press
	
onready var virtual_joystick = $CanvasLayer/Control/VBoxContainer/HBoxContainer/virtual_joystick
onready var camera_control = $CanvasLayer/Control/MarginContainer2/camera_control
onready var loading = $CanvasLayer/loading
onready var loading_bar =  $CanvasLayer/loading/VBoxContainer/loading_bar
onready var loading_label = $CanvasLayer/loading/VBoxContainer/Label
onready var hp_bar = $CanvasLayer/Control/VBoxContainer/MarginContainer/HBoxContainer/hp_bar

func _ready():
	pass

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
	
func loading_message(message :String, progress, max_progress :int):
	.loading_message(message, progress, max_progress)
	if message == BaseMap.GENERATING_RESOURCE:
		loading_label.text = "Spawn resources ({progress}/{max_progress})".format({"progress": progress, "max_progress" :max_progress})
		
	elif message == BaseMap.GENERATING_LAND:
		loading_label.text = "Generate island ({progress}/{max_progress})".format({"progress": progress, "max_progress" :max_progress})
		
	loading_bar.update_bar(progress, max_progress)
	
func joystick_move_direction() -> Vector2:
	return virtual_joystick.get_output()
	
func camera_facing_direction() -> Vector2:
	return camera_control.get_facing_direction()
	
