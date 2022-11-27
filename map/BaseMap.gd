extends StaticBody
class_name BaseMap

const land_shader = preload("res://map/shadermaterial.tres")
const water_shader = preload("res://map/water_shadermaterial.tres")

signal on_created_inland_position(inland_positions)
signal on_generating_map(message, progress, max_progress)
signal on_generate_map_completed

const GENERATING_LAND = "LAND"
const GENERATING_RESOURCE = "RESOURCE"

export var map_seed :int = 1
export var map_size :float = 200
export var map_scale :float = 1
export var map_land_color :Color = Color(0, 0.282353, 0.039216)
export var map_sand_color :Color = Color(0.521569, 0.380392, 0)
export var map_water_color :Color = Color(0, 0.196078, 0.392157)
export var map_height :int = 20

var thread = Thread.new()
var recomended_spawn_pos :Vector3 = Vector3.ZERO

var water :MeshInstance
var land_mesh :MeshInstance
var collision :CollisionShape
var inland_positions :Array = []

onready var _land_shader :ShaderMaterial = land_shader
onready var _water_shader :ShaderMaterial = water_shader

func _ready():
	map_land_color = Color(
		stepify(map_land_color.r, 0.01),
		stepify(map_land_color.g, 0.01),
		stepify(map_land_color.b, 0.01),
		1.0
	)
	map_sand_color = Color(
		stepify(map_sand_color.r, 0.01),
		stepify(map_sand_color.g, 0.01),
		stepify(map_sand_color.b, 0.01),
		1.0
	)
	
	_land_shader.set_shader_param("grass_color", map_land_color)
	_land_shader.set_shader_param("sand_color", map_sand_color)
	_water_shader.set_shader_param("out_color", map_water_color)
	
	connect("on_created_inland_position", self, "_on_created_inland_position")
	
func _on_created_inland_position(pos):
	inland_positions = pos
	
func get_recomended_spawn_position() -> Vector3:
	var spawn_pos = get_rand_pos(recomended_spawn_pos)
	spawn_pos.y += 1
	return spawn_pos
		
func get_water_height():
	if not is_instance_valid(water):
		return 0.0
		
	return water.global_transform.origin.y
	
func _exit_tree():
	thread.wait_to_finish()
	
func generate_map():
	if not thread.is_active():
		thread.start(self, "_generate_map")

func _generate_map():
	var noise = NoiseMaker.new()
	noise.make_noise(map_seed, 3)
	
	var lands = _create_land(noise)
	land_mesh = lands[0]
	var _inland_positions = lands[1]
	add_child(land_mesh)
	
	emit_signal("on_created_inland_position", _inland_positions)
	
	land_mesh.cast_shadow = false
	land_mesh.generate_lightmap = false
	land_mesh.software_skinning_transform_normals = false
	
	emit_signal("on_generating_map", GENERATING_LAND, 0, 1)
	
	collision = land_mesh.get_child(0).get_child(0)
	land_mesh.get_child(0).remove_child(collision)
	add_child(collision)
	land_mesh.get_child(0).queue_free()
	
	water = _create_water()
	add_child(water)
	
	var grass = _generate_grass(land_mesh.mesh)
	add_child(grass)
	
	var stuff_pos = 1
	var stuffs = _create_spawn_stuff(_inland_positions)
	for stuff in stuffs:
		emit_signal("on_generating_map", GENERATING_RESOURCE, stuff_pos, stuffs.size())
		stuff.set_network_master(Network.PLAYER_HOST_ID)
		add_child(stuff)
		stuff_pos += 1
	
	emit_signal("on_generate_map_completed")
	
	
func _create_spawn_stuff(inland_positions :Array) -> Array:
	var stuffs = []
	
	var rng = RandomNumberGenerator.new()
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
			
		var index :int = rng.randi_range(0, _resources.size() - 1)
		var res :Resource = _resources[index]
		var y_rotate = rng.randi_range(0, 180)
		
		stuffs.append(
			_resources_instance_placement(res, pos, y_rotate)
		)
		
	return stuffs
	
func _trim_array(arr :Array, step :int) -> Array:
	var new_arr = []
	for i in range(0, arr.size(), step):
		new_arr.append(arr[i])
		
	return new_arr
	
func _create_land(noise :NoiseMaker) -> Array:
	var inland_positions :Array = []
	
	var land_mesh = PlaneMesh.new()
	land_mesh.size = Vector2(map_size, map_size)
	land_mesh.subdivide_width = map_size * 0.5
	land_mesh.subdivide_depth = map_size * 0.5

	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(land_mesh, 0)
	
	var array_plane = surface_tool.commit()
	
	var data_tool = MeshDataTool.new()
	data_tool.create_from_surface(array_plane, 0)
	
	var gradient = CustomGradientTexture.new()
	gradient.gradient = Gradient.new()
	gradient.type = CustomGradientTexture.GradientType.RADIAL
	gradient.size = Vector2.ONE * map_size + Vector2.ONE
	
	var data = gradient.get_data()
	data.lock()
	
	for i in range(data_tool.get_vertex_count()):
		var vertext = data_tool.get_vertex(i)
		var value = noise.get_noise(vertext * map_scale)
		var gradient_value = data.get_pixel((vertext.x + map_size) * 0.5, (vertext.z + map_size) * 0.5).r * 2.2
		value -= gradient_value
		value = clamp(value, -0.075, 1)
		vertext.y = value * (map_height + 2.0)
		if value > 0.15:
			inland_positions.append(vertext)
			
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
	land_mesh_instance.set_surface_material(0, _land_shader)
	land_mesh_instance.create_trimesh_collision()

	return [land_mesh_instance, inland_positions]
	
func _create_water() -> MeshInstance:
	var water_mesh = PlaneMesh.new()
	water_mesh.size = Vector2(map_size, map_size) * 2
	
	var water_mesh_instance = MeshInstance.new()
	water_mesh_instance.mesh = water_mesh
	water_mesh_instance.set_surface_material(0, _water_shader)
	
	water_mesh_instance.cast_shadow = false
	water_mesh_instance.generate_lightmap = false
	water_mesh_instance.software_skinning_transform_normals = false
	
	return water_mesh_instance
	
func _generate_grass(land_mesh :Mesh):
	var grass :Grass = preload("res://addons/grass/Grass.tscn").instance()
	grass.grass_color = map_land_color
	grass.mesh = land_mesh
	return grass
	
func _resources_instance_placement(resources_instance :Resource, _pos :Vector3, _y_rotate :float) -> MineableResource:
	var instance :MineableResource = resources_instance.instance()
	instance.name = "resources-" + _str(_pos.x) + "-" + _str(_pos.y)+ "-" + _str(_pos.z)
	instance.translation = _pos
	instance.rotation_degrees.y = _y_rotate
	return instance
	
func get_rand_pos(from :Vector3) -> Vector3:
	var angle := rand_range(0, TAU)
	var distance := rand_range(5, 15)
	var posv2 = polar2cartesian(distance, angle)
	var posv3 = from + Vector3(posv2.x, 0.0, posv2.y)
	return posv3
	
func get_random_radius_pos() -> Vector3:
	var angle := rand_range(0, TAU)
	var distance := rand_range(150, 160)
	var posv2 = polar2cartesian(distance, angle)
	var posv3 = global_transform.origin + Vector3(posv2.x, 0.0, posv2.y)
	posv3.y = get_water_height()
	return posv3
	
func _str(i :float) -> String:
	return str(stepify(i, 0.01))
