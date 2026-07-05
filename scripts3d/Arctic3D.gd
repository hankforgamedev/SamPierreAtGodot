extends Node

## Arctic Eggs 風格 3D 原型 — 主場景
## 3D 世界在 scenes3d/Restaurant.tscn（編輯器裡直接編輯；重生成用 tools/build_restaurant.gd）
## 這裡只負責：低解析度 viewport + dither shader、玩家生成、全解析度 UI 與對話
##   SubViewportContainer(dither shader) > SubViewport(320x180) > Restaurant.tscn + FPPlayer
##   CanvasLayer(全解析度) > 準星 / 互動提示 / 對話框

const VIEW_SHRINK := 6  # 1920/6 = 320x180

# Dark Earth 調色板（與 2D 版 UI 一致）
const COL_PANEL_BG := Color(0.10, 0.078, 0.060)
const COL_PANEL_BORDER := Color(0.50, 0.36, 0.14)
const COL_SPEAKER := Color(0.96, 0.80, 0.38)
const COL_BODY := Color(0.88, 0.84, 0.74)

var _player: FPPlayer
var _prompt: Label
var _dialogue_box: PanelContainer
var _speaker_label: Label
var _text_label: Label
var _lines: Array = []
var _line_idx := 0
var _typer: Tween


func _ready() -> void:
	_build_viewport()
	_build_world()
	_build_ui()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_player.rotate_look(event.relative)
	elif event.is_action_pressed("interact"):
		if _dialogue_box.visible:
			_advance_dialogue()
		else:
			var target := _player.current_target()
			if target:
				_open_dialogue(target)
	elif event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(_delta: float) -> void:
	if _dialogue_box.visible:
		_prompt.visible = false
		return
	var target := _player.current_target()
	_prompt.visible = target != null
	if target:
		_prompt.text = "[E] 和%s說話" % target.get_meta("display_name", "？")


# ---------- 低解析度 viewport + shader ----------

func _build_viewport() -> void:
	var container := SubViewportContainer.new()
	container.name = "ViewContainer"
	container.stretch = true
	container.stretch_shrink = VIEW_SHRINK
	container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	container.set_anchors_preset(Control.PRESET_FULL_RECT)

	var mat := ShaderMaterial.new()
	mat.shader = load("res://shaders/psx_dither.gdshader")
	container.material = mat
	add_child(container)

	var vp := SubViewport.new()
	vp.name = "World3D"
	container.add_child(vp)


func _world() -> SubViewport:
	return get_node("ViewContainer/World3D") as SubViewport


# ---------- 3D 世界 ----------

func _build_world() -> void:
	var vp := _world()
	var restaurant: Node3D = load("res://scenes3d/Restaurant.tscn").instantiate()
	vp.add_child(restaurant)

	_player = FPPlayer.new()
	var spawn := restaurant.get_node_or_null("PlayerSpawn")
	_player.position = spawn.position if spawn else Vector3(0, 0.1, 3.5)
	restaurant.add_child(_player)


# ---------- 全解析度 UI ----------

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.name = "UI"
	add_child(layer)

	var font := SystemFont.new()
	font.font_names = ["Consolas", "Courier New"]

	# 準星
	var crosshair := Label.new()
	crosshair.text = "·"
	crosshair.add_theme_font_override("font", font)
	crosshair.add_theme_font_size_override("font_size", 32)
	crosshair.add_theme_color_override("font_color", Color(0.9, 0.9, 0.85, 0.7))
	crosshair.set_anchors_preset(Control.PRESET_CENTER)
	layer.add_child(crosshair)

	# 互動提示
	_prompt = Label.new()
	_prompt.visible = false
	_prompt.add_theme_font_override("font", font)
	_prompt.add_theme_font_size_override("font_size", 24)
	_prompt.add_theme_color_override("font_color", COL_SPEAKER)
	_prompt.set_anchors_preset(Control.PRESET_CENTER)
	_prompt.position += Vector2(0, 60)
	layer.add_child(_prompt)

	# 對話（底部置中，無底框 — 純文字浮在畫面上）
	_dialogue_box = PanelContainer.new()
	_dialogue_box.visible = false
	_dialogue_box.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	_dialogue_box.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_dialogue_box.anchor_left = 0.2
	_dialogue_box.anchor_right = 0.8
	_dialogue_box.offset_left = 0
	_dialogue_box.offset_right = 0
	_dialogue_box.offset_top = -180
	_dialogue_box.offset_bottom = -40
	layer.add_child(_dialogue_box)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	_dialogue_box.add_child(vbox)

	_speaker_label = Label.new()
	_speaker_label.add_theme_font_override("font", font)
	_speaker_label.add_theme_font_size_override("font_size", 22)
	_speaker_label.add_theme_color_override("font_color", COL_SPEAKER)
	_speaker_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_speaker_label.add_theme_constant_override("outline_size", 6)
	vbox.add_child(_speaker_label)

	_text_label = Label.new()
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.add_theme_font_override("font", font)
	_text_label.add_theme_font_size_override("font_size", 26)
	_text_label.add_theme_color_override("font_color", COL_BODY)
	_text_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_text_label.add_theme_constant_override("outline_size", 6)
	vbox.add_child(_text_label)


# ---------- 對話 ----------

func _open_dialogue(target: Node) -> void:
	_lines = target.get_meta("dialog_lines", [])
	if _lines.is_empty():
		return
	_line_idx = 0
	_player.input_enabled = false
	_dialogue_box.visible = true
	_show_line()


func _advance_dialogue() -> void:
	# 打字中先跳到整句，再按一次才前進
	if _typer and _typer.is_running():
		_typer.kill()
		_text_label.visible_ratio = 1.0
		return
	_line_idx += 1
	if _line_idx >= _lines.size():
		_close_dialogue()
	else:
		_show_line()


func _show_line() -> void:
	var line: Dictionary = _lines[_line_idx]
	_speaker_label.text = line.get("speaker", "")
	_text_label.text = line.get("text", "")
	_text_label.visible_ratio = 0.0
	if _typer:
		_typer.kill()
	_typer = create_tween()
	_typer.tween_property(_text_label, "visible_ratio", 1.0,
		line.get("text", "").length() * 0.03)


func _close_dialogue() -> void:
	_dialogue_box.visible = false
	_player.input_enabled = true
