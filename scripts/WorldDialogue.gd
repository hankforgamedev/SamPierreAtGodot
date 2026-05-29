extends Control

const _SERIF := preload("res://font/genyo-min/GenYoMin2TW-R.otf")

# ── Layout scale roots (font sizes come from GameTheme) ──────────────────────
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
var _typed_count  := 0
var _type_timer   := 0.0
var _type_speed   := GameTheme.SPEED_NORMAL
var _has_choices    := false
var _can_advance    := false
var _is_player_line := false
var _map_font_size  := GameTheme.BASE_MAP_FONT
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
	SoundManager.score_finished.connect(func(): _can_advance = true)

func _apply_panel_style() -> void:
	var panel := $RightPanel as Panel
	var sty   := StyleBoxFlat.new()
	sty.bg_color = GameTheme.C_PANEL_BG
	sty.border_color = GameTheme.C_PANEL_BORDER
	sty.set_border_width_all(3)
	panel.add_theme_stylebox_override("panel", sty)
	var hdr := StyleBoxFlat.new()
	hdr.bg_color = GameTheme.C_HEADER_BG
	hdr.set_content_margin_all(6)
	speaker_header.add_theme_stylebox_override("panel", hdr)
	dlg_text.bbcode_enabled   = true
	dlg_text.scroll_active    = true
	dlg_text.scroll_following = true
	dlg_text.fit_content      = false
	dlg_text.focus_mode       = Control.FOCUS_NONE  # prevent stealing keyboard focus from choice buttons
	panel.clip_contents       = true                # prevent text/choices from rendering outside panel
	dlg_text.add_theme_font_override("normal_font", _SERIF)
	dlg_text.add_theme_constant_override("line_separation", 13.5)
	spk_name.theme_type_variation    = "SpeakerLabel"
	choice_title.theme_type_variation = "DimLabel"

func apply_scale(map_font_size: int) -> void:
	_map_font_size = map_font_size
	var m := BASE_MARGIN * map_font_size / GameTheme.BASE_MAP_FONT
	margin_box.add_theme_constant_override("margin_left",   m)
	margin_box.add_theme_constant_override("margin_right",  m)
	margin_box.add_theme_constant_override("margin_top",    m)
	margin_box.add_theme_constant_override("margin_bottom", m)
	speaker_accent.custom_minimum_size = Vector2(4.0, float(BASE_ACCENT_H * map_font_size) / float(GameTheme.BASE_MAP_FONT))

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
	while _type_timer >= _type_speed and _typed_count < _full_text.length():
		_type_timer -= _type_speed
		_typed_count += 1
		SoundManager.play_type_click()
	if _typed_count >= _full_text.length():
		_typing      = false
		_can_advance = true
		if _is_player_line:
			_advance()
	_update_display()

func _input(event: InputEvent) -> void:
	if not visible:
		return
	var is_keyboard := event.is_action_pressed("interact")
	var is_mouse    := event is InputEventMouseButton \
		and (event as InputEventMouseButton).pressed \
		and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT
	var is_nav_up   := event.is_action_pressed("move_up")
	var is_nav_down := event.is_action_pressed("move_down")
	if _has_choices:
		if is_mouse:
			return  # let mouse reach buttons
		if is_nav_up or is_nav_down:
			_navigate_choices(-1 if is_nav_up else 1)
			get_viewport().set_input_as_handled()
			return
		if is_keyboard:
			for btn: Button in choice_buttons.get_children():
				if btn.has_focus():
					get_viewport().set_input_as_handled()
					_select_choice(btn.get_meta("goto") as int)
					return
		return
	var is_advance := is_keyboard or is_mouse
	if not is_advance:
		return
	get_viewport().set_input_as_handled()
	if _typing:
		_finish_typing()
	elif _can_advance:
		_advance()

func _navigate_choices(delta: int) -> void:
	var btns := choice_buttons.get_children()
	if btns.is_empty():
		return
	var idx := 0
	for i in btns.size():
		if (btns[i] as Button).has_focus():
			idx = i
			break
	(btns[wrapi(idx + delta, 0, btns.size())] as Button).grab_focus()

func _finish_typing() -> void:
	_typed_count = _full_text.length()
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
	_is_player_line = spk_key == "sam"
	var display  : String = GameManager.SPEAKER_NAMES.get(spk_key, "") as String
	spk_name.text = display.to_upper() if display != "" else "— — —"
	var spk_color: Color  = GameTheme.CHAR_COLOR.get(spk_key, GameTheme.C_SPEAKER_TEXT) as Color
	spk_name.add_theme_color_override("font_color", spk_color)
	speaker_accent.color = spk_color.darkened(0.3)

	var is_narr     : bool   = spk_key == "narrator"
	var is_inner    : bool   = spk_key == "inner"
	var body_color  : Color  = GameTheme.C_NARRATOR if is_narr \
		else (GameTheme.C_INNER if is_inner else GameTheme.C_BODY_TEXT)
	_cur_body_hex            = "#" + body_color.to_html(false)
	var disp_upper  : String = display.to_upper() if display != "" else ""
	if disp_upper != "":
		_cur_entry_header = "[color=#%s]%s[/color]\n" % [spk_color.to_html(false), disp_upper]
	else:
		_cur_entry_header = ""

	if line.has("choices"):
		_has_choices = true
		_build_choices(line["choices"] as Array)

	var score_track: String = line.get("score", "") as String
	if score_track != "":
		_can_advance = false
		SoundManager.play_score(score_track, false)

	var spd: String = line.get("speed", "normal") as String
	match spd:
		"fast":  _type_speed = GameTheme.SPEED_FAST
		"slow":  _type_speed = GameTheme.SPEED_SLOW
		_:       _type_speed = GameTheme.SPEED_NORMAL

	var sfx_name: String = line.get("sfx", "") as String
	if sfx_name != "":
		SoundManager.play_sfx(sfx_name)

	var fx: Array = line.get("fx", []) as Array
	if fx.size() > 0:
		line_fx.emit(fx)

	_full_text   = line.get("text", "") as String
	if is_inner:
		_full_text = "[i]" + _full_text + "[/i]"
	_typed_count = 0
	_type_timer  = 0.0
	_typing      = true
	_update_display()

func _commit_current_line() -> void:
	if _full_text == "":
		return
	_log_bbcode += _cur_entry_header + "[color=" + _cur_body_hex + "]" + _full_text + "[/color]\n\n"

func _update_display() -> void:
	dlg_text.text = _log_bbcode + _cur_entry_header \
		+ "[color=" + _cur_body_hex + "]" + _full_text.substr(0, _typed_count) + "[/color]"
	if not _typing:
		dlg_text.scroll_to_line(dlg_text.get_line_count())

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
		btn.custom_minimum_size = Vector2(0, 0)
		btn.clip_text = true
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var sn := StyleBoxFlat.new()
		sn.bg_color = GameTheme.C_CHOICE_BG
		sn.border_color = GameTheme.C_CHOICE_BORDER_HVR
		sn.set_border_width_all(1)
		sn.set_content_margin_all(float(BASE_BTN_MARGIN * _map_font_size) / float(GameTheme.BASE_MAP_FONT))
		var sh := StyleBoxFlat.new()
		sh.bg_color = GameTheme.C_CHOICE_HVR
		sh.border_color = GameTheme.C_STAMP_BORDER
		sh.set_border_width_all(1)
		sh.set_content_margin_all(float(BASE_BTN_MARGIN * _map_font_size) / float(GameTheme.BASE_MAP_FONT))
		btn.add_theme_stylebox_override("normal",  sn)
		btn.add_theme_stylebox_override("hover",   sh)
		btn.add_theme_stylebox_override("pressed", sh)
		btn.add_theme_stylebox_override("focus",   sh)
		var goto_index: int = choice["goto"] as int
		btn.set_meta("goto", goto_index)
		btn.pressed.connect(_on_choice(goto_index))
		choice_buttons.add_child(btn)
	if choice_buttons.get_child_count() > 0:
		(choice_buttons.get_child(0) as Button).call_deferred("grab_focus")

func _select_choice(goto_index: int) -> void:
	SoundManager.play_type_ding()
	choice_panel.visible = false
	_has_choices = false
	_show_line(goto_index)

func _on_choice(goto_index: int) -> Callable:
	return func() -> void: _select_choice(goto_index)
