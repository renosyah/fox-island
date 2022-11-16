extends Spatial

onready var trail = $trail

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func show_aim_at(pos :Vector3, is_valid :bool, delta :float) -> void:
	trail.color = Color.white if is_valid else Color.red
	translation = pos
