extends Sprite3D
class_name Message3D

onready var _message = $Viewport/HBoxContainer/message
onready var _viewport = $Viewport

# Called when the node enters the scene tree for the first time.
func _ready():
	_message.text = "hello"
	texture = _viewport.get_texture()
	
func set_color(_color : Color):
	_message.modulate = _color
	
func set_message(_msg):
	_message.text = _msg
