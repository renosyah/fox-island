extends Spatial

signal on_generating_map(message, progress, max_progress)
signal on_generate_map_completed

const map_chunk = preload("res://map/map_chunk/map_chunk.tscn")

export var map_seed :int = 1
export var map_size :int = 200
export var map_height :int = 20
export var chunk_size :int = 50

var recomended_spawn_pos :Vector3 = Vector3.ZERO

var thread = Thread.new()
	
func get_recomended_spawn_position() -> Vector3:
	var spawn_pos = get_rand_pos(global_transform.origin)
	spawn_pos.y += 8
	return spawn_pos
	
func _ready():
	pass
	
#func _exit_tree():
#	thread.wait_to_finish()
#
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
		chunk.translation = pos
		chunk.generate()
		emit_signal("on_generating_map", "", cursor, chunk_pos.size())
		inland_positions.append_array(chunk.hight_vertex_points)
		cursor += 1
		
	cursor = 0
	var stuffs = _create_spawn_stuff(inland_positions)
	for stuff in stuffs:
		add_child(stuff)
		emit_signal("on_generating_map", "", cursor, stuffs.size())
		cursor += 1

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
	
func _create_spawn_stuff(inland_positions :Array) -> Array:
	var stuffs = []
	
	var rng  = RandomNumberGenerator.new()
	rng.seed = map_seed * 2
	
	var _resources = [
		preload("res://entity/resources/tree/bush_1/tree.tscn"),
		preload("res://entity/resources/tree/bush_2/tree.tscn"),
		preload("res://entity/resources/tree/bush_3/tree.tscn"),
		
		preload("res://entity/resources/stone/stone_1/stone.tscn"),
		preload("res://entity/resources/stone/stone_2/stone.tscn"),
		preload("res://entity/resources/stone/stone_3/stone.tscn"),
		
		preload("res://entity/resources/tree/tree_1/tree.tscn"),
		preload("res://entity/resources/tree/tree_2/tree.tscn"),
		preload("res://entity/resources/tree/tree_3/tree.tscn"),
		preload("res://entity/resources/tree/tree_4/tree.tscn"),
	]
	
	var trimed_inland_positions = _trim_array(inland_positions, 22)
	
	for pos in trimed_inland_positions:
		if pos.y > recomended_spawn_pos.y:
			recomended_spawn_pos = pos
			
		var index :int = int(rng.randf_range(0, _resources.size()))
		var res :Resource = _resources[index]
		
		stuffs.append(
			_resources_instance_placement(res, pos)
		)
		
	return stuffs
	
func _trim_array(arr :Array, step :int) -> Array:
	var new_arr = []
	for i in range(0, arr.size(), step):
		new_arr.append(arr[i])
		
	return new_arr
	
	
	
func _resources_instance_placement(resources_instance :Resource, _pos :Vector3) -> MineableResource:
	var instance :MineableResource = resources_instance.instance()
	instance.name = "resources-" + _str(_pos.x) + "-" + _str(_pos.y)+ "-" + _str(_pos.z)
	instance.translation = _pos
	return instance
	
func _str(i :float) -> String:
	return str(stepify(i, 0.01))
	
	
	
func get_rand_pos(from :Vector3) -> Vector3:
	var angle := rand_range(0, TAU)
	var distance := rand_range(0, 5)
	var posv2 = polar2cartesian(distance, angle)
	var posv3 = from + Vector3(posv2.x, 0.0, posv2.y)
	return posv3
	
