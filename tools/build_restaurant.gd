extends SceneTree
## 產生 scenes3d/Restaurant.tscn（3D 老蕭餐館）
## 執行：godot --headless --path . --script tools/build_restaurant.gd
## 生成後以編輯器手動編輯為準；重跑會覆蓋編輯器改動

const Lib := preload("res://tools/level_builder_lib.gd")

const BAR_TOP := 0.84  # kitchenBar 檯面高（0.42 × 2 縮放）


func _init() -> void:
	var root := Node3D.new()
	root.name = "Restaurant"

	Lib.make_env(root, Color(0.04, 0.06, 0.05), Color(0.45, 0.50, 0.46),
		Color(0.05, 0.08, 0.06), 0.05)

	Lib.add_omni(root, "CounterLight", Vector3(0, 2.6, -2), Color(1.0, 0.85, 0.6), 1.8, 8.0)
	Lib.add_omni(root, "DoorLight", Vector3(0, 2.4, 3.5), Color(0.6, 0.8, 0.7), 0.9, 6.0)
	Lib.add_model(root, "LampCounter", "lampSquareCeiling", Vector3(0, 2.7, -2), 0.0,
		Lib.MODEL_SCALE, false)

	var floor_mat := Lib.flat_mat(Color(0.55, 0.58, 0.52),
		Lib.checker_tex(Color(0.32, 0.35, 0.30), Color(0.20, 0.22, 0.19)), Vector3(7, 5, 1))
	var wall_mat := Lib.flat_mat(Color(0.38, 0.42, 0.36))
	var ceil_mat := Lib.flat_mat(Color(0.16, 0.18, 0.15))

	# 結構 14 x 10，牆高 3.2
	Lib.add_box(root, "Floor", Vector3(0, -0.1, 0), Vector3(14, 0.2, 10), floor_mat)
	Lib.add_box(root, "Ceiling", Vector3(0, 3.3, 0), Vector3(14, 0.2, 10), ceil_mat)
	Lib.add_box(root, "WallBack", Vector3(0, 1.6, -5.1), Vector3(14, 3.2, 0.2), wall_mat)
	Lib.add_box(root, "WallFront", Vector3(0, 1.6, 5.1), Vector3(14, 3.2, 0.2), wall_mat)
	Lib.add_box(root, "WallLeft", Vector3(-7.1, 1.6, 0), Vector3(0.2, 3.2, 10), wall_mat)
	Lib.add_box(root, "WallRight", Vector3(7.1, 1.6, 0), Vector3(0.2, 3.2, 10), wall_mat)

	# 吧檯（四段 kitchenBar + 兩端蓋板），檯面朝客席（+z）
	for i in 4:
		Lib.add_model(root, "Bar%d" % (i + 1), "kitchenBar",
			Vector3(-1.29 + i * 0.86, 0, -2), 180.0)
	Lib.add_model(root, "BarEndL", "kitchenBarEnd", Vector3(-1.82, 0, -2), 180.0)
	Lib.add_model(root, "BarEndR", "kitchenBarEnd", Vector3(1.82, 0, -2), 180.0)
	Lib.add_model(root, "RadioBar", "radio", Vector3(1.4, BAR_TOP, -2), 160.0,
		Lib.MODEL_SCALE, false)

	# 廚房線（靠後牆）：櫃、爐 + 抽油煙機、水槽、冰箱
	Lib.add_model(root, "KCabinet", "kitchenCabinet", Vector3(-2.6, 0, -4.55), 0.0)
	Lib.add_model(root, "Stove", "kitchenStove", Vector3(-1.7, 0, -4.55), 0.0)
	Lib.add_model(root, "Hood", "hoodLarge", Vector3(-1.7, 1.5, -4.55), 0.0,
		Lib.MODEL_SCALE, false)
	Lib.add_model(root, "Sink", "kitchenSink", Vector3(-0.8, 0, -4.55), 0.0)
	Lib.add_model(root, "Fridge", "kitchenFridge", Vector3(1.6, 0, -4.55), 0.0)

	# 吧檯凳
	for i in 3:
		Lib.add_model(root, "Stool%d" % (i + 1), "stoolBar",
			Vector3(-1.2 + i * 1.2, 0, -0.9), 0.0)

	# 客席：兩張布面桌，各兩把椅
	Lib.add_model(root, "TableLeft", "tableCloth", Vector3(-4.5, 0, 2.0), 90.0)
	Lib.add_model(root, "ChairL1", "chair", Vector3(-5.4, 0, 2.0), 90.0)
	Lib.add_model(root, "ChairL2", "chair", Vector3(-3.6, 0, 2.0), -90.0)
	Lib.add_model(root, "TableRight", "tableCloth", Vector3(4.5, 0, 1.5), 90.0)
	Lib.add_model(root, "ChairR1", "chair", Vector3(3.6, 0, 1.5), -90.0)
	Lib.add_model(root, "ChairR2", "chair", Vector3(5.4, 0, 1.5), 90.0)
	Lib.add_model(root, "Trashcan", "trashcan", Vector3(6.5, 0, -4.4), 0.0)

	# NPC：某甲（ch5），吧檯後
	Lib.add_npc(root, "NPC_Moujia", "moujia", "ch5", 0, Vector3(0, 0, -3.2))

	# 門 → 虎寨城街區（回 hub）+ 出口招牌（DoorLight 已在門口）
	Lib.add_door(root, "DoorStreet", Vector3(0, 0, 5.0), 180.0,
		"res://scenes3d/HuZhaiCheng.tscn", "巷弄")
	Lib.add_sign(root, "ExitSign", "▸ 出口", Vector3(0, 2.7, 4.8), 180.0,
		Color(0.95, 0.78, 0.35), 48)

	Lib.add_spawn(root, Vector3(0, 0.1, 3.5))
	quit(0 if Lib.save(root, "res://scenes3d/Restaurant.tscn") == OK else 1)
