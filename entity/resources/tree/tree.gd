extends MineableResource
export var mesh_model :Mesh

var mesh :MeshInstance
var tween :Tween

remotesync func _take_damage(_hp_left, _damage : int) -> void:
	._take_damage(_hp_left, _damage)
	tween.interpolate_property(mesh, "scale", Vector3.ONE * 0.6, Vector3.ONE, 0.6)
	tween.start()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	mesh = MeshInstance.new()
	add_child(mesh)
	mesh.mesh = mesh_model
	mesh.create_convex_collision()
	
	var collision = mesh.get_child(0).get_child(0)
	mesh.get_child(0).remove_child(collision)
	add_child(collision)
	mesh.get_child(0).queue_free()
	
	tween = Tween.new()
	add_child(tween)
