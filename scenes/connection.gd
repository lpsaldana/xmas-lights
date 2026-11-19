extends Node3D

class_name Connection3D

@onready var cable_mesh: MeshInstance3D = $MeshInstance3D

var source_node: StaticBody3D
var target_node: StaticBody3D

var anchor_offset: Vector3 = Vector3.ZERO

func setup(source:StaticBody3D, target:StaticBody3D,
	radius:float, material:Material, 
	offset: Vector3 = Vector3.ZERO) -> void:
	source_node = source
	target_node = target
	anchor_offset = offset
	
	var cylinder:CylinderMesh = CylinderMesh.new()
	
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius
	cylinder.height = 0.01
	cylinder.radial_segments = 8
	
	cable_mesh.mesh = cylinder
	cable_mesh.material_override = material
	cable_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	update_connection()
	
func update_connection() -> void:
	if !is_instance_valid(source_node):
		return
	if !is_instance_valid(target_node):
		return
	var start = source_node.global_position + anchor_offset
	var end = target_node.global_position + anchor_offset
	
	var direction = end - start
	var distance = direction.length()
	
	if distance < 0.001:
		return
		
	var midpoint = (start+end)/2
	var rotationx = Quaternion(
		Vector3.UP,
		direction.normalized()
	)
	
	var cylinder = cable_mesh.mesh as CylinderMesh
	cylinder.height = distance
	
	global_transform = Transform3D(
		Basis(rotationx),
		midpoint
	)
