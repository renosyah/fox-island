extends BaseUi

onready var virtual_joystick = $CanvasLayer/Control/virtual_joystick
onready var camera_control = $CanvasLayer/Control/camera_control
onready var fire = $CanvasLayer/Control/fire
onready var jump = $CanvasLayer/Control/jump
onready var fps = $CanvasLayer/Control/VBoxContainer/fps
onready var ping = $CanvasLayer/Control/VBoxContainer/ping
onready var loading = $CanvasLayer/loading

func _ready():
	Network.connect("on_ping", self, "on_ping")
	
func on_ping(_ping :int):
	ping.text = "Ping : " + str(_ping) + "/ms"
	
func _process(delta):
	fps.text = "Fps : " +  str(Engine.get_frames_per_second())
	
func loading(_show :bool):
	.loading(_show)
	loading.visible = _show

func is_fire_pressed():
	return fire.pressed
	
func is_jump_pressed():
	return jump.pressed
	
func joystick_move_direction() -> Vector2:
	return virtual_joystick.get_output()
	
func camera_facing_direction() -> Vector2:
	return camera_control.get_facing_direction()
	
