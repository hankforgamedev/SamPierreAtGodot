extends AsciiLevelBase

var _train_triggered: bool = false

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
			"ambient_a":  "月台那端有個人。深夜，末班車前。",
			"ambient_b":  "末班車不再回來了。",
		},
		Vector2i(47, 9): {
			"start_chapter": "ch2",
			"char_id":       "narrator",
			"display":       ">",
			"ambient_a":     "出口在那邊。天還沒亮。",
		},
	}

func _on_dialogue_closed() -> void:
	super._on_dialogue_closed()
	if _last_dialogue_chapter == "ch1":
		_transition_to_ch2()
	else:
		stress_level = 0.7

func _transition_to_ch2() -> void:
	_in_dialogue = true
	trigger_flash(Color.BLACK, 1.8)
	await get_tree().create_timer(1.9).timeout
	GameManager.start_chapter("ch2")

func _on_player_moved() -> void:
	if not _train_triggered and _player_pos.y >= 16:
		_train_triggered = true
		_trigger_train_death()

func _trigger_train_death() -> void:
	_in_dialogue = true

	var narr := _make_narration("隆隆聲——")
	add_child(narr)
	await get_tree().create_timer(0.9).timeout

	# 火車從右邊衝入
	var train := Label.new()
	train.text = "══════════════╗▶"
	train.add_theme_font_size_override("font_size", 36)
	train.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95))
	var vp_size := get_viewport().get_visible_rect().size
	var track_y  := _base_map_pos.y + 16 * 28.0 - 18.0
	train.position = Vector2(vp_size.x + 40.0, track_y)
	train.z_index  = 80
	add_child(train)

	var tw := create_tween()
	tw.tween_property(train, "position:x", -500.0, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(0.28).timeout

	# 衝到玩家位置：爆炸效果
	trigger_shake(22.0, 0.7)
	trigger_flash(Color.WHITE, 0.35)
	narr.text = "——末班車從黑暗中衝出——"

	await get_tree().create_timer(0.8).timeout
	train.queue_free()
	narr.queue_free()

	trigger_flash(Color.BLACK, 2.0)
	await get_tree().create_timer(2.1).timeout
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")

func _make_narration(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 22)
	lbl.add_theme_color_override("font_color", Color(0.88, 0.84, 0.74))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	lbl.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	lbl.z_index = 90
	return lbl

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
