extends Node

## 3D 世界主場景（宿主）：低解析度 viewport + dither shader、關卡載入、HUD、輸入路由
## 關卡 = scenes3d/*.tscn（純場景資料，無腳本；編輯器直接編輯）
## 互動 metadata 慣例（見 tools/level_builder_lib.gd）：
##   NPC：meta chapter_id / start_line / char_id → 開對話
##   門 ：meta next_level / display_name → 換關卡

const START_LEVEL := "res://scenes3d/HuZhaiCheng.tscn"
const VIEW_SHRINK := 6  # 1920/6 = 320x180

var _player: FPPlayer
var _level: Node3D
var _dialogue: DialogueBox3D
var _prompt: Label


func _ready() -> void:
	_build_viewport()
	_build_hud()
	_load_level(START_LEVEL)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_player.rotate_look(event.relative)
	elif event.is_action_pressed("interact"):
		if _dialogue.is_open():
			_dialogue.advance()
		else:
			_try_interact()
	elif event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(_delta: float) -> void:
	if _dialogue.is_open():
		_prompt.visible = false
		return
	var target := _player.current_target()
	_prompt.visible = target != null
	if target:
		_prompt.text = _prompt_text(target)


# ---------- 互動 ----------

func _try_interact() -> void:
	var target := _player.current_target()
	if target == null:
		return
	if target.has_meta("chapter_id"):
		_player.input_enabled = false
		_dialogue.open(target.get_meta("chapter_id") as String,
			target.get_meta("start_line", 0) as int)
	elif target.has_meta("next_level"):
		_load_level(target.get_meta("next_level") as String)


func _prompt_text(target: Node) -> String:
	if target.has_meta("chapter_id"):
		var display: String = GameManager.SPEAKER_NAMES.get(
			target.get_meta("char_id", "") as String, "？") as String
		return "[E] 和%s說話" % display
	if target.has_meta("next_level"):
		return "[E] 前往%s" % (target.get_meta("display_name", "") as String)
	return "[E]"


func _on_dialogue_closed() -> void:
	_player.input_enabled = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_choices_visible(active: bool) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if active else Input.MOUSE_MODE_CAPTURED


# ---------- 關卡載入 ----------

func _load_level(path: String) -> void:
	if _level:
		_level.queue_free()  # 玩家掛在關卡下，一併釋放
	_level = (load(path) as PackedScene).instantiate() as Node3D
	_world().add_child(_level)

	_player = FPPlayer.new()
	var spawn := _level.get_node_or_null("PlayerSpawn") as Node3D
	_player.position = spawn.position if spawn else Vector3(0, 0.1, 0)
	_level.add_child(_player)


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


# ---------- 全解析度 HUD ----------

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "UI"
	add_child(layer)

	var font := SystemFont.new()
	font.font_names = ["Consolas", "Courier New"]

	var crosshair := Label.new()
	crosshair.text = "·"
	crosshair.add_theme_font_override("font", font)
	crosshair.add_theme_font_size_override("font_size", 32)
	crosshair.add_theme_color_override("font_color", Color(0.9, 0.9, 0.85, 0.7))
	crosshair.set_anchors_preset(Control.PRESET_CENTER)
	layer.add_child(crosshair)

	_prompt = Label.new()
	_prompt.visible = false
	_prompt.add_theme_font_override("font", font)
	_prompt.add_theme_font_size_override("font_size", 24)
	_prompt.add_theme_color_override("font_color", Color(0.96, 0.80, 0.38))
	_prompt.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_prompt.add_theme_constant_override("outline_size", 6)
	_prompt.set_anchors_preset(Control.PRESET_CENTER)
	_prompt.position += Vector2(0, 60)
	layer.add_child(_prompt)

	_dialogue = DialogueBox3D.new()
	_dialogue.closed.connect(_on_dialogue_closed)
	_dialogue.choices_visible_changed.connect(_on_choices_visible)
	layer.add_child(_dialogue)
