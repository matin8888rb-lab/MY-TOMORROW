extends Node3D

const PlayerController = preload("res://scripts/player.gd")
var player: CharacterBody3D
var status_label: Label
var quest_label: Label
var vc: int = 40
var quest_done: bool = false
var hint_label: Label

func _ready() -> void:
	_build_world()
	_build_player()
	_build_hud()
	_update_hud()

func _process(_delta: float) -> void:
	if player == null:
		return
	if not quest_done and player.global_position.distance_to(Vector3(0, 0, -18)) < 9.0:
		hint_label.text = "نزدیک تالار شهر هستی؛ دکمه تعامل را بزن"
	else:
		hint_label.text = "با دکمه‌های لمسی حرکت کن و شهر را بگرد"

func _build_world() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.72, 0.79, 0.86)
	env.ambient_light_energy = 0.75
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_env.environment = env
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -28, 0)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	add_child(sun)

	var ground := MeshInstance3D.new()
	var ground_mesh := PlaneMesh.new()
	ground_mesh.size = Vector2(120, 120)
	ground.mesh = ground_mesh
	var grass := StandardMaterial3D.new()
	grass.albedo_color = Color(0.34, 0.48, 0.34)
	ground.material_override = grass
	ground.position.y = -0.08
	add_child(ground)
	var ground_body := StaticBody3D.new()
	var ground_collision := CollisionShape3D.new()
	var ground_shape := BoxShape3D.new()
	ground_shape.size = Vector3(120, 0.2, 120)
	ground_collision.shape = ground_shape
	ground_collision.position.y = -0.1
	ground_body.add_child(ground_collision)
	add_child(ground_body)

	_add_box(Vector3(0, 0.01, 0), Vector3(10, 0.12, 100), Color(0.18, 0.19, 0.21), false)
	_add_box(Vector3(0, 0.02, -8), Vector3(100, 0.12, 8), Color(0.22, 0.23, 0.24), false)
	_add_box(Vector3(0, 0.09, 0), Vector3(0.16, 0.02, 100), Color(0.86, 0.78, 0.49), false)

	_add_building("تالار شهر", Vector3(0, 0, -18), Vector3(11, 6, 8), Color(0.72, 0.68, 0.57))
	_add_building("کتابخانه", Vector3(-18, 0, -12), Vector3(9, 4.5, 8), Color(0.63, 0.69, 0.72))
	_add_building("کافه", Vector3(18, 0, -10), Vector3(8, 4, 7), Color(0.62, 0.42, 0.31))
	_add_building("فروشگاه", Vector3(-18, 0, 12), Vector3(9, 4, 8), Color(0.55, 0.61, 0.48))
	_add_building("خانه", Vector3(18, 0, 14), Vector3(9, 5, 9), Color(0.72, 0.53, 0.43))

	for x in [-28.0, -12.0, 13.0, 29.0]:
		for z in [-28.0, 4.0, 29.0]:
			_add_tree(Vector3(x, 0, z))

func _add_box(pos: Vector3, size: Vector3, color: Color, solid: bool = true) -> void:
	var holder: Node3D
	if solid:
		var body := StaticBody3D.new()
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		body.add_child(collision)
		holder = body
	else:
		holder = Node3D.new()
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.86
	mesh_instance.material_override = material
	holder.add_child(mesh_instance)
	holder.position = pos
	add_child(holder)

func _add_building(title: String, pos: Vector3, size: Vector3, color: Color) -> void:
	_add_box(pos + Vector3(0, size.y / 2.0, 0), size, color, true)
	_add_box(pos + Vector3(0, size.y + 0.35, 0), Vector3(size.x + 0.8, 0.7, size.z + 0.8), color.darkened(0.25), true)
	var sign := Label3D.new()
	sign.text = title
	sign.font_size = 48
	sign.pixel_size = 0.012
	sign.position = pos + Vector3(0, size.y + 1.5, size.z / 2.0 + 0.25)
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(sign)

func _add_tree(pos: Vector3) -> void:
	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.22
	trunk_mesh.bottom_radius = 0.32
	trunk_mesh.height = 2.0
	trunk.mesh = trunk_mesh
	var bark := StandardMaterial3D.new()
	bark.albedo_color = Color(0.30, 0.20, 0.13)
	trunk.material_override = bark
	trunk.position = pos + Vector3(0, 1, 0)
	add_child(trunk)

	var crown := MeshInstance3D.new()
	var crown_mesh := SphereMesh.new()
	crown_mesh.radius = 1.25
	crown_mesh.height = 2.5
	crown.mesh = crown_mesh
	var leaves := StandardMaterial3D.new()
	leaves.albedo_color = Color(0.19, 0.38, 0.22)
	crown.material_override = leaves
	crown.position = pos + Vector3(0, 2.8, 0)
	add_child(crown)

func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.set_script(PlayerController)
	player.position = Vector3(0, 1.1, 12)
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.42
	capsule.height = 1.8
	var visual := MeshInstance3D.new()
	visual.mesh = capsule
	var suit := StandardMaterial3D.new()
	suit.albedo_color = Color(0.22, 0.45, 0.72)
	visual.material_override = suit
	visual.position.y = 0.9
	player.add_child(visual)

	var collision := CollisionShape3D.new()
	var capsule_shape := CapsuleShape3D.new()
	capsule_shape.radius = 0.42
	capsule_shape.height = 1.8
	collision.shape = capsule_shape
	collision.position.y = 0.9
	player.add_child(collision)

	var camera := Camera3D.new()
	camera.position = Vector3(0, 4.8, 7.5)
	camera.current = true
	player.add_child(camera)
	camera.look_at(Vector3(0, 1.0, 0), Vector3.UP)
	add_child(player)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(root)

	status_label = Label.new()
	status_label.position = Vector2(24, 18)
	status_label.add_theme_font_size_override("font_size", 25)
	status_label.add_theme_color_override("font_color", Color(0.95, 0.97, 1))
	root.add_child(status_label)

	quest_label = Label.new()
	quest_label.position = Vector2(24, 56)
	quest_label.add_theme_font_size_override("font_size", 18)
	quest_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.58))
	root.add_child(quest_label)

	hint_label = Label.new()
	hint_label.anchor_left = 0.5
	hint_label.anchor_right = 0.5
	hint_label.offset_left = -270
	hint_label.offset_right = 270
	hint_label.offset_top = 18
	hint_label.offset_bottom = 52
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size", 18)
	hint_label.add_theme_color_override("font_color", Color.WHITE)
	root.add_child(hint_label)

	_make_button(root, "▲", Vector2(100, -172), "move_forward")
	_make_button(root, "▼", Vector2(100, -82), "move_back")
	_make_button(root, "◀", Vector2(8, -82), "move_left")
	_make_button(root, "▶", Vector2(192, -82), "move_right")
	_make_button(root, "پرش", Vector2(-190, -94), "jump")
	_make_button(root, "تعامل", Vector2(-190, -174), "interact")

func _make_button(root: Control, caption: String, offset: Vector2, action: String) -> void:
	var button := Button.new()
	button.text = caption
	button.size = Vector2(78, 70)
	button.anchor_left = 1.0
	button.anchor_right = 1.0
	button.anchor_top = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = offset.x
	button.offset_right = offset.x + 78
	button.offset_top = offset.y
	button.offset_bottom = offset.y + 70
	button.add_theme_font_size_override("font_size", 21)
	button.add_theme_color_override("font_color", Color(0.08, 0.13, 0.18))
	button.add_theme_stylebox_override("normal", _button_style(Color(0.78, 0.88, 0.91, 0.92)))
	button.add_theme_stylebox_override("pressed", _button_style(Color(0.48, 0.76, 0.72, 0.98)))
	button.button_down.connect(func(): _press_action(action))
	button.button_up.connect(func(): _release_action(action))
	root.add_child(button)

func _button_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.25, 0.42, 0.50, 0.9)
	return style

func _press_action(action: String) -> void:
	if action == "interact":
		_interact()
	else:
		Input.action_press(action)

func _release_action(action: String) -> void:
	if action != "interact":
		Input.action_release(action)

func _interact() -> void:
	if quest_done:
		hint_label.text = "فعلاً مأموریت دیگری در دسترس نیست."
		return
	if player.global_position.distance_to(Vector3(0, 0, -18)) < 9.0:
		quest_done = true
		vc += 12
		_update_hud()
		hint_label.text = "مأموریت کامل شد! ۱۲ VC دریافت کردی."
	else:
		hint_label.text = "برای انجام مأموریت به تالار شهر برو."

func _update_hud() -> void:
	status_label.text = "VALORA  |  روز ۱  |  %d VC" % vc
	quest_label.text = "مأموریت: به تالار شهر برو و با آن تعامل کن" if not quest_done else "مأموریت روز اول: تکمیل شد  ✓"
