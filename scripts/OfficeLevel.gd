extends AsciiLevelBase

func _ready() -> void:
	_level_text = StoryLoader.load_level_text("res://story/levels/office.md")
	super._ready()

func _get_level_name() -> String:
	return _level_text.get("level_name", "")

func _get_level_id() -> String:
	return "office"

func _get_ambient_track() -> String:
	return "big-office-1961"

func _get_scene_intro() -> String:
	return _level_text.get("intro", "")

func _get_player_spawn() -> Vector2i:
	return Vector2i(5, 10)

func _get_npcs() -> Dictionary:
	var amb: Dictionary = _level_text.get("ambient", {})
	return {
		Vector2i(41, 10): {
			"chapter_id": "ch3",
			"start_line": 0,
			"char_id":    "lee",
			"display":    "L",
			"ambient_a":  (amb.get("41,10", {}) as Dictionary).get("before", ""),
			"ambient_b":  (amb.get("41,10", {}) as Dictionary).get("after", ""),
		},
		Vector2i(47, 10): {
			"start_chapter": "ch4",
			"char_id":       "narrator",
			"display":       ">",
			"ambient_a":     (amb.get("47,10", {}) as Dictionary).get("before", ""),
		},
	}

func _on_dialogue_closed() -> void:
	super._on_dialogue_closed()
	stress_level = 0.2

func _get_map_data() -> Array:
	return [
		"####################################################",
		"#                                                  #",
		"#  HUK-ZAI CITY POLICE DEPT                       #",
		"#  FLOOR 3  //  HOMICIDE & PUBLIC ORDER           #",
		"#                                                  #",
		"#  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  #",
		"#                                                  #",
		"#  [DESK]          [DESK]                [DESK]   #",
		"#   ----            ----                  ----    #",
		"#                                                  #",
		"#  .                                          .    #",
		"#  .                                          .    #",
		"#  .                                          .    #",
		"#  ..............................................   #",
		"#                          [FILING] [FILING]       #",
		"#                                                  #",
		"#  % %  % %%  %  %  %  %% %  %%  %  %  %  % %%  #",
		"#                                                  #",
		"####################################################",
	]
