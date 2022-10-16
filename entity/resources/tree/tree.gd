extends MineableResource
export var mesh_model :Mesh

var mesh :MeshInstance
var tween :Tween
var hp_bar :HpBar3D
var collision :CollisionShape
var visibility_notifier :VisibilityNotifier
var audio :AudioStreamPlayer3D

var _mine_sound = preload("res://entity/resources/sound/mine_wood.wav")

remotesync func _take_damage(_hp_left, _damage : int) -> void:
	._take_damage(_hp_left, _damage)
	hp_bar.update_bar(_hp_left, max_hp)
	
	audio.stream = _mine_sound
	audio.play()
	
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
	
func camera_entered(camera: Camera):
	if is_dead:
		return
		
	visible = true
	tween.interpolate_property(mesh, "scale", Vector3.ZERO, Vector3.ONE, 0.2)
	tween.start()
	
func camera_exited(camera: Camera):
	if is_dead:
		return
		
	visible = false
	
func _process(delta):
	var camera :Camera = get_viewport().get_camera()
	if not is_instance_valid(camera):
		return
		
	var camera_origin :Vector3 = camera.global_transform.origin
	var is_camera_close = global_transform.origin.distance_to(camera_origin) < 5
	
# Called when the node enters the scene tree for the first time.
func _ready():
	audio = AudioStreamPlayer3D.new()
	audio.unit_db = Global.sound_amplified
	add_child(audio)
	
	visible = false
	set_process(false)

	mesh = MeshInstance.new()
	add_child(mesh)
	mesh.mesh = mesh_model
	mesh.create_convex_collision()
	
	mesh.cast_shadow = true
	mesh.generate_lightmap = false
	mesh.software_skinning_transform_normals = false
	
	collision = mesh.get_child(0).get_child(0)
	mesh.get_child(0).remove_child(collision)
	add_child(collision)
	mesh.get_child(0).queue_free()
	
	tween = Tween.new()
	add_child(tween)
	
	visibility_notifier = VisibilityNotifier.new()
	add_child(visibility_notifier)
	visibility_notifier.connect("camera_entered", self, "camera_entered")
	visibility_notifier.connect("camera_exited", self, "camera_exited")
	
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
	







