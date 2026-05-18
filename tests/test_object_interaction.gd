class_name TestObjectInteraction
extends GdUnitTestSuite

const _StationLevel    := preload("res://scripts/StationLevel.gd")
const _OfficeLevel     := preload("res://scripts/OfficeLevel.gd")
const _RestaurantLevel := preload("res://scripts/RestaurantLevel.gd")
const _StreetLevel     := preload("res://scripts/StreetLevel.gd")


# ── StoryLoader.load_objects() ────────────────────────────────────────────────

func test_all_level_keys_present() -> void:
	var result := StoryLoader.load_objects("res://story/objects.md")
	assert_dict(result).contains_keys(["station", "office", "restaurant", "street"])


func test_station_has_four_objects() -> void:
	var result := StoryLoader.load_objects("res://story/objects.md")
	assert_dict(result["station"]).has_size(4)


func test_office_has_four_objects() -> void:
	var result := StoryLoader.load_objects("res://story/objects.md")
	assert_dict(result["office"]).has_size(4)


func test_restaurant_has_four_objects() -> void:
	var result := StoryLoader.load_objects("res://story/objects.md")
	assert_dict(result["restaurant"]).has_size(4)


func test_street_has_four_objects() -> void:
	var result := StoryLoader.load_objects("res://story/objects.md")
	assert_dict(result["street"]).has_size(4)


func test_station_trash_key_14_11_exists() -> void:
	var result := StoryLoader.load_objects("res://story/objects.md")
	assert_bool((result["station"] as Dictionary).has(Vector2i(14, 11))).is_true()


func test_all_objects_have_nonempty_text() -> void:
	var result := StoryLoader.load_objects("res://story/objects.md")
	for level_id: String in result:
		for key: Vector2i in (result[level_id] as Dictionary):
			var text: String = ((result[level_id] as Dictionary)[key] as Dictionary).get("text", "")
			assert_str(text).is_not_empty()


# ── _get_level_id() ───────────────────────────────────────────────────────────

func test_station_level_id() -> void:
	var level := auto_free(_StationLevel.new()) as AsciiLevelBase
	assert_str(level._get_level_id()).is_equal("station")


func test_office_level_id() -> void:
	var level := auto_free(_OfficeLevel.new()) as AsciiLevelBase
	assert_str(level._get_level_id()).is_equal("office")


func test_restaurant_level_id() -> void:
	var level := auto_free(_RestaurantLevel.new()) as AsciiLevelBase
	assert_str(level._get_level_id()).is_equal("restaurant")


func test_street_level_id() -> void:
	var level := auto_free(_StreetLevel.new()) as AsciiLevelBase
	assert_str(level._get_level_id()).is_equal("street")


# ── _try_interact_object() ────────────────────────────────────────────────────

func test_interact_returns_true_adjacent_right() -> void:
	var level: AsciiLevelBase = auto_free(AsciiLevelBase.new())
	level._player_pos = Vector2i(4, 4)
	level._objects = {Vector2i(5, 4): {"text": "test"}}
	assert_bool(level._try_interact_object()).is_true()


func test_interact_returns_true_adjacent_left() -> void:
	var level: AsciiLevelBase = auto_free(AsciiLevelBase.new())
	level._player_pos = Vector2i(4, 4)
	level._objects = {Vector2i(3, 4): {"text": "test"}}
	assert_bool(level._try_interact_object()).is_true()


func test_interact_returns_true_adjacent_above() -> void:
	var level: AsciiLevelBase = auto_free(AsciiLevelBase.new())
	level._player_pos = Vector2i(4, 4)
	level._objects = {Vector2i(4, 3): {"text": "test"}}
	assert_bool(level._try_interact_object()).is_true()


func test_interact_returns_true_adjacent_below() -> void:
	var level: AsciiLevelBase = auto_free(AsciiLevelBase.new())
	level._player_pos = Vector2i(4, 4)
	level._objects = {Vector2i(4, 5): {"text": "test"}}
	assert_bool(level._try_interact_object()).is_true()


func test_interact_returns_false_not_adjacent() -> void:
	var level: AsciiLevelBase = auto_free(AsciiLevelBase.new())
	level._player_pos = Vector2i(4, 4)
	level._objects = {Vector2i(10, 10): {"text": "far"}}
	assert_bool(level._try_interact_object()).is_false()


func test_interact_returns_false_no_objects() -> void:
	var level: AsciiLevelBase = auto_free(AsciiLevelBase.new())
	level._player_pos = Vector2i(4, 4)
	level._objects = {}
	assert_bool(level._try_interact_object()).is_false()


# ── Object coordinates within map bounds ──────────────────────────────────────

func _assert_coords_in_map(level_script: GDScript, level_id: String) -> void:
	var level := auto_free(level_script.new()) as AsciiLevelBase
	var map_data := level._get_map_data()
	var rows := map_data.size()
	var objects := StoryLoader.load_objects("res://story/objects.md")
	var objs: Dictionary = objects.get(level_id, {})
	for key: Vector2i in objs:
		assert_bool(key.y >= 0 and key.y < rows) \
			.override_failure_message("%s coord %s row %d out of map (%d rows)" % [level_id, key, key.y, rows]) \
			.is_true()
		var row := map_data[key.y] as String
		assert_bool(key.x >= 0 and key.x < row.length()) \
			.override_failure_message("%s coord %s col %d out of row length %d" % [level_id, key, key.x, row.length()]) \
			.is_true()


func test_station_coords_in_map() -> void:
	_assert_coords_in_map(_StationLevel, "station")


func test_office_coords_in_map() -> void:
	_assert_coords_in_map(_OfficeLevel, "office")


func test_restaurant_coords_in_map() -> void:
	_assert_coords_in_map(_RestaurantLevel, "restaurant")


func test_street_coords_in_map() -> void:
	_assert_coords_in_map(_StreetLevel, "street")
