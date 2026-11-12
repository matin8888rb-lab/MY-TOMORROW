extends Node3D

# Lightweight stylized human model built from Godot primitives.
# It is deliberately mesh-based so it works with Godot 4.3 GL Compatibility on Android.

var _body: CharacterBody3D
var _left_arm: Node3D
var _right_arm: Node3D
var _left_leg: Node3D
var _right_leg: Node3D
var _clock: float = 0.0

func _ready() -> void:
	_body = get_parent() as CharacterBody3D
	_build_character()

func _process(delta: float) -> void:
	if _body == null:
		return
	_clock += delta
	var horizontal_speed := Vector2(_body.velocity.x, _body.velocity.z).length()
	var moving := horizontal_speed > 0.35 and _body.is_on_floor()
	var swing := sin(_clock * (10.5 if horizontal_speed > 3.7 else 7.8)) * (0.52 if moving else 0.035)
	_left_arm.rotation.x = swing
	_right_arm.rotation.x = -swing
	_left_leg.rotation.x = -swing * 0.92
	_right_leg.rotation.x = swing * 0.92
	if not moving:
		rotation.y = lerp_angle(rotation.y, 0.0, delta * 2.0)
	rotation.z = sin(_clock * 1.7) * 0.012 if not moving else 0.0

func _mat(color: Color, roughness: float = 0.78) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = roughness
	return m

func _capsule(name: String, radius: float, height: float, color: Color, pos: Vector3) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	node.mesh = mesh
	node.material_override = _mat(color)
	node.position = pos
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(node)
	return node

func _sphere(name: String, radius: float, color: Color, pos: Vector3) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	node.mesh = mesh
	node.material_override = _mat(color)
	node.position = pos
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(node)
	return node

func _box(name: String, size: Vector3, color: Color, pos: Vector3) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.material_override = _mat(color)
	node.position = pos
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(node)
	return node

func _limb_pivot(name: String, pos: Vector3, radius: float, height: float, color: Color) -> Node3D:
	var pivot := Node3D.new()
	pivot.name = name
	pivot.position = pos
	add_child(pivot)
	var limb := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	limb.mesh = mesh
	limb.material_override = _mat(color)
	limb.position.y = -height * 0.43
	limb.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	pivot.add_child(limb)
	return pivot

func _build_character() -> void:
	var jacket := Color(0.20, 0.36, 0.49)
	var jacket_dark := Color(0.13, 0.25, 0.35)
	var shirt := Color(0.82, 0.79, 0.68)
	var trousers := Color(0.15, 0.19, 0.24)
	var skin := Color(0.78, 0.57, 0.43)
	var hair := Color(0.18, 0.14, 0.12)
	var shoes := Color(0.16, 0.14, 0.13)

	# Torso, shirt insert and jacket details.
	_capsule("Jacket_Torso", 0.29, 1.00, jacket, Vector3(0, 0.12, 0))
	_box("Shirt_Collar", Vector3(0.23, 0.16, 0.12), shirt, Vector3(0, 0.52, -0.02))
	_box("Jacket_Zip", Vector3(0.035, 0.76, 0.025), jacket_dark, Vector3(0, 0.13, -0.285))
	for y in [0.36, 0.15, -0.06]:
		_sphere("Jacket_Button", 0.025, Color(0.78, 0.70, 0.52), Vector3(0.045, y, -0.31))
	_box("Jacket_Pocket_L", Vector3(0.17, 0.16, 0.035), jacket_dark, Vector3(-0.17, -0.12, -0.29))
	_box("Jacket_Pocket_R", Vector3(0.17, 0.16, 0.035), jacket_dark, Vector3(0.17, -0.12, -0.29))

	# Neck, head and simple hair silhouette.
	_cylinder_neck()
	_sphere("Head", 0.225, skin, Vector3(0, 0.88, 0))
	_sphere("Hair", 0.232, hair, Vector3(0, 1.00, 0.035))
	_box("Hair_Front", Vector3(0.34, 0.09, 0.25), hair, Vector3(0, 1.035, -0.12))
	_sphere("Ear_L", 0.055, skin, Vector3(-0.22, 0.87, 0))
	_sphere("Ear_R", 0.055, skin, Vector3(0.22, 0.87, 0))

	# Sleeves and hands.
	_left_arm = _limb_pivot("Left_Arm", Vector3(-0.34, 0.49, 0), 0.115, 0.67, jacket)
	_right_arm = _limb_pivot("Right_Arm", Vector3(0.34, 0.49, 0), 0.115, 0.67, jacket)
	_sphere_child(_left_arm, "Left_Hand", skin, Vector3(0, -0.64, 0))
	_sphere_child(_right_arm, "Right_Hand", skin, Vector3(0, -0.64, 0))

	# Trousers and shoes.
	_left_leg = _limb_pivot("Left_Leg", Vector3(-0.16, -0.31, 0), 0.135, 0.78, trousers)
	_right_leg = _limb_pivot("Right_Leg", Vector3(0.16, -0.31, 0), 0.135, 0.78, trousers)
	_box_child(_left_leg, "Left_Shoe", Vector3(0.22, 0.12, 0.38), shoes, Vector3(0, -0.73, -0.08))
	_box_child(_right_leg, "Right_Shoe", Vector3(0.22, 0.12, 0.38), shoes, Vector3(0, -0.73, -0.08))

func _cylinder_neck() -> void:
	var neck := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.09
	mesh.bottom_radius = 0.11
	mesh.height = 0.16
	neck.mesh = mesh
	neck.material_override = _mat(Color(0.68, 0.48, 0.36))
	neck.position = Vector3(0, 0.66, 0)
	add_child(neck)

func _sphere_child(parent: Node3D, name: String, color: Color, pos: Vector3) -> void:
	var node := MeshInstance3D.new()
	node.name = name
	var mesh := SphereMesh.new()
	mesh.radius = 0.09
	mesh.height = 0.18
	node.mesh = mesh
	node.material_override = _mat(color)
	node.position = pos
	parent.add_child(node)

func _box_child(parent: Node3D, name: String, size: Vector3, color: Color, pos: Vector3) -> void:
	var node := MeshInstance3D.new()
	node.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.material_override = _mat(color)
	node.position = pos
	parent.add_child(node)
