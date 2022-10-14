extends Spatial
class_name DayNightDome

signal morning
signal night

onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func set_time(at :float, stop:bool = true):
	animation_player.seek(at, true)
	if stop:
		animation_player.stop()
	
func _on_morning_time():
	emit_signal("morning")
	
func _on_night_time():
	emit_signal("night")
