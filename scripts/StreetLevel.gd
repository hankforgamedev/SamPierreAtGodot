extends AsciiLevelBase

func _get_level_name() -> String:
	return "[ 虎寨城  //  中環路  //  深夜 ]"

func _get_level_id() -> String:
	return "street"

func _get_scene_intro() -> String:
	return "中環路。深夜。\n\n街上沒有人。只有路燈和影子，還有遠處某個地方漏出的昏黃燈光。\n\n巷子深處透著昏黃的燈光。老蕭餐館——全年無休。"

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
