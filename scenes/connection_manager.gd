extends Node

@export var camera3D: Camera3D
@export var interaction_plane_height: float = 0.0

@export var preview_connection: MeshInstance3D
@export var connection_material: Material
@export var connection_radius: float = 0.04
@export var connection_anchor_offset: Vector3 = Vector3.ZERO 

@export var connection_scene: PackedScene
@export var connection_container: Node3D

var active_connections: Array[Connection3D] = []

var preview_mesh: CylinderMesh

var is_dragging:bool = false
var initial_node: StaticBody3D = null
var current_drag_position:Vector3

func _ready() -> void:
	preview_mesh = CylinderMesh.new()
	preview_mesh.top_radius = connection_radius
	preview_mesh.bottom_radius = connection_radius
	preview_mesh.height = 0.01
	preview_mesh.radial_segments = 8
	preview_connection.mesh = preview_mesh
	preview_connection.material_overlay = connection_material
	preview_connection.visible = false

func get_node_at_screen_position(screen_pos: Vector2) -> StaticBody3D:
	var ray_origin:Vector3 = camera3D.project_ray_origin(screen_pos)
	var ray_direction:Vector3 = camera3D.project_ray_normal(screen_pos)
	var ray_end:Vector3 = ray_origin + ray_direction * 1000.0
	
	var query = PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_end
	)
	
	query.collision_mask = 1
	var result:Dictionary = camera3D.get_world_3d().direct_space_state.intersect_ray(query)
	
	if result.is_empty():
		return null
	
	var collider = result.collider
	
	if collider is StaticBody3D && collider.is_in_group("connection_nodes"):
		return collider
	
	return null

func get_world_position(screen_pos: Vector2) -> Variant:
	var ray_origin:Vector3 = camera3D.project_ray_origin(screen_pos)
	var ray_direction:Vector3 = camera3D.project_ray_normal(screen_pos)
	
	var interaction_plane:Plane = Plane(
		Vector3.UP,
		interaction_plane_height
	)
	
	var intersection = interaction_plane.intersects_ray(
		ray_origin,
		ray_direction
	)
	
	return intersection


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_drag(event.position)
			else:
				end_drag(event.position)
	elif event is InputEventMouseMotion:
		if is_dragging:
			update_drag(event.position)
		
	elif event is InputEventScreenTouch:
		if event.pressed:
			start_drag(event.position)
		else:
			end_drag(event.position)
	elif event is InputEventScreenDrag:
		if is_dragging:
			update_drag(event.position)
			

func start_drag(screen_position: Vector2) -> void:
	var selected_node = get_node_at_screen_position(screen_position)
	if selected_node == null:
		return
	
	initial_node = selected_node
	is_dragging = true
	
	update_drag(screen_position)
	#print("Drag Started ", initial_node.get_parent().name)

func update_drag(screen_position: Vector2) -> void:
	if !is_dragging:
		return
	var world_position = get_world_position(screen_position)
	if world_position == null:
		return
	current_drag_position = world_position
	var start_position = initial_node.global_position + connection_anchor_offset
	
	update_preview_connection(
		start_position, 
		current_drag_position
	)
	
	#print("Drag Position ", current_drag_position)

func end_drag(screen_position: Vector2) -> void:
	if !is_dragging:
		return
	#print("Drag Ended ", initial_node.get_parent().name)
	var target = get_node_at_screen_position(screen_position)
	if is_valid_connection(initial_node, target):
		create_connection(initial_node, target)
	is_dragging = false
	initial_node = null
	preview_connection.visible = false

func update_preview_connection(start:Vector3, end:Vector3) -> void:
	var direction = end - start
	var distance = direction.length()
	if distance < 0.001:
		preview_connection.visible = false
		return
	preview_mesh.height = distance
	var midpoint = (end+start)/2.0
	var rotation = Quaternion(
		Vector3.UP,
		direction.normalized()
	)
	preview_connection.global_transform = Transform3D(
		Basis(rotation),
		midpoint
	)
	
	preview_connection.visible = true


func is_valid_connection(source:StaticBody3D, target:StaticBody3D) -> bool:
	if source == null || target == null:
		return false
	if source == target:
		return false
	if !source.is_in_group("connection_nodes"):
		return false
	if !target.is_in_group("connection_nodes"):
		return false
	return true

func create_connection(source: StaticBody3D, target: StaticBody3D) -> void:
	var connection:Connection3D = connection_scene.instantiate() as Connection3D
	if connection == null:
		push_error("Error connection to Connection3D scene")
		return
	
	connection_container.add_child(connection)
	connection.setup(
		source,target, connection_radius, connection_material,
		connection_anchor_offset
	)
	
	active_connections.append(connection)

	print("connection created: ",source.get_parent().name,
	" ", target.get_parent().name)
