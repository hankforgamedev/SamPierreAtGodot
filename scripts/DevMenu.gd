extends Control

const LEVELS = {
	"Station":    "res://scenes/Station.tscn",
	"Office":     "res://scenes/Office.tscn",
	"Street":     "res://scenes/Street.tscn",
	"Restaurant": "res://scenes/LaoxiaoRestaurant.tscn",
	"SubwayCar":  "res://scenes/SubwayCar.tscn",
}

const CHAPTERS = ["ch1", "ch2", "ch3", "ch4", "ch5", "ch6", "ch7", "ch8", "epilogue"]

func _ready() -> void:
	theme = GameTheme.build_scaled_theme(get_viewport().get_visible_rect().size.y / float(GameTheme.BASE_VIEWPORT_H))

	var bg := ColorRect.new()
	bg.color = GameTheme.C_BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		margin.add_theme_constant_override(side, 64)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "SAM PIERRE — DEV"
	title.theme_type_variation = "DimLabel"
	vbox.add_child(title)

	var first_btn: Button = null
	vbox.add_child(_section_label("── Levels ──"))
	var row_levels := _button_row()
	vbox.add_child(row_levels)
	for level_name: String in LEVELS:
		var path: String = LEVELS[level_name]
		var btn := _make_button(level_name, func() -> void: GameManager.go_to_level(path))
		row_levels.add_child(btn)
		if first_btn == null:
			first_btn = btn

	vbox.add_child(_section_label("── Chapters ──"))
	var row_chapters := _button_row()
	vbox.add_child(row_chapters)
	for ch_id: String in CHAPTERS:
		row_chapters.add_child(_make_button(ch_id, func() -> void: GameManager.start_chapter(ch_id)))

	var row_full := _button_row()
	vbox.add_child(row_full)
	row_full.add_child(_make_button("Full Playthrough", func() -> void: GameManager.go_to_level("res://scenes/StartScreen.tscn")))

	if first_btn != null:
		first_btn.grab_focus()  # keyboard nav: arrows move between buttons, Space/Enter activates

func _section_label(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.theme_type_variation = "DimLabel"
	return lbl

func _button_row() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	return row  # buttons stay content-width (HBox doesn't stretch children)

func _make_button(label: String, on_press: Callable) -> Button:
	var btn := Button.new()
	btn.text = "  %s  " % label  # breathing room around label
	btn.pressed.connect(on_press)
	return btn
