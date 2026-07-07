extends SceneTree
## 產生 scenes3d/HuZhaiCheng.tscn — 虎寨城街區 hub（3D 小開放世界切片）
## 執行：godot --headless --path . --script tools/build_huzhaicheng.gd
## 生成後以編輯器手動編輯為準；重跑會覆蓋編輯器改動。
## 貼圖：把 PNG 丟進 assets/textures/huzhaicheng/（檔名見 SPEC / 對話），重跑本檔即自動貼上。
##
## 布局：一個被高樓圍死的內院（claustrophobic，抬頭只剩一線天），
## 三面各一扇門通往既有內裝（老蕭餐館 / 警局 / 地鐵站），
## 西側有可攀爬的斜坡 → 天橋走道（垂直感 = KWC 招牌）。玩家自南側巷口進入。

const Lib := preload("res://tools/level_builder_lib.gd")

const CY := 19.0    # 內院邊長
const WH := 9.0     # 圍樓高度（壓迫感）
const H := CY / 2.0 + 0.5


func _init() -> void:
	var root := Node3D.new()
	root.name = "HuZhaiCheng"

	# 夜、濕、病態綠灰、濃霧
	Lib.make_env(root, Color(0.02, 0.025, 0.03), Color(0.30, 0.36, 0.33),
		Color(0.05, 0.07, 0.06), 0.085)

	# ---------- 材質（缺貼圖時退回純色）----------
	var ground_mat := Lib.tex_mat("ground_wet", Color(0.13, 0.14, 0.13), Vector3(6, 6, 1))
	var facade_mat := Lib.tex_mat("wall_concrete", Color(0.22, 0.23, 0.22), Vector3(6, 3, 1))
	var facade2_mat := Lib.tex_mat("wall_brick", Color(0.26, 0.20, 0.18), Vector3(6, 3, 1))
	var metal_mat := Lib.tex_mat("metal_corrugated", Color(0.28, 0.29, 0.31), Vector3(4, 2, 1))
	var pipe_mat := Lib.tex_mat("pipe_rust", Color(0.30, 0.24, 0.18), Vector3(1, 4, 1))
	var ac_mat := Lib.flat_mat(Color(0.35, 0.36, 0.37))
	var puddle_mat := Lib.flat_mat(Color(0.06, 0.07, 0.09))

	# ---------- 結構：地面 + 四面圍樓 ----------
	Lib.add_box(root, "Ground", Vector3(0, -0.1, 0), Vector3(CY + 0.4, 0.2, CY + 0.4), ground_mat)
	Lib.add_box(root, "WallN", Vector3(0, WH / 2, -H), Vector3(CY, WH, 0.3), facade_mat)
	Lib.add_box(root, "WallS", Vector3(0, WH / 2, H), Vector3(CY, WH, 0.3), facade2_mat)
	Lib.add_box(root, "WallE", Vector3(H, WH / 2, 0), Vector3(0.3, WH, CY), facade_mat)
	Lib.add_box(root, "WallW", Vector3(-H, WH / 2, 0), Vector3(0.3, WH, CY), facade2_mat)
	# 頂棚外突（只留一線天）
	Lib.add_box(root, "OverhangN", Vector3(0, WH - 0.4, -H + 2.0), Vector3(CY, 0.3, 4.0), facade_mat)
	Lib.add_box(root, "OverhangS", Vector3(0, WH - 0.4, H - 2.0), Vector3(CY, 0.3, 4.0), facade2_mat)

	# ---------- 垂直感：西側斜坡 → 天橋走道 ----------
	# 斜坡 30°：一端貼地、一端達天橋高度，用 CharacterBody 可直接走上去
	var ramp := Lib.add_box(root, "Ramp", Vector3(-7.6, 1.5, 5.2), Vector3(2.6, 0.3, 6.0), metal_mat)
	ramp.rotation.x = deg_to_rad(30)
	# 天橋走道（沿西牆，供俯瞰內院）
	Lib.add_box(root, "Catwalk", Vector3(-7.6, 2.9, -1.0), Vector3(2.6, 0.2, 14.0), metal_mat)
	Lib.add_box(root, "CatwalkRail", Vector3(-6.3, 3.4, -1.0), Vector3(0.1, 0.9, 14.0),
		Lib.flat_mat(Color(0.20, 0.21, 0.22)))
	# 天橋上一扇封死的門（走得到、進不去，暗示樓上還有無數層）
	Lib.add_box(root, "SealedDoor", Vector3(-8.7, 3.9, -6.0), Vector3(1.4, 2.0, 0.15),
		Lib.flat_mat(Color(0.12, 0.10, 0.09)))

	# ---------- KWC 質感：管線、冷氣、晾衣、垃圾、積水 ----------
	# 垂直管線沿牆
	for spec in [Vector3(6.5, 0, -H + 0.3), Vector3(-3.0, 0, -H + 0.3),
			Vector3(H - 0.3, 0, 4.0), Vector3(H - 0.3, 0, -5.0)]:
		Lib.add_box(root, "Pipe_%d" % randi(), Vector3(spec.x, WH / 2, spec.z),
			Vector3(0.22, WH, 0.22), pipe_mat)
	# 外掛冷氣機（從牆突出）
	for spec in [Vector3(3.0, 3.2, -H + 0.6), Vector3(-5.0, 5.0, -H + 0.6),
			Vector3(H - 0.6, 4.0, 1.0), Vector3(H - 0.6, 2.4, -3.0)]:
		Lib.add_box(root, "AC_%d" % randi(), spec, Vector3(1.1, 0.8, 0.7), ac_mat)
	# 橫越內院的管線 / 電纜（一線天上方）
	for y in [6.4, 7.1]:
		Lib.add_box(root, "Wire_%.0f" % (y * 10), Vector3(0, y, -2.0 + y),
			Vector3(0.12, 0.12, CY), pipe_mat)
	# 晾衣（薄片，病態布色）
	var cloths := [Color(0.45, 0.42, 0.30), Color(0.30, 0.34, 0.40), Color(0.42, 0.28, 0.28)]
	for i in cloths.size():
		Lib.add_quad(root, "Laundry_%d" % i, Vector3(-2.0 + i * 2.2, 5.2, -1.0 + i),
			Vector2(1.2, 1.6), Vector3(0, 0, 6), Lib.flat_mat(cloths[i]))
	# 積水（地面薄片）
	for spec in [Vector3(2.5, 0.02, 3.0), Vector3(-3.5, 0.02, -2.0), Vector3(4.5, 0.02, -5.5)]:
		Lib.add_quad(root, "Puddle_%d" % randi(), spec, Vector2(3.0, 2.0),
			Vector3(-90, 0, 0), puddle_mat)
	# 垃圾桶
	Lib.add_model(root, "Trash1", "trashcan", Vector3(5.5, 0, 6.0), 0.0)
	Lib.add_model(root, "Trash2", "trashcan", Vector3(-4.0, 0, 5.5), 20.0)

	# ---------- 燈光（少、髒、指向招牌）----------
	Lib.add_omni(root, "LampCenter", Vector3(0, 6.2, 0), Color(0.70, 0.85, 0.72), 1.6, 13.0)
	Lib.add_omni(root, "NeonLaoxiao", Vector3(0, 3.2, -8.4), Color(1.0, 0.60, 0.22), 2.2, 6.5)
	Lib.add_omni(root, "NeonMetro", Vector3(8.4, 3.0, -2.0), Color(0.66, 0.88, 1.0), 1.4, 6.0)
	Lib.add_omni(root, "NeonRed", Vector3(-6.0, 3.4, 7.5), Color(0.95, 0.32, 0.26), 1.3, 6.0)

	# ---------- 招牌 / 環境敘事（世界自己開口，P1）----------
	Lib.add_sign(root, "SignLaoxiao", "老蕭餐館", Vector3(0, 3.2, -9.25), 0.0,
		Color(1.0, 0.70, 0.28), 96)
	Lib.add_sign(root, "SignPolice", "虎寨分局", Vector3(-9.25, 3.2, 2.0), 90.0,
		Color(0.70, 0.85, 1.0), 80)
	Lib.add_sign(root, "SignMetro", "地鐵 ⇣ LINE 3", Vector3(9.25, 3.2, -2.0), -90.0,
		Color(0.72, 0.95, 0.85), 72)
	Lib.add_sign(root, "SignPharmacy", "藥", Vector3(6.5, 5.4, -9.25), 0.0,
		Color(0.40, 1.0, 0.55), 120)
	# 拆遷公告（被判死的城 —— 呼應輪迴與異化）
	Lib.add_sign(root, "NoticeDemolish",
		"虎寨城改建計劃\n限期遷出　逾期強制執行",
		Vector3(0, 2.0, 9.15), 180.0, Color(0.82, 0.78, 0.66), 40)
	# 塗鴉（主題回聲）
	Lib.add_sign(root, "Graffiti", "一次就好", Vector3(-9.25, 1.6, 7.5), 90.0,
		Color(0.75, 0.22, 0.20), 64)

	# ---------- 門：三扇通往既有內裝 ----------
	Lib.add_door(root, "DoorRestaurant", Vector3(0, 0, -9.1), 0.0,
		"res://scenes3d/Restaurant.tscn", "老蕭餐館")
	Lib.add_door(root, "DoorOffice", Vector3(-9.1, 0, 2.0), 90.0,
		"res://scenes3d/Office.tscn", "虎寨分局")
	Lib.add_door(root, "DoorStation", Vector3(9.1, 0, -2.0), -90.0,
		"res://scenes3d/Station.tscn", "地鐵站")

	# 玩家自南側巷口進入，面向內院
	Lib.add_spawn(root, Vector3(0, 0.1, 7.5))

	quit(0 if Lib.save(root, "res://scenes3d/HuZhaiCheng.tscn") == OK else 1)
