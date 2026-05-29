extends Control

const LEVELS = {
	"Station":    "res://scenes/Station.tscn",
	"Office":     "res://scenes/Office.tscn",
	"Street":     "res://scenes/Street.tscn",
	"Restaurant": "res://scenes/LaoxiaoRestaurant.tscn",
}

const CHAPTERS = ["ch1", "ch2", "ch3", "ch4", "ch5", "ch6", "ch7", "ch8", "epilogue"]

func _ready() -> void:
	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 10)
	add_child(vbox)

	var lbl_levels := Label.new()
	lbl_levels.text = "── Levels ──"
	vbox.add_child(lbl_levels)

	var row_levels := HBoxContainer.new()
	row_levels.add_theme_constant_override("separation", 6)
	vbox.add_child(row_levels)
	for level_name: String in LEVELS:
		var btn := Button.new()
		btn.text = level_name
		var path: String = LEVELS[level_name]
		btn.pressed.connect(func() -> void: GameManager.go_to_level(path))
		row_levels.add_child(btn)

	var lbl_chapters := Label.new()
	lbl_chapters.text = "── Chapters ──"
	vbox.add_child(lbl_chapters)

	var row_chapters := HBoxContainer.new()
	row_chapters.add_theme_constant_override("separation", 6)
	vbox.add_child(row_chapters)
	for ch_id: String in CHAPTERS:
		var btn := Button.new()
		btn.text = ch_id
		btn.pressed.connect(func() -> void: GameManager.start_chapter(ch_id))
		row_chapters.add_child(btn)

	var btn_full := Button.new()
	btn_full.text = "Full Playthrough"
	btn_full.pressed.connect(func() -> void: GameManager.go_to_level("res://scenes/StartScreen.tscn"))
	vbox.add_child(btn_full)
