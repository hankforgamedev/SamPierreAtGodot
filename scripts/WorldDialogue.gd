extends Control

const C_PANEL_BG    := Color(0.10, 0.078, 0.060, 0.96)
const C_PANEL_BORDER:= Color(0.50, 0.36,  0.14,  1.0)
const C_SPEAKER_TEXT:= Color(0.96, 0.80,  0.38,  1.0)
const C_BODY_TEXT   := Color(0.88, 0.84,  0.74,  1.0)
const C_NARRATOR    := Color(0.60, 0.56,  0.46,  1.0)
const C_CHOICE_BG   := Color(0.08, 0.062, 0.048, 1.0)
const C_CHOICE_HVR  := Color(0.16, 0.12,  0.07,  1.0)
const C_CHOICE_TXT  := Color(0.72, 0.60,  0.38,  1.0)
const C_CHOICE_HVTXT:= Color(0.96, 0.80,  0.38,  1.0)
const TYPE_SPEED    := 0.020

signal dialogue_closed

var _chapter      : Dictionary = {}
var _lines        : Array      = []
var _current_index: int        = 0
var _typing       := false
var _full_text    := ""
var _typed_so_far := ""
var _type_timer   := 0.0
var _has_choices  := false
var _can_advance  := false

@onready var spk_name     : Label         = $RightPanel/Margin/Inner/SpeakerBar/SpeakerName
@onready var speaker_accent: ColorRect    = $RightPanel/Margin/Inner/SpeakerBar/SpeakerAccent
@onready var dlg_text     : Label         = $RightPanel/Margin/Inner/DialogueText
@onready var choice_panel : VBoxContainer = $RightPanel/Margin/Inner/ChoicePanel
@onready var choice_buttons: VBoxContainer= $RightPanel/Margin/Inner/ChoicePanel/ChoiceButtons

func _ready() -> void:
	_apply_panel_style()

func _apply_panel_style() -> void:
	var panel := $RightPanel as Panel
	var sty   := StyleBoxFlat.new()
	sty.bg_color = C_PANEL_BG
	sty.border_color = C_PANEL_BORDER
	sty.border_width_left = 2
	panel.add_theme_stylebox_override("panel", sty)
	dlg_text.add_theme_font_size_override("font_size", 16)
	dlg_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func open(chapter_id: String, start_line: int = 0) -> void:
	_chapter = DialogueData.get_chapter(chapter_id)
	if _chapter.is_empty():
		return
	_lines = _chapter["lines"] as Array
	visible = true
	_show_line(start_line)

func close() -> void:
	visible = false
	_chapter = {}
	_lines   = []
	dialogue_closed.emit()

func _process(delta: float) -> void:
	if not _typing:
		return
	_type_timer += delta
	while _type_timer >= TYPE_SPEED and _typed_so_far.length() < _full_text.length():
		_type_timer -= TYPE_SPEED
		_typed_so_far += _full_text[_typed_so_far.length()]
		dlg_text.text = _typed_so_far
	if _typed_so_far.length() >= _full_text.length():
		_typing      = false
		_can_advance = true

func _input(event: InputEvent) -> void:
	if not visible:
		return
	var is_advance := event.is_action_pressed("ui_accept") or \
		(event is InputEventMouseButton and (event as InputEventMouseButton).pressed \
		 and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT)
	if not is_advance:
		return
	get_viewport().set_input_as_handled()
	if _typing:
		_finish_typing()
	elif _can_advance and not _has_choices:
		_advance()

func _finish_typing() -> void:
	_typed_so_far = _full_text
	dlg_text.text = _full_text
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
	_current_index = index
	_can_advance   = false
	_has_choices   = false
	choice_panel.visible = false

	var line: Dictionary = _lines[index] as Dictionary

	if line.has("minigame"):
		GameManager.resume_line = index + 1
		get_tree().change_scene_to_file("res://scenes/CivilServantGame.tscn")
		return

	var spk_key : String = line.get("speaker", "narrator") as String
	var display : String = GameManager.SPEAKER_NAMES.get(spk_key, "") as String
	spk_name.text = display.to_upper() if display != "" else "— — —"
	var spk_color: Color = GameManager.CHAR_COLORS.get(spk_key, C_SPEAKER_TEXT) as Color
	spk_name.add_theme_color_override("font_color", spk_color)
	speaker_accent.color = spk_color.darkened(0.3)

	var is_narr: bool = spk_key == "narrator"
	dlg_text.add_theme_color_override("font_color", C_NARRATOR if is_narr else C_BODY_TEXT)

	if line.has("choices"):
		_has_choices = true
		_build_choices(line["choices"] as Array)

	_full_text    = line.get("text", "") as String
	_typed_so_far = ""
	_type_timer   = 0.0
	_typing       = true
	dlg_text.text = ""

func _build_choices(choices: Array) -> void:
	for child in choice_buttons.get_children():
		child.queue_free()
	choice_panel.visible = true

	for i in choices.size():
		var choice : Dictionary = choices[i] as Dictionary
		var btn    := Button.new()
		btn.text = "  ›  " + (choice["text"] as String)
		btn.flat = true
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_size_override("font_size", 14)
		btn.add_theme_color_override("font_color",         C_CHOICE_TXT)
		btn.add_theme_color_override("font_hover_color",   C_CHOICE_HVTXT)
		btn.add_theme_color_override("font_pressed_color", Color.WHITE)
		var sn := StyleBoxFlat.new()
		sn.bg_color = C_CHOICE_BG
		sn.border_color = Color(0.30, 0.22, 0.10)
		sn.set_border_width_all(1)
		sn.set_content_margin_all(8)
		var sh := StyleBoxFlat.new()
		sh.bg_color = C_CHOICE_HVR
		sh.border_color = C_PANEL_BORDER
		sh.set_border_width_all(1)
		sh.set_content_margin_all(8)
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
