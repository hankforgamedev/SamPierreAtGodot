class_name AsciiLevelBase
extends Control

# ── Wall symbols (block movement) ─────────────────────────
const WALL_SYMS := ["＃", "Ｉ", "｜"]
const DOOR_SYMS := ["＞"]

# ── Glitch pools ──────────────────────────────────────────
const WALL_GLITCH  := ["ｌ", "１", "！", "ｉ", "｜", "；"]
const FLOOR_GLITCH := ["ｖ", "．", "，", "；", "－", "～"]
const JUNK_CHAOS   := [
	"＠", "！", "＄", "Ψ", "Ω", "Δ", "░", "▓", "×", "†",
	"¿", "Ж", "Ш", "ξ", "∂", "∑", "＊", "？", "＃", "～"
]

const BASE_MAP_FONT := GameTheme.BASE_MAP_FONT

# ── State ─────────────────────────────────────────────────
var _map_base      : Array      = []
var _glitch_overlay: Dictionary = {}  # Vector2i → String
var _player_pos    : Vector2i   = Vector2i(4, 4)
var _npcs          : Dictionary = {}  # Vector2i → {chapter_id, start_line, char_id, display, next_level?}
var stress_level   : float      = 0.0
var _glitch_timer  : float      = 0.0
var _in_dialogue   : bool       = false

# ── FX state ──────────────────────────────────────────────
var _shake_timer     : float  = 0.0
var _shake_intensity : float  = 0.0
var _base_map_pos    : Vector2 = Vector2.ZERO
var _glitch_spike_timer   : float = 0.0
var _glitch_spike_base    : float = 0.0
var _flash_rect      : ColorRect = null

# ── Movement state ────────────────────────────────────────
const MOVE_HOLD_DELAY  := 0.18   # seconds before repeat kicks in
const MOVE_REPEAT_RATE := 0.07   # seconds between repeat steps
const FRICTION_STEPS   := 0      # no slide after release — 1 press = 1 step
const FRICTION_RATE    := 0.14
const CHAR_ASPECT      := 1.00  # full-width CJK advance-width / point-size ratio

# ── Layout scale roots (font sizes come from GameTheme; these are pixel offsets) ──
const BASE_HUD_HEIGHT  := 28   # HUD label offset_top magnitude in scene
const STATUSLINE_ROWS  := 3    # height of status bar at bottom of map (in grid rows)
const BASE_AMB_TOP     := 32 + (STATUSLINE_ROWS * BASE_MAP_FONT)  # padding above statusline
const BASE_AMB_BOTTOM  := 8    # ambient label offset_bottom magnitude in scene
const BASE_AMB_LEFT    := BASE_MAP_FONT  # ambient label offset_left in scene
const BASE_PANEL_MARGIN := 28  # scene intro panel content margin
const BASE_PANEL_SEP   := 20   # scene intro VBoxContainer separation
const TYPEWRITER_SPEED := 0.035  # seconds per character

var _held_dir      : Vector2i = Vector2i.ZERO
var _move_phase    : int      = 0   # 0=idle 1=held 2=repeating 3=friction
var _move_timer    : float    = 0.0
var _friction_dir  : Vector2i = Vector2i.ZERO
var _friction_count: int      = 0
var _last_dialogue_chapter: String = ""

# ── NPC oscillation during dialogue ───────────────────────
var _dialogue_npc_pos : Vector2i = Vector2i(-1, -1)
var _npc_anim_timer   : float    = 0.0
var _npc_anim_offset  : int      = 0
var _npc_anim_phase   : int      = 0

# ── Ambient text state ────────────────────────────────────
var _talked_npcs   := {}
var _ambient_label: Node = null

# ── Scene intro panel state ───────────────────────────────
var _scene_panel_open: bool = false
var _scene_panel: Node = null
var _panel_text_label: Node = null
var _panel_typing:       bool   = false
var _panel_typed_count:  int    = 0
var _panel_type_timer:   float  = 0.0
var _panel_full_text:    String = ""

# ── Interactable objects ───────────────────────────────────
var _objects: Dictionary = {}
var _font_size: int = BASE_MAP_FONT

# ── Story text (populated by each level subclass before super._ready()) ──────
var _level_text: Dictionary = {}

@onready var map_display   : RichTextLabel = $MapDisplay
@onready var hud_label     : Label         = $HUD
@onready var world_dialogue                = $WorldUI

# ── Override in each level ────────────────────────────────
func _get_map_data()       -> Array      : return []
func _get_player_spawn()   -> Vector2i   : return Vector2i(4, 4)
func _get_npcs()           -> Dictionary : return {}
func _get_level_name()     -> String     : return ""
func _get_scene_intro()    -> String     : return ""
func _get_level_id()       -> String     : return ""
func _get_ambient_track()  -> String     : return ""
func _get_chapter_id()     -> String     : return ""  # scene's chapter — "" = no entry card

# [TODO] fix hardcoding & magic numbers 
func _compute_font_size() -> int:
	var vp   := get_viewport().get_visible_rect().size
	var rows := _map_base.size()
	if rows == 0:
		return BASE_MAP_FONT
	var cols := 0
	for row in _map_base:
		cols = max(cols, (row as String).length())
	if cols == 0:
		return BASE_MAP_FONT
	# 0.65 = WorldUI anchor_left; subtract offset_left(24) from each side
	var map_w := vp.x * 0.65 
	# subtract MapDisplay offset_top(24) + abs(offset_bottom(-40))
	var map_h := vp.y -64.0
	var sz_w  := int(map_w / (cols * CHAR_ASPECT))
	var sz_h  := int(map_h / rows)
	return clampi(mini(sz_w, sz_h), 14, 200)

# ── Lifecycle ─────────────────────────────────────────────
func _ready() -> void:
	_map_base   = _get_map_data()
	_player_pos = _get_player_spawn()
	_npcs       = _get_npcs()
	world_dialogue.dialogue_closed.connect(_on_dialogue_closed)
	world_dialogue.line_fx.connect(_on_line_fx)
	world_dialogue.visible = false
	_font_size = _compute_font_size()
	theme = GameTheme.build_scaled_theme(float(_font_size) / float(BASE_MAP_FONT))
	hud_label.theme_type_variation = "AmbientLabel"
	hud_label.offset_top = -float(BASE_HUD_HEIGHT * _font_size) / float(BASE_MAP_FONT)
	world_dialogue.apply_scale(_font_size)
	_setup_display()
	_draw_map()
	hud_label.text = _get_level_name()
	_base_map_pos  = map_display.position
	_setup_flash()
	_setup_ambient()
	_objects = ObjectData.OBJECTS.get(_get_level_id(), {})
	_setup_scene_panel()
	# Chapter title card on scene enter (one scene = one chapter), before intro panel.
	var chap_id := _get_chapter_id()
	if chap_id != "":
		var chap := DialogueData.get_chapter(chap_id)
		if not chap.is_empty():
			await ChapterCard.show_card(self, chap.get("title", "") as String).finished
	_show_panel_text(_get_scene_intro())
	SoundManager.play_ambient(_get_ambient_track())

func _setup_display() -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = GameTheme.C_BG_MAP
	map_display.add_theme_stylebox_override("normal", bg)
	map_display.bbcode_enabled = true
	map_display.scroll_active  = false
	map_display.fit_content    = false
	map_display.focus_mode     = Control.FOCUS_NONE
	map_display.mouse_filter   = Control.MOUSE_FILTER_IGNORE
	map_display.add_theme_font_override("normal_font", load("res://font/genyo-gothic/GenYoGothic2TW-R.otf"))
	# map grid font size set per-frame via [font_size=N] BBCode in _draw_map()

# ── Input ─────────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	var _is_lmb := event is InputEventMouseButton \
		and (event as InputEventMouseButton).pressed \
		and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT

	# Ctrl+WASD / Ctrl+arrows: dash to the next wall (DX for playtesting)
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo \
			and (event as InputEventKey).ctrl_pressed \
			and not _in_dialogue and not _scene_panel_open and not _panel_typing:
		var dash := _dash_dir(event as InputEventKey)
		if dash != Vector2i.ZERO:
			while _try_move(dash):
				pass
			_update_ambient()
			if is_inside_tree():
				get_viewport().set_input_as_handled()
			return

	if event.is_action_pressed("interact") or _is_lmb:
		if _panel_typing:
			_panel_typing = false
			if _panel_text_label != null:
				(_panel_text_label as Label).visible_characters = -1
			get_viewport().set_input_as_handled()
			return
		if _scene_panel_open:
			_close_scene_panel()
			get_viewport().set_input_as_handled()
			if not _in_dialogue:
				for dir in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
					if (_player_pos + dir) in _npcs:
						_try_interact()
						break
			return
		if _in_dialogue:
			return
		var near_npc := false
		for dir in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
			if (_player_pos + dir) in _npcs:
				near_npc = true
				break
		if near_npc:
			_try_interact()
		else:
			_try_interact_object()
		if not is_inside_tree():
			return
		get_viewport().set_input_as_handled()

# ── Movement ──────────────────────────────────────────────
func _dash_dir(k: InputEventKey) -> Vector2i:
	match k.physical_keycode:
		KEY_W, KEY_UP:    return Vector2i(0, -1)
		KEY_S, KEY_DOWN:  return Vector2i(0,  1)
		KEY_A, KEY_LEFT:  return Vector2i(-1, 0)
		KEY_D, KEY_RIGHT: return Vector2i(1,  0)
		_:                return Vector2i.ZERO

func _try_move(dir: Vector2i) -> bool:
	var target := _player_pos + dir
	if _is_walkable(target):
		_player_pos = target
		_draw_map()
		return true
	return false

func _is_walkable(pos: Vector2i) -> bool:
	if pos.y < 0 or pos.y >= _map_base.size():
		return false
	var row := _map_base[pos.y] as String
	if pos.x < 0 or pos.x >= row.length():
		return false
	if pos in _npcs:
		return false
	return not (_map_base[pos.y][pos.x] in WALL_SYMS)

# ── Interaction ───────────────────────────────────────────
func _try_interact() -> void:
	for dir in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
		var check: Vector2i = _player_pos + dir
		if not (check in _npcs):
			continue
		var npc := _npcs[check] as Dictionary
		if npc.has("next_level"):
			get_tree().change_scene_to_file(npc["next_level"] as String)
			return
		if npc.has("start_chapter"):
			_in_dialogue = true
			GameManager.start_chapter(npc["start_chapter"] as String)
			return
		_in_dialogue = true
		_dialogue_npc_pos = check
		_last_dialogue_chapter = npc.get("chapter_id", "") as String
		world_dialogue.open(
			_last_dialogue_chapter,
			npc.get("start_line", 0) as int
		)
		return

func _on_dialogue_closed() -> void:
	_in_dialogue = false
	_dialogue_npc_pos = Vector2i(-1, -1)
	_npc_anim_offset  = 0
	_npc_anim_phase   = 0
	var check_dirs := [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	for d in check_dirs:
		var chk: Vector2i = _player_pos + d
		if chk in _npcs:
			var npc_d: Dictionary = _npcs[chk]
			if npc_d.has("chapter_id"):
				_talked_npcs[chk] = true
				break
	_update_ambient()

func _on_player_moved() -> void:
	pass

# ── Ambient text ──────────────────────────────────────────
func _setup_ambient() -> void:
	var lbl    := Label.new()
	lbl.theme_type_variation = "AmbientLabel"
	lbl.anchor_left   = 0.0
	lbl.anchor_right  = 0.62
	lbl.anchor_top    = 1.0
	lbl.anchor_bottom = 1.0
	lbl.offset_top    = -float(BASE_AMB_TOP    * _font_size) / float(BASE_MAP_FONT)
	lbl.offset_bottom = -float(BASE_AMB_BOTTOM * _font_size) / float(BASE_MAP_FONT)
	lbl.offset_left   =  float(BASE_AMB_LEFT   * _font_size) / float(BASE_MAP_FONT)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.z_index = 50
	add_child(lbl)
	_ambient_label = lbl

# ── Scene intro panel ─────────────────────────────────────
func _setup_scene_panel() -> void:
	var intro := _get_scene_intro()
	if intro == "":
		return

	var panel := Panel.new()
	var style := StyleBoxFlat.new()
	style.bg_color = GameTheme.C_PANEL_BG
	style.border_color = GameTheme.C_PANEL_BORDER
	style.set_border_width_all(2)
	style.set_content_margin_all(float(BASE_PANEL_MARGIN * _font_size) / float(BASE_MAP_FONT))
	panel.add_theme_stylebox_override("panel", style)
	panel.anchor_left   = 0.15
	panel.anchor_right  = 0.85
	panel.anchor_top    = 0.18
	panel.anchor_bottom = 0.82
	panel.z_index = 150
	panel.visible = false
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", BASE_PANEL_SEP * _font_size / BASE_MAP_FONT)
	panel.add_child(vbox)

	var text_lbl := Label.new()
	text_lbl.text = intro
	text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(text_lbl)
	_panel_text_label = text_lbl

	var hint_lbl := Label.new()
	hint_lbl.text = "E / Space to interact"
	hint_lbl.theme_type_variation = "HintLabel"
	hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vbox.add_child(hint_lbl)

	_scene_panel = panel

func _show_panel_text(text: String) -> void:
	if text == "" or _panel_text_label == null:
		return
	var lbl := _panel_text_label as Label
	lbl.text = text
	lbl.visible_characters = 0
	_panel_full_text   = text
	_panel_typed_count = 0
	_panel_type_timer  = 0.0
	_panel_typing      = true
	_open_scene_panel()

func _open_scene_panel() -> void:
	if _scene_panel == null:
		return
	_scene_panel.visible = true
	_scene_panel_open = true

func _close_scene_panel() -> void:
	if _scene_panel == null:
		return
	_panel_typing = false
	_scene_panel.visible = false
	_scene_panel_open = false

func _tick_panel_typewriter(delta: float) -> void:
	_panel_type_timer += delta
	while _panel_type_timer >= TYPEWRITER_SPEED and _panel_typed_count < _panel_full_text.length():
		_panel_type_timer -= TYPEWRITER_SPEED
		_panel_typed_count += 1
		if _panel_text_label != null:
			(_panel_text_label as Label).visible_characters = _panel_typed_count
		SoundManager.play_type_click()
	if _panel_typed_count >= _panel_full_text.length():
		_panel_typing = false
		if _panel_text_label != null:
			(_panel_text_label as Label).visible_characters = -1


func _try_interact_object() -> bool:
	for dir in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
		var chk: Vector2i = _player_pos + dir
		if chk in _objects:
			var obj := _objects[chk] as Dictionary
			_show_panel_text(obj.get("text", ""))
			return true
	return false

func _get_nearby_npc() -> Vector2i:
	var search_dirs := [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	for d in search_dirs:
		var chk: Vector2i = _player_pos + d
		if chk in _npcs:
			return chk
	return Vector2i(-1, -1)

func _update_ambient() -> void:
	if _ambient_label == null:
		return
	var lbl := _ambient_label as Label
	if lbl == null:
		return
	var nearby := _get_nearby_npc()
	if nearby.x == -1:
		lbl.text = ""
		return
	var npc := _npcs[nearby] as Dictionary
	var key := "ambient_a"
	if _talked_npcs.has(nearby):
		key = "ambient_b"
	lbl.text = npc.get(key, "")

func _setup_flash() -> void:
	_flash_rect = ColorRect.new()
	_flash_rect.color = Color.TRANSPARENT
	_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_flash_rect.z_index = 100
	add_child(_flash_rect)

# ── FX triggers ───────────────────────────────────────────
func trigger_shake(intensity: float = 6.0, duration: float = 0.35) -> void:
	_shake_intensity = intensity
	_shake_timer     = duration

func trigger_flash(color: Color = Color.WHITE, duration: float = 0.25) -> void:
	if _flash_rect == null:
		return
	_flash_rect.color = Color(color.r, color.g, color.b, 0.0)
	var tw := create_tween()
	tw.tween_property(_flash_rect, "color:a", 0.85, duration * 0.3)
	tw.tween_property(_flash_rect, "color:a", 0.0,  duration * 0.7)

func trigger_glitch_spike(duration: float = 1.2) -> void:
	_glitch_spike_base  = stress_level
	_glitch_spike_timer = duration
	stress_level        = max(stress_level, 1.0)

func _on_line_fx(effects: Array) -> void:
	for fx in effects:
		match fx:
			"shake":       trigger_shake()
			"flash_white": trigger_flash(Color.WHITE)
			"flash_black": trigger_flash(Color.BLACK, 0.6)
			"glitch_spike": trigger_glitch_spike()

# ── Glitch ────────────────────────────────────────────────
func _process(delta: float) -> void:
	_tick_shake(delta)
	if _panel_typing:
		_tick_panel_typewriter(delta)
	if _in_dialogue:
		_tick_npc_anim(delta)
		return
	if _scene_panel_open:
		return
	_tick_movement(delta)
	_tick_glitch_spike(delta)
	_glitch_timer += delta
	var interval: float = 2.5 / max(1.0 + stress_level * 4.0, 0.1)
	if _glitch_timer >= interval:
		_glitch_timer = 0.0
		_apply_glitch()
		_draw_map()

func _tick_npc_anim(delta: float) -> void:
	if _dialogue_npc_pos.x == -1:
		return
	const CYCLE := [-1, 0, 1, 0]
	_npc_anim_timer += delta
	if _npc_anim_timer >= 0.4:
		_npc_anim_timer  = 0.0
		_npc_anim_phase  = (_npc_anim_phase + 1) % 4
		_npc_anim_offset = CYCLE[_npc_anim_phase]
		_draw_map()

func _try_move_dir(dir: Vector2i) -> bool:
	if dir.x != 0 and dir.y != 0:
		if _try_move(Vector2i(dir.x, 0)):
			return true
		return _try_move(Vector2i(0, dir.y))
	return _try_move(dir)

func _tick_movement(delta: float) -> void:
	var dir := Vector2i.ZERO
	if Input.is_action_pressed("move_left"):  dir.x -= 1
	if Input.is_action_pressed("move_right"): dir.x += 1
	if Input.is_action_pressed("move_up"):    dir.y -= 1
	if Input.is_action_pressed("move_down"):  dir.y += 1

	if dir != Vector2i.ZERO:
		_friction_dir   = dir
		_friction_count = FRICTION_STEPS
		if _held_dir != dir:
			_held_dir   = dir
			_move_timer = 0.0
			_move_phase = 1
			if _try_move_dir(dir):
				_draw_map()
				_update_ambient()
				_on_player_moved()
		else:
			_move_timer += delta
			match _move_phase:
				1:
					if _move_timer >= MOVE_HOLD_DELAY:
						_move_phase = 2
						_move_timer = 0.0
				2:
					if _move_timer >= MOVE_REPEAT_RATE:
						_move_timer = 0.0
						if _try_move_dir(dir):
							_draw_map()
							_update_ambient()
							_on_player_moved()
	else:
		if _held_dir != Vector2i.ZERO:
			_held_dir   = Vector2i.ZERO
			_move_phase = 3
			_move_timer = 0.0
		if _move_phase == 3:
			_move_timer += delta
			if _friction_count > 0 and _move_timer >= FRICTION_RATE:
				_move_timer      = 0.0
				_friction_count -= 1
				if _try_move_dir(_friction_dir):
					_draw_map()
					_update_ambient()
			elif _friction_count <= 0:
				_move_phase = 0

func _tick_shake(delta: float) -> void:
	if _shake_timer <= 0.0:
		map_display.position = _base_map_pos
		return
	_shake_timer -= delta
	var off := Vector2(
		randf_range(-_shake_intensity, _shake_intensity),
		randf_range(-_shake_intensity * 0.5, _shake_intensity * 0.5)
	)
	map_display.position = _base_map_pos + off

func _tick_glitch_spike(delta: float) -> void:
	if _glitch_spike_timer <= 0.0:
		return
	_glitch_spike_timer -= delta
	if _glitch_spike_timer <= 0.0:
		stress_level = _glitch_spike_base

func _apply_glitch() -> void:
	_glitch_overlay.clear()
	var count := int(stress_level * 10.0) + (randi() % 3)
	for _i in count:
		var y := randi() % _map_base.size()
		var row := _map_base[y] as String
		if row.is_empty():
			continue
		var x := randi() % row.length()
		var sym := row[x]
		if sym in ["＃", "Ｉ"]:
			_glitch_overlay[Vector2i(x, y)] = WALL_GLITCH[randi() % WALL_GLITCH.size()]
		elif sym == "％":
			_glitch_overlay[Vector2i(x, y)] = JUNK_CHAOS[randi() % JUNK_CHAOS.size()]
		elif sym == "．" and stress_level > 0.5:
			_glitch_overlay[Vector2i(x, y)] = FLOOR_GLITCH[randi() % FLOOR_GLITCH.size()]

# ── Rendering ─────────────────────────────────────────────
func _draw_map() -> void:
	var out := "[font_size=%d]" % _font_size
	for y in _map_base.size():
		var row := _map_base[y] as String
		for x in row.length():
			var pos := Vector2i(x, y)
			if pos == _player_pos:
				out += "[color=%s]＠[/color]" % GameTheme.C_PLAYER
			elif pos == _dialogue_npc_pos and _npc_anim_offset != 0:
				out += _sym_bbcode(row[x])
			elif _dialogue_npc_pos.x != -1 and _npc_anim_offset != 0 \
					and pos == _dialogue_npc_pos + Vector2i(_npc_anim_offset, 0) \
					and not (pos in _npcs):
				var npc  := _npcs[_dialogue_npc_pos] as Dictionary
				var col  := GameTheme.CHAR_HEX.get(npc.get("char_id", "narrator"), GameTheme.C_NPC_DEFAULT) as String
				var disp := npc.get("display", "?") as String
				out += "[color=%s]%s[/color]" % [col, disp]
			elif pos in _npcs:
				var npc  := _npcs[pos] as Dictionary
				var col  := GameTheme.CHAR_HEX.get(npc.get("char_id", "narrator"), GameTheme.C_NPC_DEFAULT) as String
				var disp := npc.get("display", "?") as String
				out += "[color=%s]%s[/color]" % [col, disp]
			elif pos in _objects:
				# subtle pulsed amber so interactable objects are discoverable
				out += "[pulse freq=0.8 ease=-2.0][color=%s]%s[/color][/pulse]" % [GameTheme.C_OBJECT_HINT, row[x]]
			elif pos in _glitch_overlay:
				out += "[color=%s]%s[/color]" % [GameTheme.C_GLITCH, _glitch_overlay[pos]]
			else:
				out += _sym_bbcode(row[x])
		out += "\n"
	out += "[/font_size]"
	map_display.text = out

func _sym_bbcode(sym: String) -> String:
	match sym:
		"＃", "Ｉ":
			return "[color=%s]%s[/color]" % [GameTheme.C_WALL, sym]
		"｜":
			return "[color=#AAAAAA]｜[/color]"
		"［":
			return "[color=#AAAAAA]［[/color]"
		"］":
			return "[color=#AAAAAA]］[/color]"
		"－", "＿":
			return "[color=#666666]%s[/color]" % sym
		"．", "，":
			return "[color=%s]%s[/color]" % [GameTheme.C_FLOOR, sym]
		"　":
			return "　"
		"％":
			return "[color=%s]％[/color]" % GameTheme.C_JUNK
		"＞":
			return "[color=%s]＞[/color]" % GameTheme.C_DOOR
		"～":
			return "[color=#1A2A3A]～[/color]"
		"？":
			return "[color=#1E1E1E]？[/color]"
		_:
			return "[color=#555555]%s[/color]" % sym
