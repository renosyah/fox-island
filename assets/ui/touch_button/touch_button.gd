extends MarginContainer
class_name CustomTouchButton

signal on_press

var enable_button :bool = true
var pressed :bool = false

var _touch_index : int = -1
var _is_pressed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _input(event : InputEvent):
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1:
			if _is_point_inside_area(event.position):
				pressed = true
				_touch_index = event.index
				get_viewport().set_input_as_handled()
				
		elif not event.pressed and event.index == _touch_index:
			_touch_index = -1
			pressed = false
			_is_pressed = false
			get_tree().set_input_as_handled()
			
func _process(delta):
	validate_press(delta)
	
func validate_press(delta):
	modulate.a = 1 if enable_button else 0.5
	if not enable_button:
		return
		
	if pressed and not _is_pressed:
		emit_signal("on_press")
		_is_pressed = true
		
	
func _is_point_inside_area(point: Vector2) -> bool:
	var x: bool = point.x >= rect_global_position.x and point.x <= rect_global_position.x + (rect_size.x * get_global_transform_with_canvas().get_scale().x)
	var y: bool = point.y >= rect_global_position.y and point.y <= rect_global_position.y + (rect_size.y * get_global_transform_with_canvas().get_scale().y)
	return x and y and visible
