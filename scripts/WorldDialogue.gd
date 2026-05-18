extends Control

const C_PANEL_BG     := Color(0.10, 0.078, 0.060, 1.0)
const C_PANEL_BORDER := Color(0.50, 0.36,  0.14,  1.0)
const C_HEADER_BG    := Color(0.06, 0.05,  0.04,  1.0)
const C_SPEAKER_TEXT := Color(0.96, 0.80,  0.38,  1.0)
const C_BODY_TEXT    := Color(0.88, 0.84,  0.74,  1.0)
const C_NARRATOR     := Color(0.62, 0.58,  0.48,  1.0)
const C_CHOICE_BG    := Color(0.14, 0.12,  0.09,  1.0)
const C_CHOICE_HVR   := Color(0.22, 0.18,  0.12,  1.0)
const C_CHOICE_TXT   := Color(0.88, 0.84,  0.74,  1.0)
const C_CHOICE_HVTXT := Color(1.00, 0.96,  0.84,  1.0)
const C_STAMP_BORDER := Color(0.60, 0.08,  0.05,  1.0)
const SPEED_FAST   := 0.008
const SPEED_NORMAL := 0.020
const SPEED_SLOW   := 0.045

# ── Original design sizes (must match AsciiLevelBase.BASE_MAP_FONT) ───
const BASE_MAP_FONT   := 28
const BASE_SPK_FONT   := 13
const BASE_DLG_FONT   := 16
const BASE_BTN_FONT   := 14
const BASE_TITLE_FONT := 12
const BASE_MARGIN     := 18
const BASE_ACCENT_H   := 20
const BASE_BTN_MARGIN := 8

signal dialogue_closed
signal line_fx(effects: Array)

var _chapter      : Dictionary = {}
var _lines        : Array      = []
var _current_index: int        = 0
var _typing       := false
var _full_text    := ""
var _typed_so_far := ""
var _type_timer   := 0.0
var _type_speed   := SPEED_NORMAL
var _has_choices    := false
var _can_advance    := false
var _map_font_size  := BASE_MAP_FONT
var _log_bbcode      : String = ""
var _cur_entry_header: String = ""
var _cur_body_hex    : String = ""

@onready var spk_name      : Label           = $RightPanel/Margin/Inner/SpeakerHeader/SpeakerBar/SpeakerName
@onready var speaker_accent: ColorRect       = $RightPanel/Margin/Inner/SpeakerHeader/SpeakerBar/SpeakerAccent
@onready var speaker_header: PanelContainer  = $RightPanel/Margin/Inner/SpeakerHeader
@onready var dlg_text      : RichTextLabel   = $RightPanel/Margin/Inner/DialogueText
@onready var choice_panel  : VBoxContainer   = $RightPanel/Margin/Inner/ChoicePanel
@onready var choice_buttons: VBoxContainer   = $RightPanel/Margin/Inner/ChoicePanel/ChoiceButtons
@onready var choice_title  : Label           = $RightPanel/Margin/Inner/ChoicePanel/ChoiceTitle
@onready var margin_box    : MarginContainer = $RightPanel/Margin

func _ready() -> void:
	_apply_panel_style()

func _apply_panel_style() -> void:
	var panel := $RightPanel as Panel
	var sty   := StyleBoxFlat.new()
	sty.bg_color = C_PANEL_BG
	sty.border_color = C_PANEL_BORDER
	sty.set_border_width_all(3)
	panel.add_theme_stylebox_override("panel", sty)
	var hdr := StyleBoxFlat.new()
	hdr.bg_color = C_HEADER_BG
	hdr.set_content_margin_all(6)
	speaker_header.add_theme_stylebox_override("panel", hdr)
	dlg_text.bbcode_enabled   = true
	dlg_text.scroll_active    = true
	dlg_text.scroll_following = true
	dlg_text.fit_content      = false
	var dlg_font := SystemFont.new()
	dlg_font.font_names = PackedStringArray(["Consolas", "Courier New", "Courier", "Monospace"])
	dlg_text.add_theme_font_override("normal_font", dlg_font)

func apply_scale(map_font_size: int) -> void:
	_map_font_size = map_font_size
	var m := BASE_MARGIN * map_font_size / BASE_MAP_FONT
	margin_box.add_theme_constant_override("margin_left",   m)
	margin_box.add_theme_constant_override("margin_right",  m)
	margin_box.add_theme_constant_override("margin_top",    m)
	margin_box.add_theme_constant_override("margin_bottom", m)
	speaker_accent.custom_minimum_size = Vector2(4.0, float(BASE_ACCENT_H * map_font_size) / float(BASE_MAP_FONT))
	spk_name.add_theme_font_size_override("font_size",        32)
	dlg_text.add_theme_font_size_override("normal_font_size", 40)
	choice_title.add_theme_font_size_override("font_size",    26)

func open(chapter_id: String, start_line: int = 0) -> void:
	_chapter = DialogueData.get_chapter(chapter_id)
	if _chapter.is_empty():
		return
	_lines = _chapter["lines"] as Array
	visible = true
	_show_line(start_line)

func close() -> void:
	visible = false
	_chapter    = {}
	_lines      = []
	_log_bbcode = ""
	_full_text  = ""
	dlg_text.text = ""
	dialogue_closed.emit()

func _process(delta: float) -> void:
	if not _typing:
		return
	_type_timer += delta
	while _type_timer >= _type_speed and _typed_so_far.length() < _full_text.length():
		_type_timer -= _type_speed
		_typed_so_far += _full_text[_typed_so_far.length()]
		_update_display()
	if _typed_so_far.length() >= _full_text.length():
		_typing      = false
		_can_advance = true

func _input(event: InputEvent) -> void:
	if not visible:
		return
	var is_keyboard := event.is_action_pressed("ui_accept")
	var is_mouse    := event is InputEventMouseButton \
		and (event as InputEventMouseButton).pressed \
		and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT
	# When choices are shown, let mouse events reach the buttons
	if _has_choices and is_mouse:
		return
	var is_advance := is_keyboard or is_mouse
	if not is_advance:
		return
	get_viewport().set_input_as_handled()
	if _typing:
		_finish_typing()
	elif _can_advance and not _has_choices:
		_advance()

func _finish_typing() -> void:
	_typed_so_far = _full_text
	_update_display()
	_typing      = false
	_can_advance = true

func _advance() -> void:
	var line := _lines[_current_index] as Dictionary
	if line.has("next"):
		_show_line(line["next"] as int)
	elif _current_index + 1 >= _lines.size():
		close()
	else:
		_show_line(_current_index + 1)

func _show_line(index: int) -> void:
	_commit_current_line()
	_current_index = index
	_can_advance   = false
	_has_choices   = false
	choice_panel.visible = false

	var line: Dictionary = _lines[index] as Dictionary

	if line.has("minigame"):
		GameManager.resume_line = index + 1
		GameManager.current_chapter_id = _chapter.get("id", "") as String
		get_tree().change_scene_to_file("res://scenes/CivilServantGame.tscn")
		return

	var spk_key  : String = line.get("speaker", "narrator") as String
	var display  : String = GameManager.SPEAKER_NAMES.get(spk_key, "") as String
	spk_name.text = display.to_upper() if display != "" else "— — —"
	var spk_color: Color  = GameManager.CHAR_COLORS.get(spk_key, C_SPEAKER_TEXT) as Color
	spk_name.add_theme_color_override("font_color", spk_color)
	speaker_accent.color = spk_color.darkened(0.3)

	var is_narr     : bool   = spk_key == "narrator"
	var body_color  : Color  = C_NARRATOR if is_narr else C_BODY_TEXT
	_cur_body_hex            = "#" + body_color.to_html(false)
	var disp_upper  : String = display.to_upper() if display != "" else ""
	if disp_upper != "":
		_cur_entry_header = "[color=#%s]%s[/color]\n" % [spk_color.to_html(false), disp_upper]
	else:
		_cur_entry_header = ""

	if line.has("choices"):
		_has_choices = true
		_build_choices(line["choices"] as Array)

	var spd: String = line.get("speed", "normal") as String
	match spd:
		"fast":  _type_speed = SPEED_FAST
		"slow":  _type_speed = SPEED_SLOW
		_:       _type_speed = SPEED_NORMAL

	var fx: Array = line.get("fx", []) as Array
	if fx.size() > 0:
		line_fx.emit(fx)

	_full_text    = line.get("text", "") as String
	_typed_so_far = ""
	_type_timer   = 0.0
	_typing       = true
	_update_display()

func _commit_current_line() -> void:
	if _full_text == "":
		return
	_log_bbcode += _cur_entry_header + "[color=" + _cur_body_hex + "]" + _full_text + "[/color]\n\n"

func _update_display() -> void:
	dlg_text.text = _log_bbcode + _cur_entry_header \
		+ "[color=" + _cur_body_hex + "]" + _typed_so_far + "[/color]"

func _build_choices(choices: Array) -> void:
	for child in choice_buttons.get_children():
		child.queue_free()
	choice_panel.visible = true
	for i in choices.size():
		var choice : Dictionary = choices[i] as Dictionary
		var btn    := Button.new()
		btn.text = "  ► " + (choice["text"] as String)
		btn.flat = true
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_size_override("font_size", 32)
		btn.add_theme_color_override("font_color",         C_CHOICE_TXT)
		btn.add_theme_color_override("font_hover_color",   C_CHOICE_HVTXT)
		btn.add_theme_color_override("font_pressed_color", Color.WHITE)
		var sn := StyleBoxFlat.new()
		sn.bg_color = C_CHOICE_BG
		sn.border_color = Color(0.35, 0.30, 0.22)
		sn.set_border_width_all(1)
		sn.set_content_margin_all(float(BASE_BTN_MARGIN * _map_font_size) / float(BASE_MAP_FONT))
		var sh := StyleBoxFlat.new()
		sh.bg_color = C_CHOICE_HVR
		sh.border_color = C_STAMP_BORDER
		sh.set_border_width_all(1)
		sh.set_content_margin_all(float(BASE_BTN_MARGIN * _map_font_size) / float(BASE_MAP_FONT))
		btn.add_theme_stylebox_override("normal",  sn)
		btn.add_theme_stylebox_override("hover",   sh)
		btn.add_theme_stylebox_override("pressed", sh)
		var goto_index: int = choice["goto"] as int
		btn.pressed.connect(_on_choice(goto_index))
		choice_buttons.add_child(btn)

func _on_choice(goto_index: int) -> Callable:
	return func() -> void:
		choice_panel.visible = false
		_has_choices = false
		_show_line(goto_index)
