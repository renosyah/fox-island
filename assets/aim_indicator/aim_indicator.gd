extends Spatial

onready var trail = $trail
onready var mesh_instance = $MeshInstance

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func show_aim_at(aim :CameraAimingData, is_valid :bool) -> void:
	var color :Color =  Color.white if is_valid else Color.red
	trail.color = color
	mesh_instance.get_surface_material(0).albedo_color = color
	translation = aim.position
