extends Control

const C_AMBER    : Color = Color(0.68, 0.10, 0.06)
const C_DIM      : Color = Color(0.45, 0.38, 0.25)

func _ready() -> void:
	_apply_theme()
	($TitleBlock/StartButton as Button).pressed.connect(_on_start)
	($TitleBlock/QuitButton  as Button).pressed.connect(_on_quit)

func _apply_theme() -> void:
	var title_lbl : Label = $TitleBlock/GameTitle as Label
	title_lbl.add_theme_color_override("font_color", Color(0.92, 0.86, 0.72))
	title_lbl.add_theme_font_size_override("font_size", 64)

	var tag_lbl : Label = $TitleBlock/Tagline as Label
	tag_lbl.add_theme_color_override("font_color", Color(0.52, 0.46, 0.34))
	tag_lbl.add_theme_font_size_override("font_size", 14)

	for btn_name: String in ["StartButton", "QuitButton"]:
		var btn : Button = $TitleBlock.get_node(btn_name) as Button
		btn.add_theme_color_override("font_color",         C_DIM)
		btn.add_theme_color_override("font_hover_color",   C_AMBER)
		btn.add_theme_color_override("font_pressed_color", Color.WHITE)
		btn.add_theme_font_size_override("font_size", 18)
		var style : StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = Color(0, 0, 0, 0)
		btn.add_theme_stylebox_override("normal",  style)
		btn.add_theme_stylebox_override("hover",   style)
		btn.add_theme_stylebox_override("pressed", style)

func _on_start() -> void:
	get_tree().change_scene_to_file("res://scenes/Station.tscn")

func _on_quit() -> void:
	get_tree().quit()
