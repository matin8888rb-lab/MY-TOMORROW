extends RefCounted
class_name ValoraVisualUpgrade

# Mobile-friendly decorative pass for the existing Godot 4.3 GL Compatibility scene.
# All additions are ordinary meshes/materials: no runtime downloads or paid dependencies.

static func apply(world: Node3D) -> void:
	_upgrade_atmosphere(world)
	_add_road_details(world)
	_add_building_details(world)
	_add_street_furniture(world)
	_add_greenery(world)

static func _material(color: Color, roughness: float = 0.82, metallic: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	return material

static func _box(parent: Node3D, name: String, pos: Vector3, size: Vector3, color: Color, roughness: float = 0.82) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.material_override = _material(color, roughness)
	node.position = pos
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(node)
	return node

static func _cylinder(parent: Node3D, name: String, pos: Vector3, radius: float, height: float, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius * 0.82
	mesh.bottom_radius = radius
	mesh.height = height
	node.mesh = mesh
	node.material_override = _material(color)
	node.position = pos
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(node)
	return node

static func _sphere(parent: Node3D, name: String, pos: Vector3, radius: float, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	node.mesh = mesh
	node.material_override = _material(color)
	node.position = pos
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(node)
	return node

static func _upgrade_atmosphere(world: Node3D) -> void:
	var world_env := world.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if world_env != null and world_env.environment != null:
		var env := world_env.environment
		var sky := Sky.new()
		var sky_material := ProceduralSkyMaterial.new()
		sky_material.sky_top_color = Color(0.19, 0.34, 0.52)
		sky_material.sky_horizon_color = Color(0.72, 0.79, 0.82)
		sky_material.ground_bottom_color = Color(0.19, 0.22, 0.20)
		sky_material.ground_horizon_color = Color(0.55, 0.60, 0.57)
		sky_material.sun_angle_max = 18.0
		sky.sky_material = sky_material
		env.sky = sky
		env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		env.ambient_light_color = Color(0.70, 0.78, 0.86)
		env.ambient_light_energy = 0.82
		env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
		env.fog_enabled = true
		env.fog_light_color = Color(0.62, 0.70, 0.72)
		env.fog_density = 0.0018
	var sun := world.get_node_or_null("DirectionalLight3D") as DirectionalLight3D
	if sun != null:
		sun.shadow_enabled = true
		sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
		sun.light_angular_distance = 0.45
		sun.light_color = Color(1.0, 0.91, 0.78)

static func _add_road_details(world: Node3D) -> void:
	var curb := Color(0.66, 0.67, 0.62)
	var pavement := Color(0.48, 0.51, 0.49)
	for side in [-1.0, 1.0]:
		_box(world, "MainStreet_Sidewalk", Vector3(side * 5.8, 0.035, 0), Vector3(1.55, 0.20, 100), pavement)
		_box(world, "MainStreet_Curb", Vector3(side * 5.08, 0.12, 0), Vector3(0.18, 0.28, 100), curb)
		_box(world, "CrossStreet_Sidewalk", Vector3(side * 34.0, 0.035, -12.4), Vector3(32, 0.20, 1.25), pavement)
	for z in range(-44, 45, 8):
		_box(world, "Road_Centre_Dash", Vector3(0, 0.095, float(z)), Vector3(0.13, 0.018, 3.2), Color(0.88, 0.82, 0.63))
	for stripe in range(7):
		_box(world, "Crosswalk_Stripe", Vector3(-3.6 + float(stripe) * 1.2, 0.105, -3.35), Vector3(0.68, 0.025, 1.5), Color(0.88, 0.88, 0.82))
		_box(world, "Crosswalk_Stripe", Vector3(-3.6 + float(stripe) * 1.2, 0.105, -12.65), Vector3(0.68, 0.025, 1.5), Color(0.88, 0.88, 0.82))

static func _window(parent: Node3D, x: float, y: float, z: float, width: float = 1.15, height: float = 1.25) -> void:
	_box(parent, "Window_Frame", Vector3(x, y, z), Vector3(width + 0.20, height + 0.20, 0.16), Color(0.22, 0.25, 0.25))
	_box(parent, "Window_Glass", Vector3(x, y, z + 0.095), Vector3(width, height, 0.035), Color(0.30, 0.49, 0.57), 0.22)
	_box(parent, "Window_Mullion_V", Vector3(x, y, z + 0.125), Vector3(0.055, height, 0.035), Color(0.82, 0.79, 0.68))
	_box(parent, "Window_Mullion_H", Vector3(x, y, z + 0.125), Vector3(width, 0.055, 0.035), Color(0.82, 0.79, 0.68))
	_box(parent, "Window_Sill", Vector3(x, y - height / 2.0 - 0.13, z + 0.13), Vector3(width + 0.34, 0.12, 0.28), Color(0.78, 0.76, 0.68))

static func _decorate_building(parent: Node3D, title: String, pos: Vector3, size: Vector3, accent: Color, window_count: int = 2) -> void:
	var front_z := pos.z + size.z / 2.0 + 0.13
	var top_y := size.y
	_box(parent, title + "_Facade_Band", Vector3(pos.x, top_y - 0.42, front_z), Vector3(size.x + 0.16, 0.18, 0.18), accent)
	_box(parent, title + "_Base_Trim", Vector3(pos.x, 0.24, front_z), Vector3(size.x + 0.18, 0.20, 0.18), accent.darkened(0.12))
	_box(parent, title + "_Door_Frame", Vector3(pos.x, 1.12, front_z + 0.035), Vector3(1.35, 2.22, 0.22), Color(0.24, 0.20, 0.16))
	_box(parent, title + "_Door", Vector3(pos.x, 1.12, front_z + 0.17), Vector3(1.12, 1.98, 0.08), Color(0.39, 0.27, 0.19))
	_sphere(parent, title + "_Door_Handle", Vector3(pos.x + 0.36, 1.1, front_z + 0.24), 0.07, Color(0.83, 0.68, 0.37))
	for side in [-1.0, 1.0]:
		_box(parent, title + "_Corner_Pilaster", Vector3(pos.x + side * (size.x / 2.0 - 0.24), size.y / 2.0, front_z), Vector3(0.28, size.y, 0.22), accent.lightened(0.12))
	for i in range(window_count):
		var x := pos.x + (float(i) - float(window_count - 1) / 2.0) * minf(2.65, size.x / float(window_count))
		_window(parent, x, minf(size.y - 1.25, 3.25), front_z + 0.08, 1.12, 1.25)
		if size.y >= 5.5:
			_window(parent, x, 4.95, front_z + 0.08, 0.95, 1.0)
	_box(parent, title + "_Canopy", Vector3(pos.x, 2.55, front_z + 0.48), Vector3(2.2, 0.16, 0.92), accent.darkened(0.12))
	_box(parent, title + "_Canopy_Support_L", Vector3(pos.x - 0.88, 1.85, front_z + 0.72), Vector3(0.10, 1.35, 0.10), Color(0.25, 0.25, 0.23))
	_box(parent, title + "_Canopy_Support_R", Vector3(pos.x + 0.88, 1.85, front_z + 0.72), Vector3(0.10, 1.35, 0.10), Color(0.25, 0.25, 0.23))

static func _add_building_details(world: Node3D) -> void:
	_decorate_building(world, "TownHall", Vector3(0, 0, -18), Vector3(11, 6, 8), Color(0.83, 0.78, 0.65), 3)
	_decorate_building(world, "Library", Vector3(-18, 0, -12), Vector3(9, 4.5, 8), Color(0.73, 0.79, 0.79), 2)
	_decorate_building(world, "Cafe", Vector3(18, 0, -10), Vector3(8, 4, 7), Color(0.77, 0.53, 0.37), 2)
	_decorate_building(world, "Shop", Vector3(-18, 0, 12), Vector3(9, 4, 8), Color(0.67, 0.75, 0.61), 2)
	_decorate_building(world, "Home", Vector3(18, 0, 14), Vector3(9, 5, 9), Color(0.82, 0.66, 0.53), 2)
	_decorate_building(world, "Employment", Vector3(0, 0, 30), Vector3(10, 4.5, 8), Color(0.68, 0.77, 0.83), 2)

static func _street_lamp(parent: Node3D, pos: Vector3) -> void:
	_cylinder(parent, "StreetLamp_Post", pos + Vector3(0, 2.0, 0), 0.075, 4.0, Color(0.16, 0.19, 0.20))
	_box(parent, "StreetLamp_Arm", pos + Vector3(0.34, 3.88, 0), Vector3(0.75, 0.08, 0.08), Color(0.16, 0.19, 0.20))
	_sphere(parent, "StreetLamp_Glow", pos + Vector3(0.68, 3.78, 0), 0.20, Color(1.0, 0.82, 0.52))
	var light := OmniLight3D.new()
	light.position = pos + Vector3(0.68, 3.58, 0)
	light.light_color = Color(1.0, 0.78, 0.49)
	light.light_energy = 0.35
	light.omni_range = 7.0
	light.shadow_enabled = false
	parent.add_child(light)

static func _bench(parent: Node3D, pos: Vector3) -> void:
	var wood := Color(0.40, 0.27, 0.18)
	_box(parent, "Bench_Seat", pos + Vector3(0, 0.55, 0), Vector3(1.8, 0.14, 0.55), wood)
	_box(parent, "Bench_Back", pos + Vector3(0, 0.98, -0.22), Vector3(1.8, 0.72, 0.13), wood)
	for x in [-0.68, 0.68]:
		_box(parent, "Bench_Leg", pos + Vector3(x, 0.27, 0), Vector3(0.12, 0.55, 0.42), Color(0.18, 0.20, 0.20))

static func _add_street_furniture(world: Node3D) -> void:
	for z in [-34.0, -20.0, -4.0, 12.0, 28.0, 42.0]:
		_street_lamp(world, Vector3(-6.9, 0, z))
		_street_lamp(world, Vector3(6.9, 0, z))
	_bench(world, Vector3(-13.0, 0, -4.5))
	_bench(world, Vector3(13.0, 0, -3.5))
	_bench(world, Vector3(-12.0, 0, 20.0))
	_box(world, "Bus_Stop_Sign_Post", Vector3(5.8, 1.55, 37.0), Vector3(0.09, 3.1, 0.09), Color(0.20, 0.24, 0.24))
	_box(world, "Bus_Stop_Sign", Vector3(5.8, 2.9, 37.0), Vector3(0.78, 0.85, 0.12), Color(0.77, 0.83, 0.77))
	_box(world, "Bus_Stop_Symbol", Vector3(5.8, 2.9, 36.92), Vector3(0.42, 0.50, 0.035), Color(0.23, 0.39, 0.43))

static func _add_greenery(world: Node3D) -> void:
	for x in [-12.0, 12.0]:
		for z in [-26.0, -2.0, 22.0, 38.0]:
			_sphere(world, "Garden_Shrub", Vector3(x, 0.48, z), 0.62, Color(0.22, 0.39, 0.25))
			_sphere(world, "Garden_Shrub", Vector3(x + 0.55, 0.40, z + 0.22), 0.48, Color(0.27, 0.44, 0.29))
			_sphere(world, "Garden_Shrub", Vector3(x - 0.52, 0.42, z - 0.18), 0.50, Color(0.19, 0.35, 0.22))
