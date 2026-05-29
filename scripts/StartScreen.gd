extends Control

func _ready() -> void:
	_apply_theme()
	($TitleBlock/StartButton as Button).pressed.connect(_on_start)
	($TitleBlock/QuitButton  as Button).pressed.connect(_on_quit)
	($TitleBlock/StartButton as Button).grab_focus()
	SoundManager.play_score("1017001")

func _apply_theme() -> void:
	theme = GameTheme.build_scaled_theme(get_viewport().get_visible_rect().size.y / float(GameTheme.BASE_VIEWPORT_H))

	var title_lbl : Label = $TitleBlock/GameTitle as Label
	title_lbl.theme_type_variation = "StartTitle"

	var tag_lbl : Label = $TitleBlock/Tagline as Label
	tag_lbl.theme_type_variation = "TagLabel"

	for btn_name: String in ["StartButton", "QuitButton"]:
		var btn : Button = $TitleBlock.get_node(btn_name) as Button
		btn.add_theme_color_override("font_color",         GameTheme.C_DIM)
		btn.add_theme_color_override("font_hover_color",   GameTheme.C_HOVER_RED)
		btn.add_theme_color_override("font_pressed_color", Color.WHITE)
		var style : StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = Color.TRANSPARENT
		btn.add_theme_stylebox_override("normal",  style)
		btn.add_theme_stylebox_override("hover",   style)
		btn.add_theme_stylebox_override("pressed", style)

func _on_start() -> void:
	get_tree().change_scene_to_file("res://scenes/Station.tscn")

func _on_quit() -> void:
	get_tree().quit()
