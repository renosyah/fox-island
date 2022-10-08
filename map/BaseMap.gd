extends StaticBody
class_name BaseMap

signal on_generate_map_completed

export var map_seed :int = 1
export var map_size :float = 200
export var map_scale :float = 1
export var map_land_shander : Resource = preload("res://map/shadermaterial.tres")
export var map_water_shander : Resource = preload("res://map/water_shadermaterial.tres")
export var map_height :int = 20

export var max_stuff = 120
export var stuff_directory = "res://map/model/"

var thread = Thread.new()
var recomended_spawn_pos :Vector3

func get_recomended_spawn_position() -> Vector3:
	return get_rand_pos(recomended_spawn_pos)

func _ready():
	pass
	
func _exit_tree():
	thread.wait_to_finish()
	
func generate_map():
	if not thread.is_active():
		thread.start(self, "_generate_map")
		
func _generate_map():
	var noise = OpenSimplexNoise.new()
	noise.seed = map_seed
	noise.octaves = 4
	noise.period = 80.0
	
	var custom_gradient = CustomGradientTexture.new()
	custom_gradient.gradient = Gradient.new()
	custom_gradient.type = CustomGradientTexture.GradientType.RADIAL
	custom_gradient.size = Vector2.ONE * map_size + Vector2.ONE

	var land = _create_land(noise, custom_gradient)
	add_child(land)

	var water = _create_water()
	add_child(water)
	
	var grass = _generate_grass(land.mesh)
	add_child(grass)
	
	translation.y = 3.0
	
	var stuffs = _create_spawn_stuff(noise, custom_gradient)
	for stuff in stuffs:
		get_parent().add_child(stuff)
	
	emit_signal("on_generate_map_completed")
	
	
func _create_spawn_stuff(noise :OpenSimplexNoise, gradient :CustomGradientTexture) -> Array:
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
	
	var data = gradient.get_data()
	data.lock()
	
	var _half_size = int(map_size * 0.5)
	for x in range(-_half_size, _half_size, 8):
		if rng.randf() > 0.6:
			continue
			
		for z in range(-_half_size, _half_size, 8):
			if rng.randf() > 0.6:
				continue
			
			var _pos = Vector3(x ,0.0, z)
			var _value = noise.get_noise_3d(_pos.x * map_scale , 0.0, _pos.z * map_scale)
			var gradient_value = data.get_pixel((_pos.x + map_size) * 0.5, (_pos.z + map_size) * 0.5).r * 0.8
			var _value_c = _value
			_value -= gradient_value
			if _value > 0.0:
				_pos.y = _value * map_height
				
				if _pos.y > 5:
					recomended_spawn_pos = _pos
				
				stuffs.append(
					_resources_instance_placement(
						_resources, _pos, clamp(int(_value_c * 20), 0, _resources.size() - 1)
					)
				)
				
	data.unlock()
	return stuffs
	
func _create_land(noise :OpenSimplexNoise, gradient :CustomGradientTexture) -> MeshInstance:
	var land_mesh = PlaneMesh.new()
	land_mesh.size = Vector2(map_size, map_size)
	land_mesh.subdivide_width = map_size * 0.5
	land_mesh.subdivide_depth = map_size * 0.5

	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(land_mesh, 0)
	
	var array_plane = surface_tool.commit()
	
	var data_tool = MeshDataTool.new()
	data_tool.create_from_surface(array_plane, 0)
	
	var data = gradient.get_data()
	data.lock()
	
	for i in range(data_tool.get_vertex_count()):
		var vertext = data_tool.get_vertex(i)
		var value = noise.get_noise_3d(vertext.x * map_scale ,vertext.y * map_scale, vertext.z * map_scale)
		var gradient_value = data.get_pixel((vertext.x + map_size) * 0.5, (vertext.z + map_size) * 0.5).r * 0.8
		value -= gradient_value
		value = clamp(value, -0.075, 2)
		vertext.y = value * (map_height + 2.0)
		data_tool.set_vertex(i, vertext)
		
	data.unlock()
	
	for i in range(array_plane.get_surface_count()):
		array_plane.surface_remove(i)
		
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
	
	var land_mesh_instance = MeshInstance.new()
	land_mesh_instance.mesh = surface_tool.commit()
	land_mesh_instance.set_surface_material(0, map_land_shander)
	land_mesh_instance.create_trimesh_collision()
	
	return land_mesh_instance
	
func _create_water() -> MeshInstance:
	var water_mesh = PlaneMesh.new()
	water_mesh.size = Vector2(map_size, map_size) * 2
	
	var water_mesh_instance = MeshInstance.new()
	water_mesh_instance.mesh = water_mesh
	water_mesh_instance.set_surface_material(0, map_water_shander)
	return water_mesh_instance
	
func _generate_grass(land_mesh :Mesh):
	var grass :Grass = preload("res://addons/grass/Grass.tscn").instance()
	grass.mesh = land_mesh
	return grass
	
func _resources_instance_placement(_resources :Array, _pos :Vector3, pointer :int) -> MineableResource:
	var resources_instance :MineableResource = _resources[pointer].instance()
	resources_instance.name = "resources-" + _str(_pos.x) + "-" + _str(_pos.y)+ "-" + _str(_pos.z)
	resources_instance.translation = _pos
	resources_instance.translation.y += 3
	return resources_instance
	
func get_rand_pos(from :Vector3) -> Vector3:
	var angle := rand_range(0, TAU)
	var distance := rand_range(5, 15)
	var posv2 = polar2cartesian(distance, angle)
	var posv3 = from + Vector3(posv2.x, 0.0, posv2.y)
	posv3.y = 10
	return posv3
func _str(i :float) -> String:
	return str(stepify(i, 0.01))
