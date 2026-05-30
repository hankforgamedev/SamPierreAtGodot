extends AsciiLevelBase

func _ready() -> void:
	_level_text = StoryLoader.load_level_text("res://story/levels/restaurant.md")
	super._ready()

func _get_level_name() -> String:
	return _level_text.get("level_name", "")

func _get_level_id() -> String:
	return "restaurant"

func _get_scene_intro() -> String:
	return _level_text.get("intro", "")

func _get_ambient_track() -> String:
	return "tavern_bar"

func _get_player_spawn() -> Vector2i:
	return Vector2i(4, 11)

func _get_npcs() -> Dictionary:
	var amb: Dictionary = _level_text.get("ambient", {})
	return {
		Vector2i(36, 11): {
			"chapter_id": "ch5",
			"start_line": 0,
			"char_id":    "moujia",
			"display":    "甲",
			"ambient_a":  (amb.get("36,11", {}) as Dictionary).get("before", ""),
			"ambient_b":  (amb.get("36,11", {}) as Dictionary).get("after", ""),
		},
		Vector2i(2, 11): {
			"start_chapter": "ch6",
			"char_id":       "narrator",
			"display":       "＜",
			"ambient_a":     (amb.get("2,11", {}) as Dictionary).get("before", ""),
		},
	}

func _on_dialogue_closed() -> void:
	super._on_dialogue_closed()
	stress_level = 0.3

func _get_map_data() -> Array:  # 19 rows × 52 cols, all full-width
	return [
		"＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃",
		"＃　　老　蕭　餐　館　　（　２４ｈｒ　）　　　　　　　　　　　　許久之前　　　　　　　　　　　　　　　＃",
		"＃　　－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－　＃",
		"＃　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　＃",
		"＃　　　（Ｏ）　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　（Ｏ）　　　　　　　　　＃",
		"＃　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　＃",
		"＃　　［ＴＡＢＬＥ］　　　　　　　　　　　　［ＴＡＢＬＥ］　　　　　　　　　［ＴＡＢＬＥ］　　　　　　＃",
		"＃　　　－－－－　　　　　　　　　　　　　　　－－－－　　　　　　　　　　　　－－－－　　　　　　　　＃",
		"＃　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　＃",
		"＃　　　　　　　　　　　　　　　　　　　［ＣＯＵＮＴＥＲ］－－－－－－－－－［ＣＯＵＮＴＥＲ］　　　　＃",
		"＃　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　＃",
		"＃　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　＃",
		"＃　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　＃",
		"＃　　．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．　　＃",
		"＃＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＃",
		"＃　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　＃",
		"＃　　％　％％　　％　％　　％％　％％　　％　％％　　％　　％　％％　　％％　％％　　％　　％　　　　＃",
		"＃　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　＃",
		"＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃",
	]
