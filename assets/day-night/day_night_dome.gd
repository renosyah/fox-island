extends Spatial
class_name DayNightDome

signal morning
signal night

const TIME_MORNING = 0
const TIME_AFTERNOON = 1
const TIME_DUSK = 2
const TIME_NIGHT = 3

onready var animation_player = $AnimationPlayer
var current_time :int = TIME_MORNING
var day_passed :int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func set_time(at :float, stop:bool = true):
	animation_player.seek(at, true)
	if stop:
		animation_player.stop()
	
func _on_morning_time():
	current_time = TIME_MORNING
	day_passed += 1
	emit_signal("morning")
	
func _on_night_time():
	current_time = TIME_NIGHT
	emit_signal("night")
