extends Spatial
class_name DayNightDome

signal morning
signal night

export var enable :bool = true
onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	if enable:
		animation_player.play("day_night_cicle")
	else:
		animation_player.stop()
	
func _on_morning_time():
	emit_signal("morning")
	
func _on_night_time():
	emit_signal("night")
