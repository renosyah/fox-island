extends Spatial

export var icon : Texture = preload("res://addons/3d-marker/empty.png")
export var color : Color = Color.white
export(String, "show_offscreen", "show_onscreen", "show_always") var mode = "show_offscreen"
export(Vector2) var screen_border_offset = Vector2( 20.0, 20.0 )
export(bool) var is_tracked = true setget _set_tracked

var target_node: Spatial

var windowsize
onready var animate = $AnimationPlayer
onready var marker_item :Sprite = $marker_item
onready var marker_icon :Sprite3D = $marker_icon

func _ready():
	if icon:
		marker_icon.texture = icon
		marker_item.set_marker(icon, color)
		
	marker_item.visible = false
	set_process(false)
	
	var rect = marker_item.get_rect().size
	if screen_border_offset.x < rect.x:
		screen_border_offset.x = rect.x
	if screen_border_offset.y < rect.y:
		screen_border_offset.y = rect.y
		
	if is_tracked == true:
		set_process(true)
		
		
func _process(delta):
	if not target_node:
		target_node = get_parent()
		if not target_node:
			print("### error, can't find parent node for tracker")
			return
			
	var viewport_rect = marker_item.get_viewport_rect()
	var current_camera: Camera = get_tree().get_root().get_camera()
	if not current_camera:
			print("### error, can't find current scene camera")
			return
			
	var target_2d_position: Vector2 = current_camera.unproject_position(get_global_transform().origin)
	marker_item.position.x = clamp(target_2d_position.x, screen_border_offset.x, viewport_rect.size.x - screen_border_offset.x)
	marker_item.position.y = clamp(target_2d_position.y, screen_border_offset.y, viewport_rect.size.y - screen_border_offset.y)
	
	if viewport_rect.has_point(target_2d_position):
		target_2d_position = current_camera.unproject_position(target_node.get_global_transform().origin)
	
	marker_item.look_at( target_2d_position )
	if mode == "show_always":
		if not marker_item.visible and not animate.is_playing():
			animate.play("show")
			marker_icon.visible = false
		return
	
	elif mode == "show_offscreen":
		if viewport_rect.has_point(target_2d_position):
			if marker_item.visible and not animate.is_playing():
				animate.play("hide")
				marker_icon.visible = true
		else:
			if not marker_item.visible and not animate.is_playing():
				animate.play("show")
				marker_icon.visible = false
		return
		
	elif mode == "show_onscreen":
		if viewport_rect.has_point(target_2d_position):
			if not marker_item.visible and not animate.is_playing():
				animate.play("show")
				marker_icon.visible = true
		else:
			if marker_item.visible and not animate.is_playing():
				animate.play("hide")
				marker_icon.visible = false
		return
		
	else:
		print("error - set mode for target indicator unknown")
		return
		
func _set_tracked(tracked : bool):
	is_tracked = tracked
	if tracked == true:
		set_process(true)
	else:
		if visible:
			animate.play("hide")
			yield(animate, "animation_finished")
		set_process(false)
		
func set_marker(icon :Texture, color :Color):
	marker_item.set_marker(icon, color)
	
 
