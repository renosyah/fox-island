extends MineableResource
export var mesh_model :Mesh

var mesh :MeshInstance
var tween :Tween
var hp_bar :HpBar3D
var collision :CollisionShape

remotesync func _take_damage(_hp_left, _damage : int) -> void:
	._take_damage(_hp_left, _damage)
	hp_bar.update_bar(_hp_left, max_hp)
	
	tween.interpolate_property(mesh, "scale", Vector3.ONE * 0.6, Vector3.ONE, 0.3)
	tween.interpolate_property(hp_bar, "modulate:a", 1, 0, 4)
	tween.start()
	
remotesync func _dead() -> void:
	._dead()
	set_visible(false)
	hp_bar.update_bar(0, max_hp)
	
func set_visible(_show :bool):
	collision.set_deferred("disabled", not _show)
	visible = _show
	
# Called when the node enters the scene tree for the first time.
func _ready():
	mesh = MeshInstance.new()
	add_child(mesh)
	mesh.mesh = mesh_model
	mesh.create_convex_collision()
	
	collision = mesh.get_child(0).get_child(0)
	mesh.get_child(0).remove_child(collision)
	add_child(collision)
	mesh.get_child(0).queue_free()
	
	tween = Tween.new()
	add_child(tween)
	
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.autostart = true
	add_child(timer)
	
	yield(timer,"timeout")
	timer.queue_free()
	
	hp_bar = preload("res://assets/ui/bar-3d/hp_bar_3d.tscn").instance()
	add_child(hp_bar)
	hp_bar.translation.y -= 1
	hp_bar.modulate.a = 0
	hp_bar.update_bar(hp, max_hp)
	








