extends Control

func _ready() -> void:
	_apply_theme()
	($TitleBlock/StartButton as Button).pressed.connect(_on_start)
	($TitleBlock/QuitButton  as Button).pressed.connect(_on_quit)

func _apply_theme() -> void:
	var title_lbl : Label = $TitleBlock/GameTitle as Label
	title_lbl.add_theme_color_override("font_color", GameTheme.C_TITLE_TEXT)
	title_lbl.add_theme_font_size_override("font_size", GameTheme.BASE_SS_TITLE)

	var tag_lbl : Label = $TitleBlock/Tagline as Label
	tag_lbl.add_theme_color_override("font_color", GameTheme.C_TAG_TEXT)
	tag_lbl.add_theme_font_size_override("font_size", GameTheme.BASE_SS_TAGLINE)

	for btn_name: String in ["StartButton", "QuitButton"]:
		var btn : Button = $TitleBlock.get_node(btn_name) as Button
		btn.add_theme_color_override("font_color",         GameTheme.C_DIM)
		btn.add_theme_color_override("font_hover_color",   GameTheme.C_HOVER_RED)
		btn.add_theme_color_override("font_pressed_color", Color.WHITE)
		btn.add_theme_font_size_override("font_size", GameTheme.BASE_SS_BTN)
		var style : StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = Color.TRANSPARENT
		btn.add_theme_stylebox_override("normal",  style)
		btn.add_theme_stylebox_override("hover",   style)
		btn.add_theme_stylebox_override("pressed", style)

func _on_start() -> void:
	get_tree().change_scene_to_file("res://scenes/Station.tscn")

func _on_quit() -> void:
	get_tree().quit()
