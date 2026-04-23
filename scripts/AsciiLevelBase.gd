extends Control
class_name AsciiLevelBase

# ── Wall symbols (block movement) ─────────────────────────
const WALL_SYMS := ["#", "I", "|"]

# ── Glitch pools ──────────────────────────────────────────
const WALL_GLITCH  := ["l", "1", "!", "i", "¦", "╎", ";"]
const FLOOR_GLITCH := ["v", "'", "`", "·", ";", ","]
const JUNK_CHAOS   := [
	"@", "!", "$", "Ψ", "Ω", "Δ", "░", "▓", "×", "†",
	"¿", "ß", "ñ", "‡", "¡", "Ж", "Ш", "ξ", "∂", "∑"
]

# ── Colors ────────────────────────────────────────────────
const C_WALL   := "#EEEEEE"
const C_FLOOR  := "#252525"
const C_JUNK   := "#4A3A1A"
const C_DOOR   := "#CC8833"
const C_PLAYER := "#DDCCAA"
const C_GLITCH := "#FF1111"
const C_NPC_DEFAULT := "#888888"

const CHAR_HEX := {
	"sam":      "#D9D9D9",
	"rat":      "#66CC66",
	"lee":      "#E6BF33",
	"rachel":   "#80B3F2",
	"sarah":    "#CC80D9",
	"bill":     "#E68033",
	"moujia":   "#E64D4D",
	"david":    "#80B3CC",
	"narrator": "#888888",
}

# ── State ─────────────────────────────────────────────────
var _map_base      : Array      = []
var _glitch_overlay: Dictionary = {}  # Vector2i → String
var _player_pos    : Vector2i   = Vector2i(4, 4)
var _npcs          : Dictionary = {}  # Vector2i → {chapter_id, start_line, char_id, display, next_level?}
var stress_level   : float      = 0.0
var _glitch_timer  : float      = 0.0
var _in_dialogue   : bool       = false

@onready var map_display   : RichTextLabel = $MapDisplay
@onready var hud_label     : Label         = $HUD
@onready var world_dialogue                = $WorldUI

# ── Override in each level ────────────────────────────────
func _get_map_data()     -> Array      : return []
func _get_player_spawn() -> Vector2i   : return Vector2i(4, 4)
func _get_npcs()         -> Dictionary : return {}
func _get_level_name()   -> String     : return ""

# ── Lifecycle ─────────────────────────────────────────────
func _ready() -> void:
	_map_base   = _get_map_data()
	_player_pos = _get_player_spawn()
	_npcs       = _get_npcs()
	world_dialogue.dialogue_closed.connect(_on_dialogue_closed)
	world_dialogue.visible = false
	_setup_display()
	_draw_map()
	hud_label.text = _get_level_name()

func _setup_display() -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0, 0, 0, 1)
	map_display.add_theme_stylebox_override("normal", bg)
	map_display.bbcode_enabled = true
	map_display.scroll_active  = false
	map_display.fit_content    = false
	map_display.focus_mode     = Control.FOCUS_NONE
	map_display.mouse_filter   = Control.MOUSE_FILTER_IGNORE
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Consolas", "Courier New", "Courier", "Monospace"])
	map_display.add_theme_font_override("normal_font", font)
	map_display.add_theme_font_size_override("normal_font_size", 28)

# ── Input ─────────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	if _in_dialogue:
		return
	if event.is_action_pressed("move_left"):
		if _try_move(Vector2i(-1, 0)):
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_right"):
		if _try_move(Vector2i(1, 0)):
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("jump"):
		if _try_move(Vector2i(0, -1)):
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_down"):
		if _try_move(Vector2i(0, 1)):
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact"):
		_try_interact()
		get_viewport().set_input_as_handled()

# ── Movement ──────────────────────────────────────────────
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
			GameManager.start_chapter(npc["start_chapter"] as String)
			return
		_in_dialogue = true
		world_dialogue.open(
			npc.get("chapter_id", "") as String,
			npc.get("start_line", 0)  as int
		)
		return

func _on_dialogue_closed() -> void:
	_in_dialogue = false

# ── Glitch ────────────────────────────────────────────────
func _process(delta: float) -> void:
	if _in_dialogue:
		return
	_glitch_timer += delta
	var interval: float = 2.5 / max(1.0 + stress_level * 4.0, 0.1)
	if _glitch_timer >= interval:
		_glitch_timer = 0.0
		_apply_glitch()
		_draw_map()

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
		if sym in ["#", "I"]:
			_glitch_overlay[Vector2i(x, y)] = WALL_GLITCH[randi() % WALL_GLITCH.size()]
		elif sym == "%":
			_glitch_overlay[Vector2i(x, y)] = JUNK_CHAOS[randi() % JUNK_CHAOS.size()]
		elif sym == "." and stress_level > 0.5:
			_glitch_overlay[Vector2i(x, y)] = FLOOR_GLITCH[randi() % FLOOR_GLITCH.size()]

# ── Rendering ─────────────────────────────────────────────
func _draw_map() -> void:
	var out := "[font_size=28]"
	for y in _map_base.size():
		var row := _map_base[y] as String
		for x in row.length():
			var pos := Vector2i(x, y)
			if pos == _player_pos:
				out += "[color=%s]@[/color]" % C_PLAYER
			elif pos in _npcs:
				var npc  := _npcs[pos] as Dictionary
				var col  := CHAR_HEX.get(npc.get("char_id", "narrator"), C_NPC_DEFAULT) as String
				var disp := npc.get("display", "?") as String
				out += "[color=%s]%s[/color]" % [col, disp]
			elif pos in _glitch_overlay:
				out += "[color=%s]%s[/color]" % [C_GLITCH, _glitch_overlay[pos]]
			else:
				out += _sym_bbcode(row[x])
		out += "\n"
	out += "[/font_size]"
	map_display.text = out

func _sym_bbcode(sym: String) -> String:
	match sym:
		"#", "I":
			return "[color=%s]%s[/color]" % [C_WALL, sym]
		"|":
			return "[color=#AAAAAA]|[/color]"
		"[":
			return "[color=#AAAAAA][lb][/color]"
		"]":
			return "[color=#AAAAAA][rb][/color]"
		"-", "_":
			return "[color=#666666]%s[/color]" % sym
		".", ",":
			return "[color=%s]%s[/color]" % [C_FLOOR, sym]
		" ":
			return " "
		"%":
			return "[color=%s]%%[/color]" % C_JUNK
		">":
			return "[color=%s]>[/color]" % C_DOOR
		"~":
			return "[color=#1A2A3A]~[/color]"
		"?":
			return "[color=#1E1E1E]?[/color]"
		_:
			return "[color=#555555]%s[/color]" % sym
