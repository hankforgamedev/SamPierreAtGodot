extends Object
## 3D 關卡建置共用函式庫 — 只給 tools/build_*.gd（SceneTree script）使用
## 慣例：節點直接掛在 root 下、owner = root（pack 時才會存進 .tscn）
##
## 互動 metadata 慣例（Arctic3D 依此路由）：
##   NPC：group "interactable" + meta char_id / chapter_id / start_line
##   門 ：group "interactable" + meta next_level / display_name

const MODEL_DIR := "res://assets/models/kenney_furniture/"
const MODEL_SCALE := 2.0  # Kenney furniture kit 約 1:2 縮尺，×2 貼近真人比例
const TEX_DIR := "res://assets/textures/huzhaicheng/"  # Hank 丟貼圖進這，重跑 build 即自動接上
const GM := preload("res://scripts/GameManager.gd")


static func save(root: Node3D, path: String) -> int:
	var packed := PackedScene.new()
	var err := packed.pack(root)
	if err == OK:
		err = ResourceSaver.save(packed, path)
	print("save %s → %s" % [path, error_string(err)])
	return err


static func make_env(root: Node3D, bg: Color, ambient: Color, fog: Color,
		fog_density: float) -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = bg
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = ambient
	env.ambient_light_energy = 0.55
	env.fog_enabled = true
	env.fog_light_color = fog
	env.fog_density = fog_density
	var we := WorldEnvironment.new()
	we.name = "WorldEnvironment"
	root.add_child(we)
	we.owner = root
	we.environment = env


static func add_omni(root: Node3D, node_name: String, pos: Vector3, color: Color,
		energy: float, rng: float) -> void:
	var light := OmniLight3D.new()
	light.name = node_name
	light.position = pos
	light.light_color = color
	light.light_energy = energy
	light.omni_range = rng
	root.add_child(light)
	light.owner = root


static func flat_mat(color: Color, tex: Texture2D = null,
		uv_scale := Vector3.ONE) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 1.0
	if tex:
		m.albedo_texture = tex
		m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		m.uv1_scale = uv_scale
	return m


## 自動接貼圖：assets/textures/huzhaicheng/<name>.png 存在就貼上、否則退回 fallback 純色。
## 讓 Hank 之後把貼圖丟進資料夾、重跑 build 就換上，門與邏輯完全不動。
static func tex_mat(tex_name: String, fallback: Color, uv_scale := Vector3.ONE,
		transparent := false) -> StandardMaterial3D:
	var path := TEX_DIR + tex_name + ".png"
	var tex: Texture2D = load(path) if ResourceLoader.exists(path) else null
	var m := flat_mat(Color.WHITE if tex else fallback, tex, uv_scale)
	if transparent:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m


## 薄片（晾衣、破布、貼紙、招牌布幔）— 無碰撞，雙面
static func add_quad(root: Node3D, node_name: String, pos: Vector3, size: Vector2,
		rot_deg: Vector3, mat: Material) -> void:
	var mesh := QuadMesh.new()
	mesh.size = size
	var mi := MeshInstance3D.new()
	mi.name = node_name
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.rotation = Vector3(deg_to_rad(rot_deg.x), deg_to_rad(rot_deg.y), deg_to_rad(rot_deg.z))
	root.add_child(mi)
	mi.owner = root


static func checker_tex(c1: Color, c2: Color) -> ImageTexture:
	var img := Image.create(8, 8, false, Image.FORMAT_RGB8)
	for y in 8:
		for x in 8:
			@warning_ignore("integer_division")
			img.set_pixel(x, y, c1 if (x / 4 + y / 4) % 2 == 0 else c2)
	return ImageTexture.create_from_image(img)


## 素色幾何方塊（牆、地板、天花板等建築結構）
static func add_box(root: Node3D, node_name: String, pos: Vector3, size: Vector3,
		mat: Material) -> StaticBody3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var shape := BoxShape3D.new()
	shape.size = size
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = pos
	root.add_child(body)
	body.owner = root

	var mi := MeshInstance3D.new()
	mi.name = "Mesh"
	mi.mesh = mesh
	mi.material_override = mat
	body.add_child(mi)
	mi.owner = root

	var col := CollisionShape3D.new()
	col.name = "Collision"
	col.shape = shape
	body.add_child(col)
	col.owner = root
	return body


## 隱形擋牆（碰撞、無外觀）
static func add_blocker(root: Node3D, node_name: String, pos: Vector3,
		size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = pos
	root.add_child(body)
	body.owner = root
	var col := CollisionShape3D.new()
	col.name = "Collision"
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	col.owner = root


## Kenney GLB 模型。collide=true 時包一層 StaticBody + AABB 碰撞盒
static func add_model(root: Node3D, node_name: String, model: String, pos: Vector3,
		rot_y_deg := 0.0, scale := MODEL_SCALE, collide := true) -> Node3D:
	var inst: Node3D = (load(MODEL_DIR + model + ".glb") as PackedScene).instantiate()
	inst.name = "Model"
	inst.scale = Vector3.ONE * scale

	var wrapper: Node3D = StaticBody3D.new() if collide else Node3D.new()
	wrapper.name = node_name
	wrapper.position = pos
	wrapper.rotation.y = deg_to_rad(rot_y_deg)
	root.add_child(wrapper)
	wrapper.owner = root
	wrapper.add_child(inst)
	inst.owner = root

	if collide:
		var aabbs: Array[AABB] = []
		_collect_aabbs(inst, Transform3D.IDENTITY, aabbs)
		var bb := aabbs[0]
		for a in aabbs.slice(1):
			bb = bb.merge(a)
		var col := CollisionShape3D.new()
		col.name = "Collision"
		var shape := BoxShape3D.new()
		shape.size = bb.size
		col.shape = shape
		col.position = bb.get_center()
		wrapper.add_child(col)
		col.owner = root
	return wrapper


## NPC：以角色色的膠囊表示（正式模型之後再換），掛上章節 metadata
static func add_npc(root: Node3D, node_name: String, char_id: String,
		chapter_id: String, start_line: int, pos: Vector3) -> StaticBody3D:
	var color: Color = GM.CHAR_COLORS.get(char_id, Color.WHITE)
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.32
	mesh.height = 1.8
	var shape := CapsuleShape3D.new()
	shape.radius = 0.32
	shape.height = 1.8

	var body := StaticBody3D.new()
	body.name = node_name
	body.position = pos + Vector3(0, 0.9, 0)
	root.add_child(body)
	body.owner = root
	body.add_to_group("interactable", true)
	body.set_meta("char_id", char_id)
	body.set_meta("chapter_id", chapter_id)
	body.set_meta("start_line", start_line)

	var mi := MeshInstance3D.new()
	mi.name = "Mesh"
	mi.mesh = mesh
	mi.material_override = flat_mat(color.darkened(0.25))
	body.add_child(mi)
	mi.owner = root

	var col := CollisionShape3D.new()
	col.name = "Collision"
	col.shape = shape
	body.add_child(col)
	col.owner = root
	return body


## 門：doorwayOpen 模型 + 換關 metadata
static func add_door(root: Node3D, node_name: String, pos: Vector3, rot_y_deg: float,
		next_level: String, label: String) -> void:
	var door := add_model(root, node_name, "doorwayOpen", pos, rot_y_deg, 2.1, true)
	door.add_to_group("interactable", true)
	door.set_meta("next_level", next_level)
	door.set_meta("display_name", label)


## 牆面文字（站名、警語）
static func add_sign(root: Node3D, node_name: String, text: String, pos: Vector3,
		rot_y_deg: float, color: Color, font_size := 48) -> void:
	var lbl := Label3D.new()
	lbl.name = node_name
	lbl.text = text
	lbl.position = pos
	lbl.rotation.y = deg_to_rad(rot_y_deg)
	lbl.modulate = color
	lbl.font_size = font_size
	lbl.outline_size = 4
	root.add_child(lbl)
	lbl.owner = root


static func add_spawn(root: Node3D, pos: Vector3) -> void:
	var spawn := Node3D.new()
	spawn.name = "PlayerSpawn"
	spawn.position = pos
	root.add_child(spawn)
	spawn.owner = root


static func _collect_aabbs(n: Node, xf: Transform3D, out: Array[AABB]) -> void:
	if n is Node3D:
		xf = xf * (n as Node3D).transform
	if n is MeshInstance3D and (n as MeshInstance3D).mesh:
		out.append(xf * (n as MeshInstance3D).mesh.get_aabb())
	for c in n.get_children():
		_collect_aabbs(c, xf, out)
