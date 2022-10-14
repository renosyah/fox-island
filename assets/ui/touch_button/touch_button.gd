extends MarginContainer
class_name CustomTouchButton

signal on_press

var pressed :bool = false

var _touch_index : int = -1
var _is_pressed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _input(event : InputEvent):
	if event is InputEventScreenTouch:
		if event.pressed:
			if _is_point_inside_area(event.position) and _touch_index == -1:
				pressed = true
				_touch_index = event.index
				get_viewport().set_input_as_handled()
				
		elif event.index == _touch_index:
			_touch_index = -1
			pressed = false
			_is_pressed = false
			get_tree().set_input_as_handled()
			
func _process(delta):
	if pressed and not _is_pressed:
		emit_signal("on_press")
		_is_pressed = true
		
func _is_point_inside_area(point: Vector2) -> bool:
	var x: bool = point.x >= rect_global_position.x and point.x <= rect_global_position.x + (rect_size.x * get_global_transform_with_canvas().get_scale().x)
	var y: bool = point.y >= rect_global_position.y and point.y <= rect_global_position.y + (rect_size.y * get_global_transform_with_canvas().get_scale().y)
	return x and y
