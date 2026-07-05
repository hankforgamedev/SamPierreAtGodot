extends SceneTree
## 產生 scenes3d/Office.tscn（3D 辦公室）
## 執行：godot --headless --path . --script tools/build_office.gd
## 生成後以編輯器手動編輯為準；重跑會覆蓋編輯器改動

const Lib := preload("res://tools/level_builder_lib.gd")

const DESK_TOP := 0.77  # desk 模型桌面高（0.38 × 2 縮放）


func _init() -> void:
	var root := Node3D.new()
	root.name = "Office"

	Lib.make_env(root, Color(0.04, 0.035, 0.03), Color(0.50, 0.46, 0.40),
		Color(0.06, 0.05, 0.04), 0.045)

	for x in [-5.0, 0.0, 5.0]:
		Lib.add_omni(root, "Light%+03d" % int(x), Vector3(x, 2.8, 0),
			Color(1.0, 0.92, 0.75), 1.3, 7.0)
		Lib.add_model(root, "Lamp%+03d" % int(x), "lampSquareCeiling",
			Vector3(x, 2.7, 0), 0.0, Lib.MODEL_SCALE, false)

	var floor_mat := Lib.flat_mat(Color(0.42, 0.38, 0.32),
		Lib.checker_tex(Color(0.30, 0.27, 0.22), Color(0.26, 0.23, 0.19)), Vector3(9, 6, 1))
	var wall_mat := Lib.flat_mat(Color(0.45, 0.42, 0.36))
	var ceil_mat := Lib.flat_mat(Color(0.18, 0.16, 0.14))

	# 結構 18 x 11，牆高 3.2
	Lib.add_box(root, "Floor", Vector3(0, -0.1, 0), Vector3(18, 0.2, 11), floor_mat)
	Lib.add_box(root, "Ceiling", Vector3(0, 3.3, 0), Vector3(18, 0.2, 11), ceil_mat)
	Lib.add_box(root, "WallBack", Vector3(0, 1.6, -5.6), Vector3(18, 3.2, 0.2), wall_mat)
	Lib.add_box(root, "WallFront", Vector3(0, 1.6, 5.6), Vector3(18, 3.2, 0.2), wall_mat)
	Lib.add_box(root, "WallLeft", Vector3(-9.1, 1.6, 0), Vector3(0.2, 3.2, 11), wall_mat)
	Lib.add_box(root, "WallRight", Vector3(9.1, 1.6, 0), Vector3(0.2, 3.2, 11), wall_mat)

	# 兩排辦公桌（桌 + 螢幕 + 鍵盤 + 椅）
	var desk_slots: Array = [
		[-2.5, -1.5, 0.0], [-2.5, 1.5, 180.0],
		[2.5, -1.5, 0.0], [2.5, 1.5, 180.0],
	]
	for i in desk_slots.size():
		var s: Array = desk_slots[i]
		var x: float = s[0]
		var z: float = s[1]
		var rot: float = s[2]
		var back := 1.0 if rot == 0.0 else -1.0  # 椅子在桌後
		Lib.add_model(root, "Desk%d" % (i + 1), "desk", Vector3(x, 0, z), rot)
		Lib.add_model(root, "Screen%d" % (i + 1), "computerScreen",
			Vector3(x, DESK_TOP, z), rot, Lib.MODEL_SCALE, false)
		Lib.add_model(root, "Keyboard%d" % (i + 1), "computerKeyboard",
			Vector3(x, DESK_TOP, z + 0.25 * back), rot, Lib.MODEL_SCALE, false)
		Lib.add_model(root, "ChairDesk%d" % (i + 1), "chairDesk",
			Vector3(x, 0, z + 0.9 * back), rot + 180.0)

	# 背牆書櫃列 + 雜物
	for i in 3:
		Lib.add_model(root, "Bookcase%d" % (i + 1), "bookcaseClosed",
			Vector3(-1.5 + i * 1.5, 0, -5.2), 0.0)
	Lib.add_model(root, "Books", "books", Vector3(-1.4, 1.72, -5.2), 20.0,
		Lib.MODEL_SCALE, false)
	Lib.add_model(root, "BoxA", "cardboardBoxClosed", Vector3(8.0, 0, -4.6), 15.0)
	Lib.add_model(root, "BoxB", "cardboardBoxOpen", Vector3(7.4, 0, -4.0), -30.0)
	Lib.add_model(root, "SideTable", "sideTableDrawers", Vector3(-8.2, 0, -4.6), 90.0)
	Lib.add_model(root, "Radio", "radio", Vector3(-8.2, 0.78, -4.6), 90.0,
		Lib.MODEL_SCALE, false)
	Lib.add_model(root, "PlantA", "pottedPlant", Vector3(8.4, 0, 4.8), 0.0)
	Lib.add_model(root, "PlantB", "pottedPlant", Vector3(-8.4, 0, 4.8), 0.0)
	Lib.add_model(root, "CoatRack", "coatRackStanding", Vector3(-8.4, 0, 3.4), 0.0)
	Lib.add_model(root, "Trashcan", "trashcan", Vector3(3.4, 0, -1.5), 0.0)

	# NPC：李先生（ch3），最深處的桌邊
	Lib.add_npc(root, "NPC_Lee", "lee", "ch3", 0, Vector3(0, 0, -4.0))

	# 門：← 地鐵站、→ 老蕭餐館
	Lib.add_door(root, "DoorStation", Vector3(-8.9, 0, 2), 90.0,
		"res://scenes3d/Station.tscn", "地鐵站")
	Lib.add_door(root, "DoorRestaurant", Vector3(8.9, 0, 2), -90.0,
		"res://scenes3d/Restaurant.tscn", "老蕭餐館")

	Lib.add_spawn(root, Vector3(-7, 0.1, 2))
	quit(0 if Lib.save(root, "res://scenes3d/Office.tscn") == OK else 1)
