extends MineableResource
export var mesh_model :Mesh

var mesh :MeshInstance
var tween :Tween
var hp_bar :HpBar3D
var collision :CollisionShape
var visibility_notifier :VisibilityNotifier
var audio :AudioStreamPlayer3D
var hit_particle :CPUParticles

var _mine_sound = preload("res://entity/resources/sound/mine_rock.wav")
var _hit_particle :HitParticle

remotesync func _take_damage(_hp_left, _damage : int) -> void:
	._take_damage(_hp_left, _damage)
	hp_bar.update_bar(_hp_left, max_hp)
	
	audio.stream = _mine_sound
	audio.play()
	
	_hit_particle.display_hit(str(_damage))
	_hit_particle.translation = global_transform.origin + Vector3(0, 0.8, 0)
	
	tween.interpolate_property(mesh, "scale", Vector3.ONE * 0.6, Vector3.ONE, 0.3)
	tween.interpolate_property(hp_bar, "modulate:a", 1, 0, 4)
	tween.start()
	
remotesync func _dead() -> void:
	._dead()
	
	_hit_particle.display_hit("Wack!")
	_hit_particle.translation = global_transform.origin + Vector3(0, 0.8, 0)
	
	set_visible(false)
	hp_bar.update_bar(0, max_hp)
	
func set_visible(_show :bool):
	collision.set_deferred("disabled", not _show)
	mesh.visible = _show
	hp_bar.visible = _show
	
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
	
# Called when the node enters the scene tree for the first time.
func _ready():
	audio = AudioStreamPlayer3D.new()
	audio.unit_db = Global.sound_amplified
	add_child(audio)
	
	mesh = MeshInstance.new()
	add_child(mesh)
	mesh.mesh = mesh_model
	mesh.create_convex_collision()
	
	collision = mesh.get_child(0).get_child(0)
	mesh.get_child(0).remove_child(collision)
	add_child(collision)
	mesh.get_child(0).queue_free()
	
	mesh.cast_shadow = true
	mesh.generate_lightmap = false
	mesh.software_skinning_transform_normals = false
	
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
		
	_hit_particle = preload("res://assets/hit_particle/hit_particle.tscn").instance()
	add_child(_hit_particle)
	_hit_particle.set_as_toplevel(true)
	
