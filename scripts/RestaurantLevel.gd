extends AsciiLevelBase

func _get_level_name() -> String:
	return "[ 老蕭餐館  //  深夜  //  最後一桌 ]"

func _get_player_spawn() -> Vector2i:
	return Vector2i(4, 11)

func _get_npcs() -> Dictionary:
	return {
		Vector2i(36, 11): {
			"chapter_id": "ch5",
			"start_line": 0,
			"char_id":    "moujia",
			"display":    "甲",
		},
		Vector2i(2, 11): {
			"next_level": "res://scenes/Street.tscn",
			"char_id":    "narrator",
			"display":    "<",
		},
	}

func _get_map_data() -> Array:
	return [
		"####################################################",
		"#  老 蕭 餐 館            ( 24hr )                #",
		"#  --------------------------------------------------#",
		"#                                                  #",
		"#   (O)                              (O)           #",
		"#                                                  #",
		"#  [TABLE]          [TABLE]       [TABLE]          #",
		"#   ----              ----          ----           #",
		"#                                                  #",
		"#                   [COUNTER]---------[COUNTER]   #",
		"#                                                  #",
		"#                                                  #",
		"#                                                  #",
		"#  ..............................................  #",
		"#__________________________________________________#",
		"#                                                  #",
		"#  % %%  % %  %% %%  % %%  %  % %%  %% %%  %  %  #",
		"#                                                  #",
		"####################################################",
	]
