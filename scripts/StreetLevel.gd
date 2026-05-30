extends AsciiLevelBase

func _ready() -> void:
	_level_text = StoryLoader.load_level_text("res://story/levels/street.md")
	super._ready()

func _get_level_name() -> String:
	return _level_text.get("level_name", "")

func _get_level_id() -> String:
	return "street"

func _get_scene_intro() -> String:
	return _level_text.get("intro", "")

func _get_ambient_track() -> String:
	return "peacefuly_night" # change to creepy/eerie the 2nd time the player visits the street level

func _get_player_spawn() -> Vector2i:
	return Vector2i(5, 13)

func _get_npcs() -> Dictionary:
	var amb: Dictionary = _level_text.get("ambient", {})
	return {
		Vector2i(47, 13): {
			"next_level": "res://scenes/LaoxiaoRestaurant.tscn",
			"char_id":    "narrator",
			"display":    "＞",
			"ambient_a":  (amb.get("47,13", {}) as Dictionary).get("before", ""),
		},
	}

func _get_map_data() -> Array:
	return [
		"＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃",
		"＃　　｜　　　　　　　　｜　　　　　　　　｜　　　　　　　　｜　　　　　　　　｜　　　　　　　　｜　　　　＃",
		"＃　　｜　　ＢＬＤＧ　　｜　　ＢＬＤＧ　　｜　　ＢＬＤＧ　　｜　　ＢＬＤＧ　　｜　　ＢＬＤＧ　　｜　　　　＃",
		"＃　　｜　　　　　　　　｜　　　　　　　　｜　　　　　　　　｜　　　　　　　　｜ＬＡＯ－ＸＩＡＯ｜　　　　＃",
		"＃　　｜　　　　　　　　｜　　　　　　　　｜　　　？　　　　｜　　　　　　　　｜　　　　　　　　｜　　　　＃",
		"＃　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　＃",
		"＃　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　＃",
		"＃　　　，　　，　　，　　，　　，　　，　　，　　，　　，　　，　　，　　，　　，　　，　　，　　　　　　＃",
		"＃　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　＃",
		"＃　　　？　？　　　　　？　　　　　　　　　　　　　　　　　　？　　　　　　　　　　　　　　　　？　　　　＃",
		"＃　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　＃",
		"＃　　　，　　，　　，　　，　　，　　，　　，　　，　　，　　，　　，　　，　　，　　，　　，　　　　　　＃",
		"＃　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　＃",
		"＃　　．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．　　　　＃",
		"＃　　＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿　　　＃",
		"＃　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　＃",
		"＃　　％　％％　　％　　％　％　　％　　％％　％　　％　　％　％％　　％　　％　％　　％％　　％　　　　　＃",
		"＃　　％％　％　　％％　　％　％％　　％　　％％　％　　％％　　％　％％　　％　　％　％％　％％　　　　　＃",
		"＃　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　＃",
		"＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃",
	]
