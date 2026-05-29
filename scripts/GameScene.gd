extends Control

# ── State ──────────────────────────────────────────────────────
var chapter        : Dictionary = {}
var lines          : Array      = []
var current_index  : int        = 0
var showing_card   : bool       = true
var can_advance    : bool       = false
var typing         : bool       = false
var has_choices    : bool       = false
var full_text      : String     = ""
var typed_so_far   : String     = ""
var type_timer     : float      = 0.0

# ── Node refs ─────────────────────────────────────────────────
@onready var base_color      : ColorRect    = $BG/Base
@onready var sky_strip       : ColorRect    = $BG/SkyStrip
@onready var chapter_lbl     : Label        = $ChapterTitle
@onready var left_panel      : Panel        = $MainLayout/LeftCharPanel
@onready var left_icon       : Label        = $MainLayout/LeftCharPanel/LeftInner/LeftCharIcon
@onready var left_name       : Label        = $MainLayout/LeftCharPanel/LeftInner/LeftCharName
@onready var dlg_panel       : Panel        = $MainLayout/CenterCol/DialoguePanel
@onready var speaker_accent  : ColorRect    = $MainLayout/CenterCol/DialoguePanel/DlgInner/SpeakerBar/SpeakerAccent
@onready var spk_name        : Label        = $MainLayout/CenterCol/DialoguePanel/DlgInner/SpeakerBar/SpeakerName
@onready var dlg_text        : Label        = $MainLayout/CenterCol/DialoguePanel/DlgInner/DialogueText
@onready var choice_panel    : VBoxContainer = $MainLayout/CenterCol/ChoicePanel
@onready var choice_title    : Label        = $MainLayout/CenterCol/ChoicePanel/ChoiceTitle
@onready var choice_buttons  : VBoxContainer = $MainLayout/CenterCol/ChoicePanel/ChoiceButtons
@onready var right_panel     : Panel        = $MainLayout/RightCharPanel
@onready var right_icon      : Label        = $MainLayout/RightCharPanel/RightInner/RightCharIcon
@onready var right_name      : Label        = $MainLayout/RightCharPanel/RightInner/RightCharName
@onready var progress_lbl    : Label        = $BottomBar/ProgressLabel
@onready var next_hint       : Label        = $BottomBar/NextHint
@onready var card            : ColorRect    = $ChapterCard
@onready var card_line1      : Label        = $ChapterCard/CardInner/CardLine1
@onready var card_accent     : ColorRect    = $ChapterCard/CardInner/CardAccent
@onready var card_line2      : Label        = $ChapterCard/CardInner/CardLine2

# ── Ready ──────────────────────────────────────────────────────
func _ready() -> void:
	chapter = DialogueData.get_chapter(GameManager.current_chapter_id)
	if chapter.is_empty():
		return
	lines = chapter["lines"] as Array
	_apply_theme()
	_setup_characters()
	if GameManager.resume_line > 0:
		card.visible  = false
		showing_card  = false
		can_advance   = true
		var start := GameManager.resume_line
		GameManager.resume_line = 0
		_show_line(start)
	else:
		_show_chapter_card()

# ── Theme ─────────────────────────────────────────────────────
func _apply_theme() -> void:
	var mood : Color = chapter.get("bg_color", GameTheme.C_BG) as Color
	base_color.color = mood.darkened(0.08)
	sky_strip.color  = mood.lightened(0.05)

	theme = GameTheme.build_scaled_theme(get_viewport().get_visible_rect().size.y / float(GameTheme.BASE_VIEWPORT_H))

	chapter_lbl.text = (chapter["title"] as String).to_upper()
	chapter_lbl.theme_type_variation = "DimLabel"

	dlg_panel.add_theme_stylebox_override("panel",  _panel_style(GameTheme.C_PANEL_BG, GameTheme.C_PANEL_BORDER, 2))
	left_panel.add_theme_stylebox_override("panel",  _panel_style(GameTheme.C_PANEL_BG, GameTheme.C_CHAR_BORDER,  1))
	right_panel.add_theme_stylebox_override("panel", _panel_style(GameTheme.C_PANEL_BG, GameTheme.C_CHAR_BORDER,  1))

	spk_name.theme_type_variation   = "SpeakerLabel"
	left_name.theme_type_variation  = "DimLabel"
	right_name.theme_type_variation = "DimLabel"
	choice_title.theme_type_variation = "DimLabel"
	next_hint.theme_type_variation    = "DimLabel"
	progress_lbl.theme_type_variation = "DimLabel"
	card_line1.theme_type_variation   = "DimLabel"
	card_line2.theme_type_variation   = "TitleLabel"
	card_accent.color = GameTheme.C_PANEL_BORDER

func _panel_style(bg: Color, border: Color, width: int) -> StyleBoxFlat:
	var s : StyleBoxFlat = StyleBoxFlat.new()
	s.bg_color    = bg
	s.border_color = border
	s.set_border_width_all(width)
	s.set_content_margin_all(0)
	return s

# ── Characters ────────────────────────────────────────────────
func _setup_characters() -> void:
	var lc : String = chapter.get("left_char",  "sam")      as String
	var rc : String = chapter.get("right_char", "narrator") as String

	left_icon.text  = GameManager.CHAR_LABELS.get(lc,  "[?]") as String
	left_name.text  = GameManager.SPEAKER_NAMES.get(lc, "")   as String
	right_icon.text = GameManager.CHAR_LABELS.get(rc,  "[?]") as String
	right_name.text = GameManager.SPEAKER_NAMES.get(rc, "")   as String

	left_icon.add_theme_color_override("font_color",
		GameTheme.CHAR_COLOR.get(lc, Color.WHITE) as Color)
	right_icon.add_theme_color_override("font_color",
		GameTheme.CHAR_COLOR.get(rc, Color.WHITE) as Color)

# ── Chapter card ──────────────────────────────────────────────
func _show_chapter_card() -> void:
	card.visible = true
	SoundManager.play_sfx("riser")
	var title  : String            = chapter["title"] as String
	var parts  : PackedStringArray = title.split(" — ", false, 1)
	card_line1.text = parts[0] if parts.size() > 0 else title
	card_line2.text = parts[1] if parts.size() > 1 else ""
	can_advance = false
	await get_tree().create_timer(2.2).timeout
	can_advance = true
	_advance()

# ── Input ─────────────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	var clicked  : bool = (event is InputEventMouseButton
		and (event as InputEventMouseButton).pressed
		and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT)
	var keyboard : bool = event.is_action_pressed("interact")
	if has_choices:
		if keyboard:
			for btn: Button in choice_buttons.get_children():
				if btn.has_focus():
					get_viewport().set_input_as_handled()
					_select_choice(btn.get_meta("goto") as int)
					return
		return
	if not can_advance:
		return
	if clicked or keyboard:
		if typing:
			_finish_typing()
		else:
			_advance()

# ── Typewriter ────────────────────────────────────────────────
func _process(delta: float) -> void:
	if not typing:
		return
	type_timer += delta
	while type_timer >= GameTheme.SPEED_NORMAL and typed_so_far.length() < full_text.length():
		typed_so_far  += full_text[typed_so_far.length()]
		type_timer    -= GameTheme.SPEED_NORMAL
		dlg_text.text  = typed_so_far
	if typed_so_far.length() >= full_text.length():
		typing        = false
		dlg_text.text = full_text
		if has_choices:
			choice_panel.visible = true
			next_hint.text = ""

func _finish_typing() -> void:
	typing        = false
	typed_so_far  = full_text
	dlg_text.text = full_text
	if has_choices:
		choice_panel.visible = true
		next_hint.text = ""

# ── Advance ───────────────────────────────────────────────────
func _advance() -> void:
	if showing_card:
		showing_card = false
		card.visible = false
		_show_line(0)
		return

	# Check for "next" override on current line
	var cur_line : Dictionary = lines[current_index] as Dictionary
	if cur_line.has("next"):
		current_index = cur_line["next"] as int
	else:
		current_index += 1

	if current_index >= lines.size():
		_go_next_chapter()
		return
	_show_line(current_index)

# ── Show line ─────────────────────────────────────────────────
func _show_line(index: int) -> void:
	current_index = index

	var line    : Dictionary = lines[index] as Dictionary
	if line.has("minigame"):
		GameManager.resume_line = index + 1
		get_tree().change_scene_to_file("res://scenes/CivilServantGame.tscn")
		return

	choice_panel.visible = false
	has_choices = false
	next_hint.text = "[ E / SPACE / CLICK ]"
	var spk_key : String     = line.get("speaker", "narrator") as String
	var active  : String     = line.get("active",  "none")     as String
	var lc      : String     = chapter.get("left_char",  "sam")      as String
	var rc      : String     = chapter.get("right_char", "narrator") as String

	# Speaker name
	var display : String = GameManager.SPEAKER_NAMES.get(spk_key, "") as String
	spk_name.text = display.to_upper() if display != "" else "— — —"
	var spk_color : Color = GameTheme.CHAR_COLOR.get(spk_key, GameTheme.C_SPEAKER_TEXT) as Color
	spk_name.add_theme_color_override("font_color", spk_color)
	speaker_accent.color = spk_color.darkened(0.3)

	# Portrait highlights
	var left_lit  : bool = (active == "left"  or active == lc)
	var right_lit : bool = (active == "right" or active == rc)
	var is_narr   : bool = (active == "none"  or spk_key == "narrator")

	left_icon.modulate  = Color.WHITE if (left_lit  and not is_narr) else GameTheme.C_ICON_DIM
	left_name.modulate  = Color.WHITE if (left_lit  and not is_narr) else GameTheme.C_ICON_DIM
	right_icon.modulate = Color.WHITE if (right_lit and not is_narr) else GameTheme.C_ICON_DIM
	right_name.modulate = Color.WHITE if (right_lit and not is_narr) else GameTheme.C_ICON_DIM

	dlg_text.theme_type_variation = "NarratorLabel" if is_narr else ""

	# Check for choices
	if line.has("choices"):
		has_choices = true
		_build_choices(line["choices"] as Array)

	# Typewriter
	full_text    = line.get("text", "") as String
	typed_so_far = ""
	type_timer   = 0.0
	typing       = true
	dlg_text.text = ""

	progress_lbl.text = "%d / %d" % [index + 1, lines.size()]

# ── Choices ───────────────────────────────────────────────────
func _build_choices(choices: Array) -> void:
	# Clear old buttons
	for child: Node in choice_buttons.get_children():
		child.queue_free()

	for i: int in choices.size():
		var choice : Dictionary = choices[i] as Dictionary
		var btn    : Button     = Button.new()
		btn.text = "  ›  " + (choice["text"] as String)
		btn.flat = true
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT

		var style_n : StyleBoxFlat = StyleBoxFlat.new()
		style_n.bg_color = GameTheme.C_CHOICE_BG
		style_n.border_color = GameTheme.C_CHOICE_BORDER
		style_n.set_border_width_all(1)
		style_n.set_content_margin_all(8)
		var style_h : StyleBoxFlat = StyleBoxFlat.new()
		style_h.bg_color = GameTheme.C_CHOICE_HVR
		style_h.border_color = GameTheme.C_PANEL_BORDER
		style_h.set_border_width_all(1)
		style_h.set_content_margin_all(8)
		btn.add_theme_stylebox_override("normal",  style_n)
		btn.add_theme_stylebox_override("hover",   style_h)
		btn.add_theme_stylebox_override("pressed", style_h)
		btn.add_theme_stylebox_override("focus",  style_h)

		var goto_index : int = choice["goto"] as int
		btn.set_meta("goto", goto_index)
		btn.pressed.connect(_on_choice(goto_index))
		choice_buttons.add_child(btn)
	if choice_buttons.get_child_count() > 0:
		(choice_buttons.get_child(0) as Button).grab_focus()

func _select_choice(goto_index: int) -> void:
	choice_panel.visible = false
	has_choices = false
	next_hint.text = "[ E / SPACE / CLICK ]"
	_show_line(goto_index)

func _on_choice(goto_index: int) -> Callable:
	return func() -> void: _select_choice(goto_index)

# ── Next chapter ──────────────────────────────────────────────
const LEVEL_CHAPTERS := {
	"ch3": "res://scenes/Office.tscn",
	"ch5": "res://scenes/LaoxiaoRestaurant.tscn",
}

func _go_next_chapter() -> void:
	var next_id : String = DialogueData.get_next_chapter_id(chapter["id"] as String)
	if next_id == "":
		get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")
	elif LEVEL_CHAPTERS.has(next_id):
		get_tree().change_scene_to_file(LEVEL_CHAPTERS[next_id])
	else:
		GameManager.current_chapter_id = next_id
		get_tree().reload_current_scene()
