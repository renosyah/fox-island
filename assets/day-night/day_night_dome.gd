extends Spatial
class_name DayNightDome

signal morning
signal night

onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func set_enable(enable :bool):
	if enable:
		animation_player.play("day_night_cicle")
	else:
		animation_player.stop()
	
func set_time(at :float):
	animation_player.seek(at, true)
	
func _on_morning_time():
	emit_signal("morning")
	
func _on_night_time():
	emit_signal("night")
