extends Spatial

signal on_generating_map(message, progress, max_progress)
signal on_generate_map_completed

const map_chunk = preload("res://map/map_chunk/map_chunk.tscn")

export var map_seed :int = 1
export var map_size :int = 200
export var map_height :int = 20
export var chunk_size :int = 25

var recomended_spawn_pos :Vector3 = Vector3.ZERO
	
var chunks = []
var thread = Thread.new()
	
func get_recomended_spawn_position() -> Vector3:
	var spawn_pos = get_rand_pos(global_transform.origin)
	spawn_pos.y += 8
	return spawn_pos
	
func _ready():
	connect("on_generate_map_completed", self, "_on_generate_map_completed")
	set_process(false)
	
func _on_generate_map_completed():
	set_process(true)
	
func _process(delta):
	var camera :Camera = get_viewport().get_camera()
	if not is_instance_valid(camera):
		return
		
	var camera_origin :Vector3 = Vector3(
		camera.global_transform.origin.x ,0.0, camera.global_transform.origin.z
	)
	
	for chunk in chunks:
		var chunk_origin :Vector3 = Vector3(
			chunk.global_transform.origin.x ,0.0, chunk.global_transform.origin.z
		)
		var distance :float = stepify(chunk_origin.distance_to(camera_origin), 1.0)
		var is_camera_close = distance < 60.0
		var is_camera_so_close = stepify(distance, 1.0) < 40.0
		var is_camera_too_close = stepify(distance, 1.0) < 20.0
		chunk.show_chunk(is_camera_close, is_camera_so_close, is_camera_too_close)
	
#func _exit_tree():
#	thread.wait_to_finish()
	
func generate_map():
	_generate_map()
#	if not thread.is_active():
#		thread.start(self, "_generate_map")
	
func _generate_map():
	var noise = OpenSimplexNoise.new()
	noise.seed = map_seed
	noise.octaves = 4
	noise.period = 80.0
	
	var chunk_pos = []
	for x in range(-map_size / 2, map_size / 2, chunk_size):
		for z in range(map_size / 2, -map_size / 2, -chunk_size):
			chunk_pos.append(Vector3(x, 0.0, z))
			
	var cursor = 0
	var inland_positions = []
	
	for pos in chunk_pos:
		var chunk = map_chunk.instance()
		chunk.size = chunk_size
		chunk.height = map_height
		chunk.noise = noise
		chunk.noise_offset = pos
		add_child(chunk)
		chunks.append(chunk)
		chunk.translation = pos
		chunk.generate()
		emit_signal("on_generating_map", "", cursor, chunk_pos.size())
		inland_positions.append_array(chunk.hight_vertex_points)
		cursor += 1
		
	for pos in inland_positions:
		if pos.y > recomended_spawn_pos.y:
			recomended_spawn_pos = pos
			
		
	var water = _create_water()
	add_child(water)
	
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1
	timer.start()
	
	yield(timer, "timeout")
	timer.queue_free()
	
	emit_signal("on_generate_map_completed")
	
func _create_water() -> MeshInstance:
	var water_mesh = PlaneMesh.new()
	water_mesh.size = Vector2(map_size, map_size) * 2
	
	var water_mesh_instance = MeshInstance.new()
	water_mesh_instance.mesh = water_mesh
	water_mesh_instance.set_surface_material(0, preload("res://map/water_shadermaterial.tres"))
	
	water_mesh_instance.cast_shadow = false
	water_mesh_instance.generate_lightmap = false
	water_mesh_instance.software_skinning_transform_normals = false
	
	return water_mesh_instance
	
func get_rand_pos(from :Vector3) -> Vector3:
	var angle := rand_range(0, TAU)
	var distance := rand_range(0, 5)
	var posv2 = polar2cartesian(distance, angle)
	var posv3 = from + Vector3(posv2.x, 0.0, posv2.y)
	return posv3
	
