extends SceneTree
## 一次性建置工具：讓 Godot 自己組出老蕭餐館場景並存成正式 .tscn
## 執行：godot --headless --path . --script tools/build_restaurant.gd
## 產出：res://scenes3d/Restaurant.tscn（可在編輯器裡直接編輯）

const OUT_PATH := "res://scenes3d/Restaurant.tscn"


func _init() -> void:
	var root := Node3D.new()
	root.name = "Restaurant"

	_build_environment(root)
	_build_lights(root)
	_build_room(root)
	_build_furniture(root)
	_build_npc(root)

	# 玩家出生點標記（FPPlayer 由 Arctic3D.gd 在這個位置生成）
	var spawn := Node3D.new()
	spawn.name = "PlayerSpawn"
	spawn.position = Vector3(0, 0.1, 3.5)
	root.add_child(spawn)
	spawn.owner = root

	var packed := PackedScene.new()
	var err := packed.pack(root)
	if err == OK:
		err = ResourceSaver.save(packed, OUT_PATH)
	print("BUILD_RESTAURANT result: ", error_string(err))
	quit(0 if err == OK else 1)


func _build_environment(root: Node3D) -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.04, 0.06, 0.05)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.45, 0.50, 0.46)
	env.ambient_light_energy = 0.55
	env.fog_enabled = true
	env.fog_light_color = Color(0.05, 0.08, 0.06)
	env.fog_density = 0.05

	var we := WorldEnvironment.new()
	we.name = "WorldEnvironment"
	we.environment = env
	root.add_child(we)
	we.owner = root


func _build_lights(root: Node3D) -> void:
	var counter_light := OmniLight3D.new()
	counter_light.name = "CounterLight"
	counter_light.position = Vector3(0, 2.6, -2)
	counter_light.light_color = Color(1.0, 0.85, 0.6)
	counter_light.light_energy = 1.8
	counter_light.omni_range = 8.0
	root.add_child(counter_light)
	counter_light.owner = root

	var door_light := OmniLight3D.new()
	door_light.name = "DoorLight"
	door_light.position = Vector3(0, 2.4, 3.5)
	door_light.light_color = Color(0.6, 0.8, 0.7)
	door_light.light_energy = 0.9
	door_light.omni_range = 6.0
	root.add_child(door_light)
	door_light.owner = root


func _build_room(root: Node3D) -> void:
	var floor_mat := _flat_mat(Color(0.55, 0.58, 0.52),
		_checker_tex(Color(0.32, 0.35, 0.30), Color(0.20, 0.22, 0.19)), Vector3(7, 5, 1))
	var wall_mat := _flat_mat(Color(0.38, 0.42, 0.36))
	var ceil_mat := _flat_mat(Color(0.16, 0.18, 0.15))

	_add_box(root, "Floor", Vector3(0, -0.1, 0), Vector3(14, 0.2, 10), floor_mat)
	_add_box(root, "Ceiling", Vector3(0, 3.3, 0), Vector3(14, 0.2, 10), ceil_mat)
	_add_box(root, "WallBack", Vector3(0, 1.6, -5.1), Vector3(14, 3.2, 0.2), wall_mat)
	_add_box(root, "WallFront", Vector3(0, 1.6, 5.1), Vector3(14, 3.2, 0.2), wall_mat)
	_add_box(root, "WallLeft", Vector3(-7.1, 1.6, 0), Vector3(0.2, 3.2, 10), wall_mat)
	_add_box(root, "WallRight", Vector3(7.1, 1.6, 0), Vector3(0.2, 3.2, 10), wall_mat)


func _build_furniture(root: Node3D) -> void:
	var counter_mat := _flat_mat(Color(0.45, 0.33, 0.20))
	var metal_mat := _flat_mat(Color(0.35, 0.37, 0.38))
	var table_mat := _flat_mat(Color(0.40, 0.30, 0.19))

	_add_box(root, "Counter", Vector3(0, 0.5, -2), Vector3(5.0, 1.0, 0.7), counter_mat)
	_add_box(root, "Stove", Vector3(-1.5, 0.45, -4.4), Vector3(1.2, 0.9, 1.0), metal_mat)
	_add_box(root, "Fridge", Vector3(1.8, 0.7, -4.5), Vector3(1.0, 1.4, 0.8), metal_mat)

	var stool_x := [-1.6, 0.0, 1.6]
	for i in stool_x.size():
		_add_cylinder(root, "Stool%d" % (i + 1),
			Vector3(stool_x[i], 0.28, -0.9), 0.22, 0.56, table_mat)

	_add_box(root, "TableLeft", Vector3(-4.5, 0.4, 2.0), Vector3(1.2, 0.8, 1.2), table_mat)
	_add_box(root, "TableRight", Vector3(4.5, 0.4, 1.5), Vector3(1.2, 0.8, 1.2), table_mat)


func _build_npc(root: Node3D) -> void:
	var npc := _add_capsule(root, "NPC_Laoxiao", Vector3(0, 0.9, -3.2), 0.32, 1.8,
		_flat_mat(Color(0.72, 0.65, 0.50)))
	npc.rotate_y(PI)  # 面向店內
	npc.add_to_group("interactable", true)
	npc.set_meta("display_name", "老蕭")
	npc.set_meta("dialog_lines", [
		{"speaker": "老蕭", "text": "又是你。坐吧，爐子還熱著。"},
		{"speaker": "山姆", "text": "……今天車站的事，你聽說了嗎？"},
		{"speaker": "老蕭", "text": "這條街上的事，沒有我沒聽說的。先吃飯。"},
		{"speaker": "老蕭", "text": "（他把一盤蛋推到你面前。蛋在抖動的燈光下微微發綠。）"},
	])


# ---------- 小工具 ----------

func _flat_mat(color: Color, tex: Texture2D = null, uv_scale := Vector3.ONE) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 1.0
	if tex:
		m.albedo_texture = tex
		m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		m.uv1_scale = uv_scale
	return m


func _checker_tex(c1: Color, c2: Color) -> ImageTexture:
	var img := Image.create(8, 8, false, Image.FORMAT_RGB8)
	for y in 8:
		for x in 8:
			@warning_ignore("integer_division")
			img.set_pixel(x, y, c1 if (x / 4 + y / 4) % 2 == 0 else c2)
	return ImageTexture.create_from_image(img)


func _add_body(parent: Node3D, node_name: String, pos: Vector3,
		mesh: Mesh, shape: Shape3D, mat: Material) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = pos
	parent.add_child(body)
	body.owner = parent

	var mi := MeshInstance3D.new()
	mi.name = "Mesh"
	mi.mesh = mesh
	mi.material_override = mat
	body.add_child(mi)
	mi.owner = parent

	var col := CollisionShape3D.new()
	col.name = "Collision"
	col.shape = shape
	body.add_child(col)
	col.owner = parent
	return body


func _add_box(parent: Node3D, node_name: String, pos: Vector3, size: Vector3,
		mat: Material) -> StaticBody3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var shape := BoxShape3D.new()
	shape.size = size
	return _add_body(parent, node_name, pos, mesh, shape, mat)


func _add_cylinder(parent: Node3D, node_name: String, pos: Vector3, radius: float,
		height: float, mat: Material) -> StaticBody3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = height
	return _add_body(parent, node_name, pos, mesh, shape, mat)


func _add_capsule(parent: Node3D, node_name: String, pos: Vector3, radius: float,
		height: float, mat: Material) -> StaticBody3D:
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	var shape := CapsuleShape3D.new()
	shape.radius = radius
	shape.height = height
	return _add_body(parent, node_name, pos, mesh, shape, mat)
