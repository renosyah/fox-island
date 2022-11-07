extends CustomTouchButton

export var colldown_time :float = 1.0
export var icon_button :Texture
onready var cooldown_timer = $cooldown
onready var texture_progress = $TextureProgress
onready var tween = $Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	cooldown_timer.wait_time = colldown_time
	texture_progress.max_value = colldown_time
	texture_progress.texture_under = icon_button if icon_button else preload("res://assets/ui/cooldown_touch_button/circle.png")
	
	rect_pivot_offset = rect_size / 2
	
func validate_press(delta):
	# full override
	#.validate_press(delta)
	
	if pressed and not _is_pressed:
		if cooldown_timer.is_stopped() and enable_button:
			tween.interpolate_property(self, "rect_scale", Vector2(0.9, 0.9), Vector2.ONE, 0.2)
			tween.start()
			
			emit_signal("on_press")
			cooldown_timer.start()
			
		_is_pressed = true
		
	texture_progress.value = cooldown_timer.time_left
	modulate.a = 1 if enable_button else 0.5
