extends MultiMeshInstance
class_name Grass

const MeshFactory = preload("res://addons/grass/mesh_factory.gd")
const GrassFactory = preload("res://addons/grass/grass_factory.gd")

export(Vector2) var blade_width:Vector2 = Vector2(0.2, 0.4) setget set_blade_width
export(Vector2) var blade_height:Vector2 = Vector2(0.4, 0.8) setget set_blade_height
export(Vector2) var sway_yaw:Vector2 = Vector2(0.0, 10.0) setget set_sway_yaw
export(Vector2) var sway_pitch:Vector2 = Vector2(0.04, 0.08) setget set_sway_pitch
export(Mesh) var mesh:Mesh = null setget set_mesh
export(float) var density:float = 1.0 setget set_density

export(Color) var grass_color :Color = Color(0, 0.313726, 0.070588)

onready var _shader :ShaderMaterial = material_override as ShaderMaterial

func _ready():
	_shader.set_shader_param("color_top", grass_color)
	_shader.set_shader_param("color_bottom", grass_color)
	
func rebuild():
	if !multimesh:
		multimesh = MultiMesh.new()
	multimesh.instance_count = 0
	var spawns:Array = GrassFactory.generate(
		mesh,
		density,
		blade_width,
		blade_height,
		sway_pitch,
		sway_yaw
	)
	if spawns.empty():
		return
	multimesh.mesh = MeshFactory.simple_grass()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.set_custom_data_format(MultiMesh.CUSTOM_DATA_FLOAT)
	multimesh.set_color_format(MultiMesh.COLOR_NONE)
	multimesh.instance_count = spawns.size()
	
	for index in multimesh.instance_count:
		var spawn:Array = spawns[index]
		multimesh.set_instance_transform(index, spawn[0])
		multimesh.set_instance_custom_data(index, spawn[1])

func set_blade_width(p_blade_width:Vector2):
	blade_width = p_blade_width
	rebuild()
	
func set_blade_height(p_blade_height:Vector2):
	blade_height = p_blade_height
	rebuild()
	
func set_sway_yaw(p_sway_yaw:Vector2):
	sway_yaw = p_sway_yaw
	rebuild()

func set_sway_pitch(p_sway_pitch:Vector2):
	sway_pitch = p_sway_pitch
	rebuild()
	
func set_mesh(p_mesh:Mesh):
	mesh = p_mesh
	rebuild()

func set_density(p_density:float):
	density = p_density
	if density < 1.0:
		density = 1.0
	rebuild()
