extends Control

const C_BG       := Color(0.062, 0.048, 0.038)
const C_PANEL    := Color(0.10,  0.078, 0.060)
const C_BORDER   := Color(0.50,  0.36,  0.14)
const C_AMBER    := Color(0.96,  0.80,  0.38)
const C_BODY     := Color(0.88,  0.84,  0.74)
const C_DIM      := Color(0.50,  0.42,  0.30)
const C_RED      := Color(0.85,  0.25,  0.20)
const C_GREEN    := Color(0.30,  0.72,  0.30)

const QUOTA      := 6
const LEE_CHANCE := 0.35

var NAMES    : Array = []
var CHARGES  : Array = []
var OFFICERS : Array = []
var NOTES    : Array = []
var LEE_LINES: Array = []
var MOODS    : Array = []
var _finish_text: String = ""

var _rng        := RandomNumberGenerator.new()
var _processed  := 0
var _used_names := []

var _quota_lbl   : Label
var _case_num    : Label
var _name_lbl    : Label
var _charge_lbl  : Label
var _officer_lbl : Label
var _note_lbl    : Label
var _mood_lbl    : Label
var _approve_btn : Button
var _reject_btn  : Button
var _stamp_lbl   : Label
var _lee_panel   : Panel
var _lee_lbl     : Label


func _ready() -> void:
	var mg := StoryLoader.load_minigame("res://story/minigame.md")
	NAMES        = mg.get("names",       [])
	CHARGES      = mg.get("charges",     [])
	OFFICERS     = mg.get("officers",    [])
	NOTES        = mg.get("notes",       [])
	LEE_LINES    = mg.get("lee_lines",   [])
	MOODS        = mg.get("moods",       [])
	_finish_text = mg.get("finish_text", "")
	_rng.randomize()
	_build_ui()
	_next_case()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = C_BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var hdr := Label.new()
	hdr.text = "虎寨城警局下城總局  ─  文書處理站"
	hdr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hdr.add_theme_color_override("font_color", C_DIM)
	hdr.add_theme_font_size_override("font_size", 12)
	hdr.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hdr.offset_top    = 14
	hdr.offset_bottom = 36
	add_child(hdr)

	_quota_lbl = Label.new()
	_quota_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_quota_lbl.add_theme_color_override("font_color", C_AMBER)
	_quota_lbl.add_theme_font_size_override("font_size", 13)
	_quota_lbl.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_quota_lbl.offset_top    = 38
	_quota_lbl.offset_bottom = 60
	add_child(_quota_lbl)

	var doc := Panel.new()
	doc.anchor_left   = 0.5;  doc.anchor_right  = 0.5
	doc.anchor_top    = 0.5;  doc.anchor_bottom = 0.5
	doc.offset_left   = -255; doc.offset_right  = 255
	doc.offset_top    = -180; doc.offset_bottom = 125
	doc.add_theme_stylebox_override("panel", _sty(C_PANEL, C_BORDER, 2, 22))
	add_child(doc)

	var inner := VBoxContainer.new()
	inner.set_anchors_preset(Control.PRESET_FULL_RECT)
	inner.add_theme_constant_override("separation", 10)
	doc.add_child(inner)

	_case_num    = _lbl("", 11, C_DIM)
	_name_lbl    = _lbl("", 16, C_BODY)
	_charge_lbl  = _lbl("", 14, C_AMBER)
	_officer_lbl = _lbl("", 12, C_DIM)
	_note_lbl    = _lbl("", 12, C_DIM)
	_charge_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_note_lbl.autowrap_mode   = TextServer.AUTOWRAP_WORD_SMART

	inner.add_child(_case_num)
	inner.add_child(HSeparator.new())
	inner.add_child(_name_lbl)
	inner.add_child(_charge_lbl)
	inner.add_child(_officer_lbl)
	inner.add_child(_note_lbl)

	_mood_lbl = _lbl("", 11, C_DIM)
	_mood_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mood_lbl.anchor_left   = 0.5;  _mood_lbl.anchor_right  = 0.5
	_mood_lbl.anchor_top    = 0.5;  _mood_lbl.anchor_bottom = 0.5
	_mood_lbl.offset_left   = -255; _mood_lbl.offset_right  = 255
	_mood_lbl.offset_top    = 136;  _mood_lbl.offset_bottom = 158
	add_child(_mood_lbl)

	var btn_row := HBoxContainer.new()
	btn_row.anchor_left   = 0.5;  btn_row.anchor_right  = 0.5
	btn_row.anchor_top    = 0.5;  btn_row.anchor_bottom = 0.5
	btn_row.offset_left   = -210; btn_row.offset_right  = 210
	btn_row.offset_top    = 163;  btn_row.offset_bottom = 213
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 40)
	add_child(btn_row)

	_reject_btn  = _btn("◀  駁回", C_RED)
	_approve_btn = _btn("核准  ▶", C_GREEN)
	_reject_btn.pressed.connect(_on_reject)
	_approve_btn.pressed.connect(_on_approve)
	btn_row.add_child(_reject_btn)
	btn_row.add_child(_approve_btn)

	_stamp_lbl = Label.new()
	_stamp_lbl.visible = false
	_stamp_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stamp_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	_stamp_lbl.add_theme_font_size_override("font_size", 56)
	_stamp_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_stamp_lbl)

	_lee_panel = Panel.new()
	_lee_panel.visible = false
	_lee_panel.anchor_left   = 0.5;  _lee_panel.anchor_right  = 0.5
	_lee_panel.anchor_top    = 0.5;  _lee_panel.anchor_bottom = 0.5
	_lee_panel.offset_left   = -220; _lee_panel.offset_right  = 220
	_lee_panel.offset_top    = -85;  _lee_panel.offset_bottom = 85
	_lee_panel.add_theme_stylebox_override("panel",
		_sty(Color(0.12, 0.09, 0.07), Color(0.9, 0.75, 0.2), 2, 20))
	add_child(_lee_panel)

	var lv := VBoxContainer.new()
	lv.set_anchors_preset(Control.PRESET_FULL_RECT)
	lv.add_theme_constant_override("separation", 12)
	_lee_panel.add_child(lv)

	lv.add_child(_lbl("李先生", 12, Color(0.9, 0.75, 0.2)))
	_lee_lbl = _lbl("", 14, C_BODY)
	_lee_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lv.add_child(_lee_lbl)
	var ok := _btn("（點頭）", C_DIM)
	ok.pressed.connect(_dismiss_lee)
	lv.add_child(ok)


func _sty(bg: Color, border: Color, bw: int, mg: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(bw)
	s.set_content_margin_all(mg)
	return s


func _lbl(txt: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = txt
	l.add_theme_color_override("font_color", color)
	l.add_theme_font_size_override("font_size", size)
	return l


func _btn(txt: String, color: Color) -> Button:
	var b := Button.new()
	b.text = txt
	b.add_theme_color_override("font_color", color)
	b.add_theme_font_size_override("font_size", 15)
	b.add_theme_stylebox_override("normal",
		_sty(C_PANEL, color.darkened(0.4), 1, 12))
	b.add_theme_stylebox_override("hover",
		_sty(color.darkened(0.55), color, 1, 12))
	b.add_theme_stylebox_override("pressed",
		_sty(color.darkened(0.55), color, 1, 12))
	return b


func _next_case() -> void:
	_update_quota()
	var charge  : String = CHARGES[_rng.randi() % CHARGES.size()]
	var officer : String = OFFICERS[_rng.randi() % OFFICERS.size()]
	var note    : String = NOTES[_rng.randi() % NOTES.size()]
	var yr := _rng.randi_range(88, 113)
	var mo := _rng.randi_range(1, 12)
	var dy := _rng.randi_range(1, 28)

	_case_num.text    = "案號 CH-%04d  ·  %d年%02d月%02d日" % [
		_rng.randi_range(1000, 9999), yr, mo, dy]
	_name_lbl.text    = "姓名：%s" % _pick_name()
	_charge_lbl.text  = "罪名：%s" % charge
	_officer_lbl.text = "逮捕：%s" % officer
	_note_lbl.text    = note
	_mood_lbl.text    = MOODS[_rng.randi() % MOODS.size()]

	_approve_btn.disabled = false
	_reject_btn.disabled  = false


func _pick_name() -> String:
	if _used_names.size() >= NAMES.size():
		_used_names.clear()
	while true:
		var n : String = NAMES[_rng.randi() % NAMES.size()]
		if not _used_names.has(n):
			_used_names.append(n)
			return n
	return ""


func _update_quota() -> void:
	_quota_lbl.text = "今日配額：%d / %d  份已處理" % [_processed, QUOTA]


func _on_approve() -> void:
	_approve_btn.disabled = true
	_reject_btn.disabled  = true
	_show_stamp("核\n准", Color(0.20, 0.65, 0.20, 0.85))


func _on_reject() -> void:
	_approve_btn.disabled = true
	_reject_btn.disabled  = true
	_show_stamp("駁\n回", Color(0.75, 0.15, 0.15, 0.85))


func _show_stamp(text: String, color: Color) -> void:
	_stamp_lbl.text = text
	_stamp_lbl.add_theme_color_override("font_color", color)
	_stamp_lbl.visible = true
	await get_tree().create_timer(0.65).timeout
	_stamp_lbl.visible = false
	_processed += 1
	if _processed >= QUOTA:
		_finish_game()
	elif _rng.randf() < LEE_CHANCE:
		_show_lee()
	else:
		_next_case()


func _show_lee() -> void:
	_lee_lbl.text = LEE_LINES[_rng.randi() % LEE_LINES.size()]
	_lee_panel.visible    = true
	_approve_btn.disabled = true
	_reject_btn.disabled  = true


func _dismiss_lee() -> void:
	_lee_panel.visible = false
	_next_case()


func _finish_game() -> void:
	_update_quota()
	_approve_btn.visible = false
	_reject_btn.visible  = false
	_mood_lbl.text = _finish_text
	await get_tree().create_timer(2.8).timeout
	get_tree().change_scene_to_file("res://scenes/GameScene.tscn")
