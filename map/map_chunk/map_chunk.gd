extends StaticBody

const land_shader = preload("res://map/shadermaterial.tres")

var size :int
var height :int
var noise :OpenSimplexNoise
var noise_offset :Vector3

var grass :Grass
var land_mesh :MeshInstance
var collision :CollisionShape
var highest_point :Vector3 = Vector3.ZERO
var hight_vertex_points :Array = []
#var visibility_notifier :VisibilityNotifier

func _ready():
	pass
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
	
func _process(delta):
	var camera :Camera = get_viewport().get_camera()
	if not is_instance_valid(camera) or not grass:
		return
		
	var camera_origin :Vector3 = camera.global_transform.origin
	var distance :float = global_transform.origin.distance_to(camera_origin)
	var is_camera_close = stepify(distance, 1.0) < 20
	grass.visible = is_camera_close
	
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
			hight_vertex_points.append(vertext + noise_offset)
			
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
	













