extends AsciiLevelBase

func _get_level_name() -> String:
	return "[ 虎寨城警察局  //  辦公室  //  08:55 ]"

func _get_player_spawn() -> Vector2i:
	return Vector2i(5, 10)

func _get_npcs() -> Dictionary:
	return {
		Vector2i(41, 10): {
			"chapter_id": "ch3",
			"start_line": 0,
			"char_id":    "lee",
			"display":    "L",
		},
	}

func _get_map_data() -> Array:
	return [
		"####################################################",
		"#                                                  #",
		"#  TIGER FORTRESS CITY POLICE DEPT                #",
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
