extends AsciiLevelBase

const MAP_W := 30
const MAP_H := 14
const NPC_COUNT := 3

var _gen: Dictionary = {}

func _ready() -> void:
	# Generate once — all three override methods read from _gen
	_gen = ProceduralMapGen.generate(MAP_W, MAP_H, NPC_COUNT)
	super._ready()

func _get_level_name() -> String:
	return "地鐵廂"

func _get_level_id() -> String:
	return "subway_car"

func _get_scene_intro() -> String:
	return ""

func _get_player_spawn() -> Vector2i:
	return _gen.get("spawn", Vector2i(MAP_W / 2, MAP_H / 2)) as Vector2i

func _get_npcs() -> Dictionary:
	var result: Dictionary = {}
	# NPCs from generator (placeholder chapter)
	for pos: Vector2i in _gen.get("npcs", {}) as Dictionary:
		result[pos] = (_gen["npcs"] as Dictionary)[pos]
	# Wire exits as door NPCs → return to Station
	for exit_pos: Vector2i in _gen.get("exits", []) as Array:
		result[exit_pos] = {
			"next_level": "res://scenes/Station.tscn",
			"char_id":    "narrator",
			"display":    "＞",
		}
	return result

func _get_map_data() -> Array:
	return _gen.get("map", []) as Array
