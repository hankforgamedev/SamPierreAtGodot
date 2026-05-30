extends AsciiLevelBase

const TRACK_ROW := 15  # map row index of the train track (rail row)

var _train_triggered: bool = false

func _ready() -> void:
	_level_text = StoryLoader.load_level_text("res://story/levels/station.md")
	super._ready()

func _get_level_name() -> String:
	return _level_text.get("level_name", "")

func _get_level_id() -> String:
	return "station"

func _get_scene_intro() -> String:
	return _level_text.get("intro", "")

func _get_player_spawn() -> Vector2i:
	return Vector2i(6, 9)

func _get_npcs() -> Dictionary:
	var amb: Dictionary = _level_text.get("ambient", {})
	return {
		Vector2i(33, 9): {
			"chapter_id": "ch1",
			"start_line": 0,
			"char_id":    "rat",
			"display":    "鼠",
			"ambient_a":  (amb.get("33,9", {}) as Dictionary).get("before", ""),
			"ambient_b":  (amb.get("33,9", {}) as Dictionary).get("after", ""),
		},
		Vector2i(35, 9): {
			"start_chapter": "ch2",
			"char_id":       "narrator",
			"display":       "＞",
			"ambient_a":     (amb.get("35,9", {}) as Dictionary).get("before", ""),
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
	SoundManager.play_sfx("tv_crash_noise")
	await get_tree().create_timer(1.9).timeout
	if not is_inside_tree():
		return
	GameManager.start_chapter("ch2")

func _on_player_moved() -> void:
	if not _train_triggered and _player_pos.y >= TRACK_ROW:
		_train_triggered = true
		_trigger_train_death()

# [DEBUG] train y postion wrong
func _trigger_train_death() -> void:
	_in_dialogue = true

	var narr := _make_narration("隆隆聲——")
	add_child(narr)
	SoundManager.play_sfx("riser")
	await get_tree().create_timer(1.2).timeout

	# 火車從右邊衝入
	var train := Label.new()
	train.text = "══════════════╗▶"
	train.theme_type_variation = "TitleLabel"
	train.add_theme_color_override("font_color", Color(GameTheme.C_TRAIN))
	var vp_size := get_viewport().get_visible_rect().size
	var track_y  := _base_map_pos.y + float(TRACK_ROW) * float(_font_size)
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
	SoundManager.play_sfx("explosion")

	SoundManager.play_sfx("tom_screaming")
	await get_tree().create_timer(0.8).timeout
	train.queue_free()
	narr.queue_free()

	trigger_flash(Color.BLACK, 2.0)
	await get_tree().create_timer(2.1).timeout
	if not is_inside_tree():
		return
	GameOverlay.show_overlay(self, "——末班車——")

func _make_narration(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	lbl.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	lbl.z_index = 90
	return lbl

func _get_map_data() -> Array:
	return [
"＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃",
"＃　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　＃",
"＃　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　＃",
"＃　　！！　ＳＴＡＹ　ＢＥＨＩＮＤ　ＴＨＥ　ＹＥＬＬＯＷ　ＬＩＮＥ　！！　　　　　　＃",
"＃　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　＃",
"＃　　．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．　＃",
"＃　　．　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　．　＃",
"＃　　．　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　．　＃",
"＃　　．　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　．　＃",
"＃　　．　　　　　　　　　　Ｉ　　　　　Ｉ　　Ｉ　　　　Ｉ　　　　　　　　　　　．　＃",
"＃　　．　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　．　＃",
"＃　　．　　　　　　　　　　％　　　　　％　　％　　　　％　　　　　　　　　　　．　＃",
"＃　　．　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　．　＃",
"＃　　．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．．　＃",
"＃＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＃",
"＃　　［　地鐵軌道　］　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　＃",
"＃　　　＿　＿　＿　＿　＿　＿　＿　＿　＿　＿　＿　＿　＿　＿　＿　＿　＿　＿　＿　＃",
"＃　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　＃",
"＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃",
	]
