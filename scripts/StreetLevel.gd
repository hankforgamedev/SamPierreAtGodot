extends AsciiLevelBase

func _get_level_name() -> String:
	return "[ 虎寨城  //  中環路  //  深夜 ]"

func _get_player_spawn() -> Vector2i:
	return Vector2i(5, 13)

func _get_npcs() -> Dictionary:
	return {
		Vector2i(47, 13): {
			"next_level": "res://scenes/LaoxiaoRestaurant.tscn",
			"char_id":    "narrator",
			"display":    ">",
			"ambient_a":  "巷子深處透著昏黃的燈光。老蕭餐館——全年無休。",
		},
	}

func _get_map_data() -> Array:
	return [
		"####################################################",
		"#  |        |        |        |        |        |  #",
		"#  |  BLDG  |  BLDG  |  BLDG  |  BLDG  |  BLDG  |  #",
		"#  |        |        |        |        |  LAOXIAO|  #",
		"#  |        |        |   ?    |        |        |  #",
		"#                                                    #",
		"#                                                    #",
		"#   ,  ,  ,  ,  ,  ,  ,  ,  ,  ,  ,  ,  ,  ,  ,   #",
		"#                                                    #",
		"#   ? ?     ?                ?                ?     #",
		"#                                                    #",
		"#   ,  ,  ,  ,  ,  ,  ,  ,  ,  ,  ,  ,  ,  ,  ,   #",
		"#                                                    #",
		"#  ..............................................  >  #",
		"#  _______________________________________________   #",
		"#                                                    #",
		"#  % %%  %  % %  %  %% %  %  % %%  %  % %  %%  %  #",
		"#  %% %  %%  % %%  %  %% %  %%  % %%  %  % %% %%  #",
		"#                                                    #",
		"####################################################",
	]
