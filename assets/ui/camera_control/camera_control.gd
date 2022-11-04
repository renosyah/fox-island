extends MarginContainer

export var inverted_axis :bool = true

var _facing_direction :Vector2 = Vector2.ZERO
var _touch_index : int = -1

func get_input_direction() -> Vector2:
	# product of current user input
	# from ui and will return
	# vector2 of UP, DOWN, LEFT & RIGHT
	if not inverted_axis:
		_facing_direction.y = -_facing_direction.y
		
	return _facing_direction
	
func _input(event : InputEvent):
	if event is InputEventScreenTouch:
		if event.pressed:
			if _is_point_inside_area(event.position) and _touch_index == -1:
				_touch_index = event.index
				get_tree().set_input_as_handled()
				
		elif event.index == _touch_index:
			_touch_index = -1
			_facing_direction = Vector2.ZERO
			get_tree().set_input_as_handled()
			
	elif event is InputEventScreenDrag:
		if event.index == _touch_index:
			_facing_direction = event.relative
			get_tree().set_input_as_handled()
			
		
func _process(delta):
	_facing_direction = _facing_direction.linear_interpolate(Vector2.ZERO , 25 * delta)
	
func _is_point_inside_area(point: Vector2) -> bool:
	var x: bool = point.x >= rect_global_position.x and point.x <= rect_global_position.x + (rect_size.x * get_global_transform_with_canvas().get_scale().x)
	var y: bool = point.y >= rect_global_position.y and point.y <= rect_global_position.y + (rect_size.y * get_global_transform_with_canvas().get_scale().y)
	return x and y
