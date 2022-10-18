extends StaticBody
class_name MapChunk

const land_shader = preload("res://map/shadermaterial.tres")

var size :int
var height :int
var noise :OpenSimplexNoise
var noise_offset :Vector3
var map_seed :int

var grass :Grass
var land_mesh :MeshInstance
var collision :CollisionShape
var highest_point :Vector3 = Vector3.ZERO
var holder :Spatial
var hight_vertex_points :Array = []

#var visibility_notifier :VisibilityNotifier

func _ready():
	set_process(false)
	
	holder = Spatial.new()
	add_child(holder)
#	visibility_notifier = VisibilityNotifier.new()
#	add_child(visibility_notifier)
#	visibility_notifier.aabb.size = Vector3.ONE * size
#	visibility_notifier.aabb.size.y = 60
#	visibility_notifier.max_distance = 100

func generate():
	land_mesh = _generate_land(noise)
	add_child(land_mesh)
	
	collision = land_mesh.get_child(0).get_child(0)
	land_mesh.get_child(0).remove_child(collision)
	add_child(collision)
	land_mesh.get_child(0).queue_free()
	
	grass = _generate_grass(land_mesh.mesh)
	add_child(grass)
	
	var stuffs = _create_spawn_stuff(hight_vertex_points)
	for stuff in stuffs:
		holder.add_child(stuff)
	
func show_chunk(_show_land, _show_stuff, _show_grass :bool):
	visible = _show_land
	holder.visible = _show_stuff
	grass.visible = _show_grass
	
func _generate_land(noise :OpenSimplexNoise) -> MeshInstance:
	var land_mesh = PlaneMesh.new()
	land_mesh.size = Vector2(size, size)
	land_mesh.subdivide_width = size * 0.5
	land_mesh.subdivide_depth = size * 0.5
	
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(land_mesh, 0)
	
	var array_plane = surface_tool.commit()
	
	var data_tool = MeshDataTool.new()
	data_tool.create_from_surface(array_plane, 0)
	
	for i in range(data_tool.get_vertex_count()):
		var vertext = data_tool.get_vertex(i)
		var value = noise.get_noise_3d(
			vertext.x + noise_offset.x, 
			vertext.y + noise_offset.y, 
			vertext.z + noise_offset.z
		)
		vertext.y = value * height
		if vertext.y > highest_point.y:
			highest_point = vertext + noise_offset
			
		if value > 0.2:
			hight_vertex_points.append(vertext)
			
		data_tool.set_vertex(i, vertext)
		
	for i in range(array_plane.get_surface_count()):
		array_plane.surface_remove(i)
		
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
	
	var land_mesh_instance = MeshInstance.new()
	land_mesh_instance.mesh = surface_tool.commit()
	land_mesh_instance.set_surface_material(0, land_shader)
	land_mesh_instance.create_trimesh_collision()
	
	land_mesh_instance.cast_shadow = false
	land_mesh_instance.generate_lightmap = false
	land_mesh_instance.software_skinning_transform_normals = false
	
	return land_mesh_instance
	
func _generate_grass(land_mesh :Mesh) -> Grass:
	var grass :Grass = preload("res://addons/grass/Grass.tscn").instance()
	grass.mesh = land_mesh
	return grass
	
	
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
		var index :int = int(rng.randf_range(0, _resources.size() - 1))
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
	












