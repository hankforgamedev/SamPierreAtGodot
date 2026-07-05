extends SceneTree
## 產生 scenes3d/Station.tscn（3D 地鐵站）
## 執行：godot --headless --path . --script tools/build_station.gd
## 生成後以編輯器手動編輯為準；重跑會覆蓋編輯器改動

const Lib := preload("res://tools/level_builder_lib.gd")

# 大廳 30 x 14，月台 z -7..3，軌道坑 z 3..7（低 1.2m）
const HALL_W := 30.0
const WALL_H := 4.0


func _init() -> void:
	var root := Node3D.new()
	root.name = "Station"

	Lib.make_env(root, Color(0.02, 0.03, 0.03), Color(0.38, 0.46, 0.44),
		Color(0.04, 0.07, 0.06), 0.06)

	# 冷白綠日光燈排
	for x in [-12.0, -6.0, 0.0, 6.0, 12.0]:
		Lib.add_omni(root, "Light%+03d" % int(x), Vector3(x, 3.4, -2),
			Color(0.85, 1.0, 0.92), 1.2, 7.0)

	var floor_mat := Lib.flat_mat(Color(0.50, 0.54, 0.50),
		Lib.checker_tex(Color(0.30, 0.33, 0.31), Color(0.22, 0.24, 0.22)), Vector3(15, 5, 1))
	var wall_mat := Lib.flat_mat(Color(0.34, 0.40, 0.37))
	var ceil_mat := Lib.flat_mat(Color(0.14, 0.16, 0.15))
	var pit_mat := Lib.flat_mat(Color(0.10, 0.11, 0.10))
	var metal_mat := Lib.flat_mat(Color(0.42, 0.44, 0.46))

	# 結構：月台地板、軌道坑、牆、天花板
	Lib.add_box(root, "Floor", Vector3(0, -0.1, -2), Vector3(HALL_W, 0.2, 10), floor_mat)
	Lib.add_box(root, "PitFloor", Vector3(0, -1.3, 5), Vector3(HALL_W, 0.2, 4), pit_mat)
	Lib.add_box(root, "PitWall", Vector3(0, -0.6, 3), Vector3(HALL_W, 1.2, 0.2), pit_mat)
	Lib.add_box(root, "Ceiling", Vector3(0, 4.1, 0), Vector3(HALL_W, 0.2, 14), ceil_mat)
	Lib.add_box(root, "WallBack", Vector3(0, 2.0, -7.1), Vector3(HALL_W, WALL_H, 0.2), wall_mat)
	Lib.add_box(root, "WallTrack", Vector3(0, 2.0, 7.1), Vector3(HALL_W, WALL_H, 0.2), wall_mat)
	Lib.add_box(root, "WallLeft", Vector3(-15.1, 2.0, 0), Vector3(0.2, WALL_H, 14), wall_mat)
	Lib.add_box(root, "WallRight", Vector3(15.1, 2.0, 0), Vector3(0.2, WALL_H, 14), wall_mat)

	# 鐵軌
	Lib.add_box(root, "RailA", Vector3(0, -1.15, 4.3), Vector3(HALL_W, 0.06, 0.08), metal_mat)
	Lib.add_box(root, "RailB", Vector3(0, -1.15, 5.7), Vector3(HALL_W, 0.06, 0.08), metal_mat)

	# 黃色警戒線 + 隱形擋牆（3D 版先不做火車事件）
	Lib.add_box(root, "YellowLine", Vector3(0, 0.01, 2.5),
		Vector3(HALL_W, 0.02, 0.3), Lib.flat_mat(Color(0.85, 0.75, 0.15)))
	Lib.add_blocker(root, "TrackBlocker", Vector3(0, 1.0, 2.9), Vector3(HALL_W, 2.0, 0.1))

	# 柱列
	var pillar_mat := Lib.flat_mat(Color(0.44, 0.47, 0.45))
	for x in [-12.0, -6.0, 0.0, 6.0, 12.0]:
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.35
		mesh.bottom_radius = 0.35
		mesh.height = WALL_H
		var body := Lib.add_box(root, "Pillar%+03d" % int(x),
			Vector3(x, 2.0, -2), Vector3(0.7, WALL_H, 0.7), pillar_mat)
		(body.get_node("Mesh") as MeshInstance3D).mesh = mesh

	# 家具：長椅、垃圾桶
	for i in 3:
		Lib.add_model(root, "Bench%d" % (i + 1),
			"bench", Vector3(-6.0 + i * 6.0, 0, -4.5), 0.0)
	Lib.add_model(root, "Trashcan", "trashcan", Vector3(-3.5, 0, -4.5), 0.0)

	# 告示
	Lib.add_sign(root, "SignLine", "METRO LINE 3  //  NO SERVICE  //  02:47",
		Vector3(0, 2.6, -6.95), 0.0, Color(0.75, 0.95, 0.85), 64)
	Lib.add_sign(root, "SignWarn", "!! STAY BEHIND THE YELLOW LINE !!",
		Vector3(0, 1.6, 6.95), 180.0, Color(0.9, 0.8, 0.2), 56)

	# NPC：老鼠（ch1）
	Lib.add_npc(root, "NPC_Rat", "rat", "ch1", 0, Vector3(10, 0, -1))

	# 門 → 辦公室
	Lib.add_door(root, "DoorOffice", Vector3(-14.9, 0, -2), 90.0,
		"res://scenes3d/Office.tscn", "辦公室")

	Lib.add_spawn(root, Vector3(-10, 0.1, -2))
	quit(0 if Lib.save(root, "res://scenes3d/Station.tscn") == OK else 1)
