class_name DialogueBox3D
extends Control

## 3D 世界的章節對話 UI：無底框純文字 + 黑描邊（Arctic Eggs 風）
## 資料層與 2D 完全共用：DialogueData 章節（story/chapters/*.md）
## 主場景（Arctic3D）負責：呼叫 open()/advance()、凍結玩家、切換滑鼠模式

signal closed
signal choices_visible_changed(active: bool)
signal line_fx(effects: Array)

const SPEED := {"fast": 0.008, "normal": 0.020, "slow": 0.045}
const C_SPEAKER := Color(0.96, 0.80, 0.38)
const C_BODY := Color(0.88, 0.84, 0.74)
const C_NARRATOR := Color(0.62, 0.58, 0.48)
const C_OUTLINE := Color(0, 0, 0, 0.85)

var _chapter: Dictionary = {}
var _lines: Array = []
var _index := 0
var _typing := false
var _type_timer := 0.0
var _type_speed: float = SPEED["normal"]
var _has_choices := false

var _speaker_label: Label
var _text_label: Label
var _choice_box: VBoxContainer


func _ready() -> void:
	visible = false
	# 必須用 and_offsets 版本：set_anchors_preset 會依「目前最小尺寸(0x0)」
	# 重算 offsets，把純 Control 縮成零尺寸釘在左上角
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var font := SystemFont.new()
	font.font_names = ["Consolas", "Courier New"]

	var vbox := VBoxContainer.new()
	vbox.anchor_left = 0.2
	vbox.anchor_right = 0.8
	vbox.anchor_top = 1.0
	vbox.anchor_bottom = 1.0
	vbox.offset_top = -420  # 給長段落與選項按鈕留空間，ALIGNMENT_END 會貼底
	vbox.offset_bottom = -40
	vbox.alignment = BoxContainer.ALIGNMENT_END
	vbox.add_theme_constant_override("separation", 10)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vbox)

	_choice_box = VBoxContainer.new()
	_choice_box.add_theme_constant_override("separation", 4)
	vbox.add_child(_choice_box)

	_speaker_label = _make_label(font, 22, C_SPEAKER)
	vbox.add_child(_speaker_label)

	_text_label = _make_label(font, 26, C_BODY)
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.custom_minimum_size = Vector2(0, 100)
	vbox.add_child(_text_label)


func is_open() -> bool:
	return visible


func open(chapter_id: String, start_line := 0) -> void:
	_chapter = DialogueData.get_chapter(chapter_id)
	if _chapter.is_empty():
		push_warning("DialogueBox3D: unknown chapter '%s'" % chapter_id)
		return
	_lines = _chapter["lines"] as Array
	visible = true
	_show_line(start_line)


func close() -> void:
	visible = false
	_chapter = {}
	_lines = []
	if _has_choices:
		_has_choices = false
		choices_visible_changed.emit(false)
	closed.emit()


## E 鍵：打字中先跳完整句；否則前進（選項顯示中則交給按鈕）
func advance() -> void:
	if _typing:
		_text_label.visible_characters = -1
		_typing = false
	elif not _has_choices:
		var line := _lines[_index] as Dictionary
		if line.has("next"):
			_show_line(line["next"] as int)
		elif _index + 1 >= _lines.size():
			close()
		else:
			_show_line(_index + 1)


func _process(delta: float) -> void:
	if not _typing:
		return
	_type_timer += delta
	while _type_timer >= _type_speed and _typing:
		_type_timer -= _type_speed
		_text_label.visible_characters += 1
		if _text_label.visible_characters >= _text_label.text.length():
			_text_label.visible_characters = -1
			_typing = false


func _show_line(index: int) -> void:
	_index = index
	var line := _lines[index] as Dictionary

	# minigame 行為與 2D WorldDialogue 一致：存 resume 點後切場景
	if line.has("minigame"):
		GameManager.resume_line = index + 1
		GameManager.current_chapter_id = _chapter.get("id", "") as String
		get_tree().change_scene_to_file("res://scenes/CivilServantGame.tscn")
		return

	var spk: String = line.get("speaker", "narrator") as String
	var is_narrator := spk == "narrator"
	_speaker_label.visible = not is_narrator
	_speaker_label.text = GameManager.SPEAKER_NAMES.get(spk, "") as String
	_speaker_label.add_theme_color_override("font_color",
		GameManager.CHAR_COLORS.get(spk, C_SPEAKER) as Color)
	_text_label.add_theme_color_override("font_color",
		C_NARRATOR if is_narrator else C_BODY)

	_type_speed = SPEED.get(line.get("speed", "normal"), SPEED["normal"])
	var fx: Array = line.get("fx", []) as Array
	if fx.size() > 0:
		line_fx.emit(fx)

	_build_choices(line.get("choices", []) as Array)

	_text_label.text = line.get("text", "") as String
	_text_label.visible_characters = 0
	_type_timer = 0.0
	_typing = true


func _build_choices(choices: Array) -> void:
	for child in _choice_box.get_children():
		child.queue_free()
	var had_choices := _has_choices
	_has_choices = not choices.is_empty()
	if _has_choices != had_choices:
		choices_visible_changed.emit(_has_choices)

	var font := SystemFont.new()
	font.font_names = ["Consolas", "Courier New"]
	for choice: Dictionary in choices:
		var btn := Button.new()
		btn.flat = true
		btn.text = "► " + (choice["text"] as String)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_override("font", font)
		btn.add_theme_font_size_override("font_size", 24)
		btn.add_theme_color_override("font_color", C_BODY)
		btn.add_theme_color_override("font_hover_color", Color(1.0, 0.96, 0.84))
		btn.add_theme_color_override("font_outline_color", C_OUTLINE)
		btn.add_theme_constant_override("outline_size", 6)
		var goto_index: int = choice["goto"] as int
		btn.pressed.connect(func() -> void: _show_line(goto_index))
		_choice_box.add_child(btn)


func _make_label(font: Font, size: int, color: Color) -> Label:
	var lbl := Label.new()
	lbl.add_theme_font_override("font", font)
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_color_override("font_outline_color", C_OUTLINE)
	lbl.add_theme_constant_override("outline_size", 6)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return lbl
