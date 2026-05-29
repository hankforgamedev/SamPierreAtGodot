class_name GameOverlay
extends CanvasLayer

static func show_overlay(parent: Node, message: String = "") -> void:
	var overlay := GameOverlay.new()
	overlay._message = message
	parent.add_child(overlay)

var _message: String = ""

func _ready() -> void:
	layer = 100
	_build()

func _build() -> void:
	var bg := ColorRect.new()
	bg.color = Color(GameTheme.C_BG.r, GameTheme.C_BG.g, GameTheme.C_BG.b, 0.92)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.theme = GameTheme.build_scaled_theme(
		get_viewport().get_visible_rect().size.y / float(GameTheme.BASE_VIEWPORT_H))
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 48)
	center.add_child(vbox)

	if _message != "":
		var msg := Label.new()
		msg.text = _message
		msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		msg.theme_type_variation = "NarratorLabel"
		vbox.add_child(msg)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 64)
	vbox.add_child(btn_row)

	var retry := Button.new()
	retry.text = "重試"
	retry.pressed.connect(_on_retry)
	btn_row.add_child(retry)

	var quit := Button.new()
	quit.text = "去死吧"
	quit.pressed.connect(_on_quit)
	btn_row.add_child(quit)

	retry.grab_focus()

func _on_retry() -> void:
	SoundManager.play_sfx("riser")
	await get_tree().create_timer(0.5).timeout
	get_tree().reload_current_scene()

func _on_quit() -> void:
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")
