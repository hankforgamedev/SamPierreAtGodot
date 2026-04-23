extends AsciiLevelBase

func _get_level_name() -> String:
	return "[ 虎寨城地鐵站 //  LINE 3  //  02:47  //  NO SERVICE TONIGHT ]"

func _get_player_spawn() -> Vector2i:
	return Vector2i(6, 9)

func _get_npcs() -> Dictionary:
	return {
		Vector2i(44, 9): {
			"chapter_id": "ch1",
			"start_line": 0,
			"char_id":    "rat",
			"display":    "?",
		},
		Vector2i(47, 9): {
			"start_chapter": "ch2",
			"char_id":       "narrator",
			"display":       ">",
		},
	}

func _on_dialogue_closed() -> void:
	super._on_dialogue_closed()
	stress_level = 0.7

func _get_map_data() -> Array:
	return [
		"####################################################",
		"#                                                  #",
		"#  METRO LINE 3  //  NO SERVICE  //  02:47        #",
		"#  !! STAY BEHIND THE YELLOW LINE !!              #",
		"#                                                  #",
		"#  ............................................  #",
		"#  .                                          .  #",
		"#  .                                          .  #",
		"#  .                                          .  #",
		"#  .                                          .  #",
		"#  .                                          .  #",
		"#  .          %     %  %    %                 .  #",
		"#  .                                          .  #",
		"#  ............................................  #",
		"#__________________________________________________#",
		"#  [ TRACK ]                                       #",
		"#   _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _    #",
		"#                                                  #",
		"####################################################",
	]
