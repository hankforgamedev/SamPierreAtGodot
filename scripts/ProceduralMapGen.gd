class_name ProceduralMapGen
# Generates a simple rectangular ASCII level map using full-width characters.
# All map cells are full-width (2 columns wide in monospace) — no mixing with ASCII.

# Full-width glyph constants
const FW_WALL  := "＃"
const FW_FLOOR := "．"
const FW_EXIT  := "＞"
const FW_SPACE := "　"  # full-width ideographic space (floor display variant)

# generate() returns a Dictionary:
#   map   : Array[String]   — rows of full-width characters
#   npcs  : Dictionary      — Vector2i → {display, char_id, chapter_id, start_line}
#   exits : Array[Vector2i] — border positions where exits were placed
#   spawn : Vector2i        — guaranteed-walkable player start
static func generate(width: int, height: int, npc_count: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	# ── Build blank map (walls on border, floor inside) ─────────────────
	var grid: Array = []  # Array of Array[String] — grid[y][x]
	for y in height:
		var row: Array = []
		for x in width:
			if x == 0 or x == width - 1 or y == 0 or y == height - 1:
				row.append(FW_WALL)
			else:
				row.append(FW_FLOOR)
		grid.append(row)

	# ── Place exit on right wall ─────────────────────────────────────────
	var exit_y := height / 2
	grid[exit_y][width - 1] = FW_EXIT
	var exit_pos := Vector2i(width - 1, exit_y)

	# ── Spawn = center ───────────────────────────────────────────────────
	var spawn := Vector2i(width / 2, height / 2)

	# ── Place NPCs at random interior positions ─────────────────────────
	var interior: Array = []
	for y in range(1, height - 1):
		for x in range(1, width - 1):
			var p := Vector2i(x, y)
			if p != spawn and p != exit_pos:
				interior.append(p)

	var placed_npcs: Dictionary = {}
	var attempts := 0
	var placed := 0
	while placed < npc_count and attempts < interior.size() * 3:
		attempts += 1
		var idx: int = rng.randi() % interior.size()
		var pos: Vector2i = interior[idx] as Vector2i
		if pos in placed_npcs:
			continue
		# Flood-fill: NPC reachable from spawn, and exit still reachable after NPC placed
		if not _reachable(grid, spawn, pos, width, height, placed_npcs):
			continue
		var test_npcs := placed_npcs.duplicate()
		test_npcs[pos] = true
		if not _reachable(grid, spawn, exit_pos, width, height, test_npcs):
			continue
		placed_npcs[pos] = {
			"display":    "Ｎ",
			"char_id":    "narrator",
			"chapter_id": "subway_stub",
			"start_line": 0,
		}
		placed += 1

	# ── Build final row strings ──────────────────────────────────────────
	var map: Array = []
	for y in height:
		var s := ""
		for x in width:
			s += (grid[y] as Array)[x] as String
		map.append(s)

	# ── Build exits array (NPC entry added by SubwayCarLevel) ────────────
	var exits: Array = [exit_pos]

	return {
		"map":   map,
		"npcs":  placed_npcs,
		"exits": exits,
		"spawn": spawn,
	}


# Flood-fill: can we reach `target` from `start` avoiding walls and NPC cells?
static func _reachable(
		grid: Array, start: Vector2i, target: Vector2i,
		width: int, height: int, npcs: Dictionary) -> bool:
	if start == target:
		return true
	var visited: Dictionary = {}
	var queue: Array = [start]
	visited[start] = true
	var dirs := [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	while queue.size() > 0:
		var cur: Vector2i = queue.pop_front() as Vector2i
		for d in dirs:
			var nb: Vector2i = cur + d
			if nb.x < 0 or nb.x >= width or nb.y < 0 or nb.y >= height:
				continue
			if nb in visited:
				continue
			var cell: String = ((grid[nb.y] as Array)[nb.x]) as String
			if cell == FW_WALL:
				continue
			if nb in npcs:
				# NPC cells block movement
				continue
			visited[nb] = true
			if nb == target:
				return true
			queue.append(nb)
	return false
