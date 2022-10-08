extends Spatial
class_name DayNightDome

signal morning
signal night

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _on_morning_time():
	emit_signal("morning")
	
func _on_night_time():
	emit_signal("night")
