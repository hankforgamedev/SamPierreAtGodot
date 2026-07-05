extends SceneTree
## 開發輔助：印出 assets/models 下每個 GLB 的包圍盒，供關卡佈局參考
## 執行：godot --headless --path . --script tools/measure_models.gd

const DIR := "res://assets/models/kenney_furniture/"


func _init() -> void:
	for f in DirAccess.get_files_at(DIR):
		if not f.ends_with(".glb"):
			continue
		var inst: Node3D = (load(DIR + f) as PackedScene).instantiate()
		var aabbs: Array[AABB] = []
		_collect(inst, Transform3D.IDENTITY, aabbs)
		var bb := aabbs[0]
		for a in aabbs.slice(1):
			bb = bb.merge(a)
		print("%-28s size=%.2f x %.2f x %.2f  origin_y=%.2f" %
			[f, bb.size.x, bb.size.y, bb.size.z, bb.position.y])
		inst.free()
	quit()


func _collect(n: Node, xf: Transform3D, out: Array[AABB]) -> void:
	if n is Node3D:
		xf = xf * (n as Node3D).transform
	if n is MeshInstance3D and (n as MeshInstance3D).mesh:
		out.append(xf * (n as MeshInstance3D).mesh.get_aabb())
	for c in n.get_children():
		_collect(c, xf, out)
