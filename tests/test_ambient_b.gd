class_name TestAmbientB
extends GdUnitTestSuite

const _StationLevel    := preload("res://scripts/StationLevel.gd")
const _OfficeLevel     := preload("res://scripts/OfficeLevel.gd")
const _RestaurantLevel := preload("res://scripts/RestaurantLevel.gd")
const _StreetLevel     := preload("res://scripts/StreetLevel.gd")


# _ambient_label is set up in _ready() which requires a scene tree.
# Tests that call _update_ambient() need this helper to provide a bare Label.
func _attach_label(level: AsciiLevelBase) -> Label:
	var lbl := auto_free(Label.new()) as Label
	level._ambient_label = lbl
	return lbl


# ── ambient_b field presence and content ──────────────────────────────────

func test_station_rat_has_ambient_b() -> void:
	var level := auto_free(_StationLevel.new()) as AsciiLevelBase
	level._level_text = StoryLoader.load_level_text("res://story/levels/station.md")
	var npcs := level._get_npcs()
	var rat_pos := Vector2i(44, 9)
	assert_bool(npcs.has(rat_pos)).is_true()
	var rat_npc := npcs[rat_pos] as Dictionary
	assert_bool(rat_npc.has("ambient_b")).is_true()


func test_station_rat_ambient_b_nonempty() -> void:
	var level := auto_free(_StationLevel.new()) as AsciiLevelBase
	level._level_text = StoryLoader.load_level_text("res://story/levels/station.md")
	var npcs := level._get_npcs()
	var rat_npc := npcs[Vector2i(44, 9)] as Dictionary
	assert_str(rat_npc.get("ambient_b", "") as String).is_not_empty()


func test_station_rat_ambient_a_differs_from_ambient_b() -> void:
	var level := auto_free(_StationLevel.new()) as AsciiLevelBase
	level._level_text = StoryLoader.load_level_text("res://story/levels/station.md")
	var npcs := level._get_npcs()
	var rat_npc := npcs[Vector2i(44, 9)] as Dictionary
	assert_str(rat_npc.get("ambient_a", "") as String).is_not_equal(rat_npc.get("ambient_b", "") as String)


# ── ambient_b fallback for NPCs without the field ─────────────────────────

func test_station_narrator_has_no_ambient_b() -> void:
	var level := auto_free(_StationLevel.new()) as AsciiLevelBase
	level._level_text = StoryLoader.load_level_text("res://story/levels/station.md")
	var npcs := level._get_npcs()
	var narrator_npc := npcs[Vector2i(47, 9)] as Dictionary
	assert_bool(narrator_npc.has("ambient_b")).is_false()


func test_station_narrator_shows_ambient_a_when_no_ambient_b() -> void:
	var level := auto_free(_StationLevel.new()) as AsciiLevelBase
	level._level_text = StoryLoader.load_level_text("res://story/levels/station.md")
	level._player_pos = Vector2i(46, 9)
	level._npcs = level._get_npcs()
	var lbl := _attach_label(level)
	level._update_ambient()
	var expected := (level._npcs[Vector2i(47, 9)] as Dictionary).get("ambient_a", "") as String
	assert_str(lbl.text).is_equal(expected)


# ── proximity check: ambient_a before dialogue ────────────────────────────

func test_proximity_shows_ambient_a_initially() -> void:
	var level := auto_free(_StationLevel.new()) as AsciiLevelBase
	level._level_text = StoryLoader.load_level_text("res://story/levels/station.md")
	level._player_pos = Vector2i(43, 9)
	level._npcs = level._get_npcs()
	level._talked_npcs.clear()
	var lbl := _attach_label(level)
	level._update_ambient()
	var expected_a := (level._npcs[Vector2i(44, 9)] as Dictionary).get("ambient_a", "") as String
	assert_str(lbl.text).is_equal(expected_a)


# ── proximity check: ambient_b after dialogue marked ──────────────────────

func test_proximity_shows_ambient_b_after_dialogue_marked() -> void:
	var level := auto_free(_StationLevel.new()) as AsciiLevelBase
	level._level_text = StoryLoader.load_level_text("res://story/levels/station.md")
	level._player_pos = Vector2i(43, 9)
	level._npcs = level._get_npcs()
	level._talked_npcs.clear()
	var lbl := _attach_label(level)
	level._talked_npcs[Vector2i(44, 9)] = true
	level._update_ambient()
	var expected_b := (level._npcs[Vector2i(44, 9)] as Dictionary).get("ambient_b", "") as String
	assert_str(lbl.text).is_equal(expected_b)


func test_proximity_switches_from_ambient_a_to_ambient_b() -> void:
	var level := auto_free(_StationLevel.new()) as AsciiLevelBase
	level._level_text = StoryLoader.load_level_text("res://story/levels/station.md")
	level._player_pos = Vector2i(43, 9)
	level._npcs = level._get_npcs()
	level._talked_npcs.clear()
	var lbl := _attach_label(level)
	var rat_npc := level._npcs[Vector2i(44, 9)] as Dictionary

	level._update_ambient()
	assert_str(lbl.text).is_equal(rat_npc.get("ambient_a", "") as String)

	level._talked_npcs[Vector2i(44, 9)] = true
	level._update_ambient()
	assert_str(lbl.text).is_equal(rat_npc.get("ambient_b", "") as String)
	assert_str(rat_npc.get("ambient_a", "") as String).is_not_equal(rat_npc.get("ambient_b", "") as String)


# ── dialogue completion tracking ──────────────────────────────────────────

func test_dialogue_closed_marks_adjacent_npc_as_talked() -> void:
	var level := auto_free(_StationLevel.new()) as AsciiLevelBase
	level._level_text = StoryLoader.load_level_text("res://story/levels/station.md")
	level._player_pos = Vector2i(43, 9)
	level._npcs = level._get_npcs()
	level._talked_npcs.clear()
	_attach_label(level)
	level._on_dialogue_closed()
	assert_bool(level._talked_npcs.has(Vector2i(44, 9))).is_true()


func test_dialogue_closed_multiple_directions() -> void:
	var level := auto_free(_StationLevel.new()) as AsciiLevelBase
	level._level_text = StoryLoader.load_level_text("res://story/levels/station.md")
	level._npcs = level._get_npcs()
	_attach_label(level)

	level._talked_npcs.clear()
	level._player_pos = Vector2i(43, 9)
	level._on_dialogue_closed()
	assert_bool(level._talked_npcs.has(Vector2i(44, 9))).is_true()

	level._talked_npcs.clear()
	level._player_pos = Vector2i(45, 9)
	level._on_dialogue_closed()
	assert_bool(level._talked_npcs.has(Vector2i(44, 9))).is_true()


# ── ambient clears when far from NPC ─────────────────────────────────────

func test_ambient_clears_when_far_from_npc() -> void:
	var level := auto_free(_StationLevel.new()) as AsciiLevelBase
	level._level_text = StoryLoader.load_level_text("res://story/levels/station.md")
	level._player_pos = Vector2i(20, 10)
	level._npcs = level._get_npcs()
	level._talked_npcs.clear()
	var lbl := _attach_label(level)
	level._update_ambient()
	assert_str(lbl.text).is_empty()


# ── cross-level ambient fields ────────────────────────────────────────────

func test_office_lee_has_ambient_a() -> void:
	var level := auto_free(_OfficeLevel.new()) as AsciiLevelBase
	level._level_text = StoryLoader.load_level_text("res://story/levels/office.md")
	var npcs := level._get_npcs()
	var lee_npc := npcs[Vector2i(41, 10)] as Dictionary
	assert_bool(lee_npc.has("ambient_a")).is_true()
	assert_bool(lee_npc.has("ambient_b")).is_true()


func test_restaurant_moujia_has_ambient_a() -> void:
	var level := auto_free(_RestaurantLevel.new()) as AsciiLevelBase
	level._level_text = StoryLoader.load_level_text("res://story/levels/restaurant.md")
	var npcs := level._get_npcs()
	var moujia_npc := npcs[Vector2i(36, 11)] as Dictionary
	assert_bool(moujia_npc.has("ambient_a")).is_true()
	assert_bool(moujia_npc.has("ambient_b")).is_true()


# ── ambient persistence after moving away and returning ───────────────────

func test_ambient_persists_after_moving_away_and_returning() -> void:
	var level := auto_free(_StationLevel.new()) as AsciiLevelBase
	level._level_text = StoryLoader.load_level_text("res://story/levels/station.md")
	level._npcs = level._get_npcs()
	level._talked_npcs.clear()
	var lbl := _attach_label(level)
	var rat_pos := Vector2i(44, 9)
	var expected_b := (level._npcs[rat_pos] as Dictionary).get("ambient_b", "") as String
	level._talked_npcs[rat_pos] = true

	level._player_pos = Vector2i(43, 9)
	level._update_ambient()
	assert_str(lbl.text).is_equal(expected_b)

	level._player_pos = Vector2i(20, 10)
	level._update_ambient()
	assert_str(lbl.text).is_empty()

	level._player_pos = Vector2i(45, 9)
	level._update_ambient()
	assert_str(lbl.text).is_equal(expected_b)


# ── edge cases ────────────────────────────────────────────────────────────

func test_npc_with_empty_ambient_a_and_no_ambient_b() -> void:
	var level := auto_free(_StationLevel.new()) as AsciiLevelBase
	level._player_pos = Vector2i(4, 4)
	level._npcs = {Vector2i(5, 4): {"chapter_id": "test", "start_line": 0, "char_id": "sam", "display": "@", "ambient_a": ""}}
	level._talked_npcs.clear()
	var lbl := _attach_label(level)
	level._update_ambient()
	assert_str(lbl.text).is_empty()


func test_npc_with_ambient_a_and_empty_ambient_b() -> void:
	var level := auto_free(_StationLevel.new()) as AsciiLevelBase
	level._player_pos = Vector2i(4, 4)
	level._npcs = {Vector2i(5, 4): {"chapter_id": "test", "start_line": 0, "char_id": "sam", "display": "@", "ambient_a": "test text a", "ambient_b": ""}}
	var lbl := _attach_label(level)
	var npc_pos := Vector2i(5, 4)

	level._talked_npcs.clear()
	level._update_ambient()
	assert_str(lbl.text).is_equal("test text a")

	level._talked_npcs[npc_pos] = true
	level._update_ambient()
	assert_str(lbl.text).is_empty()


# ── integration: dialogue closure → ambient_b displays ───────────────────

func test_dialogue_closed_updates_ambient_to_ambient_b() -> void:
	var level := auto_free(_StationLevel.new()) as AsciiLevelBase
	level._level_text = StoryLoader.load_level_text("res://story/levels/station.md")
	level._player_pos = Vector2i(43, 9)
	level._npcs = level._get_npcs()
	level._talked_npcs.clear()
	var lbl := _attach_label(level)
	var rat_npc := level._npcs[Vector2i(44, 9)] as Dictionary

	level._update_ambient()
	assert_str(lbl.text).is_equal(rat_npc.get("ambient_a", "") as String)

	level._on_dialogue_closed()
	assert_str(lbl.text).is_equal(rat_npc.get("ambient_b", "") as String)
	assert_str(rat_npc.get("ambient_a", "") as String).is_not_equal(rat_npc.get("ambient_b", "") as String)


# ── _get_nearby_npc helper ────────────────────────────────────────────────

func test_get_nearby_npc_returns_adjacent_npc() -> void:
	var level := auto_free(_StationLevel.new()) as AsciiLevelBase
	level._level_text = StoryLoader.load_level_text("res://story/levels/station.md")
	level._player_pos = Vector2i(43, 9)
	level._npcs = level._get_npcs()
	assert_that(level._get_nearby_npc()).is_equal(Vector2i(44, 9))


func test_get_nearby_npc_returns_invalid_when_none_adjacent() -> void:
	var level := auto_free(_StationLevel.new()) as AsciiLevelBase
	level._player_pos = Vector2i(20, 10)
	level._npcs = {Vector2i(5, 5): {"display": "?"}}
	assert_that(level._get_nearby_npc()).is_equal(Vector2i(-1, -1))


# ── text content spot-checks ──────────────────────────────────────────────

func test_station_rat_ambient_a_text() -> void:
	var level := auto_free(_StationLevel.new()) as AsciiLevelBase
	level._level_text = StoryLoader.load_level_text("res://story/levels/station.md")
	var rat_npc := level._get_npcs()[Vector2i(44, 9)] as Dictionary
	assert_str(rat_npc.get("ambient_a", "") as String).contains("月台")


func test_station_rat_ambient_b_text() -> void:
	var level := auto_free(_StationLevel.new()) as AsciiLevelBase
	level._level_text = StoryLoader.load_level_text("res://story/levels/station.md")
	var rat_npc := level._get_npcs()[Vector2i(44, 9)] as Dictionary
	assert_str(rat_npc.get("ambient_b", "") as String).contains("末班車")
