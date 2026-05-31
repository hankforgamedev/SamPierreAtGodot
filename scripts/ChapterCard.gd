class_name ChapterCard
extends CanvasLayer
# Full-screen chapter title card. `await ChapterCard.show_card(parent, title).finished`
# to block until it dismisses. Title is split on " — " into a dim line + big line.

signal finished

var _title    : String = ""
var _duration : float  = 1.6

static func show_card(parent: Node, title: String, duration: float = 1.6) -> ChapterCard:
	var c := ChapterCard.new()
	c._title    = title
	c._duration = duration
	parent.add_child(c)
	return c

func _ready() -> void:
	layer = 90
	_build()
	SoundManager.play_sfx("riser")
	await get_tree().create_timer(_duration).timeout
	finished.emit()
	queue_free()

func _build() -> void:
	var bg := ColorRect.new()
	bg.color = GameTheme.C_BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.theme = GameTheme.build_scaled_theme(
		get_viewport().get_visible_rect().size.y / float(GameTheme.BASE_VIEWPORT_H))
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 24)
	center.add_child(vbox)

	var parts := _title.split(" — ", false, 1)
	var l1 := Label.new()
	l1.text = parts[0] if parts.size() > 0 else _title
	l1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l1.theme_type_variation = "DimLabel"
	vbox.add_child(l1)
	if parts.size() > 1:
		var l2 := Label.new()
		l2.text = parts[1]
		l2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l2.theme_type_variation = "TitleLabel"
		vbox.add_child(l2)
