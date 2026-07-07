extends SceneTree
## 煙霧測試：驗證每個 3D 關卡能載入，且有 PlayerSpawn 與合法互動 metadata
## 執行：godot --headless --path . --script tools/smoke_levels.gd

const LEVELS := [
	"res://scenes3d/HuZhaiCheng.tscn",
	"res://scenes3d/Station.tscn",
	"res://scenes3d/Office.tscn",
	"res://scenes3d/Restaurant.tscn",
]


func _init() -> void:
	var failures := 0
	for path in LEVELS:
		var level: Node3D = (load(path) as PackedScene).instantiate()
		var problems: Array[String] = []

		if level.get_node_or_null("PlayerSpawn") == null:
			problems.append("missing PlayerSpawn")

		var npcs := 0
		var doors := 0
		for node in _all_children(level):
			if not node.is_in_group("interactable"):
				continue
			if node.has_meta("chapter_id"):
				npcs += 1
				if String(node.get_meta("chapter_id")).is_empty():
					problems.append("%s: empty chapter_id" % node.name)
			elif node.has_meta("next_level"):
				doors += 1
				if not ResourceLoader.exists(node.get_meta("next_level") as String):
					problems.append("%s: next_level not found" % node.name)
			else:
				problems.append("%s: interactable without chapter_id/next_level" % node.name)

		# hub（街區）合法地沒有章節 NPC，只要求「至少一個可互動物件」
		if npcs + doors == 0:
			problems.append("no interactable (npc/door)")

		if problems.is_empty():
			print("PASS %s (npcs=%d doors=%d)" % [path, npcs, doors])
		else:
			failures += 1
			print("FAIL %s: %s" % [path, ", ".join(problems)])
		level.free()

	quit(failures)


func _all_children(n: Node) -> Array[Node]:
	var out: Array[Node] = [n]
	for c in n.get_children():
		out.append_array(_all_children(c))
	return out
