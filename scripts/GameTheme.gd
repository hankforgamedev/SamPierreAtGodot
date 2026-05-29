class_name GameTheme

# ── Custom fonts (loaded once, cached) ───────────────────────────────────────
static var _font_sans:       FontFile = null
static var _font_sans_heavy: FontFile = null
static var _font_serif:      FontFile = null

static func _ensure_fonts() -> void:
	if _font_sans != null:
		return
	_font_sans       = load("res://font/genyo-gothic/GenYoGothic2TW-R.otf")
	_font_sans_heavy = load("res://font/genyo-gothic/GenYoGothic2TW-H.otf")
	_font_serif      = load("res://font/genyo-min/GenYoMin2TW-R.otf")

# ── Font sizes (edit here — these are the only knobs) ────────────────────────
const FONT_BODY    := 30   # dialogue body, narration
const FONT_SPEAKER := 24   # speaker name
const FONT_DIM     := 30   # hints, buttons, secondary text
const FONT_TITLE   := 64   # chapter card title
const FONT_AMBIENT := 20   # ASCII world HUD / NPC hint
const FONT_BIG     := 96   # start screen title
const FONT_STAMP   := 64   # civil servant approval/rejection stamp

# ── Design roots ─────────────────────────────────────────────────────────────
const BASE_MAP_FONT   := 28    # map grid font at design resolution
const BASE_VIEWPORT_H := 1080  # full-screen design viewport height

static func build_scaled_theme(scale: float) -> Theme:
	_ensure_fonts()
	var t := Theme.new()
	if _font_sans != null:
		t.set_font("font",        "Label",         _font_sans)
		t.set_font("font",        "Button",        _font_sans)
	if _font_serif != null:
		t.set_font("normal_font", "RichTextLabel", _font_serif)
	t.set_font_size("font_size",        "Label",        maxi(int(FONT_BODY    * scale), FONT_BODY))
	t.set_color(    "font_color",       "Label",        C_BODY_TEXT)
	t.set_font_size("normal_font_size", "RichTextLabel",maxi(int(FONT_BODY    * scale), FONT_BODY))
	t.set_font_size("font_size",        "Button",       maxi(int(FONT_DIM     * scale), FONT_DIM))
	t.set_color(    "font_color",       "Button",       C_CHOICE_TXT)
	t.set_color(    "font_hover_color", "Button",       C_CHOICE_HVTXT)
	t.set_color(    "font_pressed_color","Button",      Color.WHITE)
	_var(t, "SpeakerLabel",  "Label", maxi(int(FONT_SPEAKER * scale), FONT_SPEAKER), C_SPEAKER_TEXT)
	_var(t, "HintLabel",     "Label", maxi(int(FONT_DIM     * scale), FONT_DIM),     C_HINT_TEXT)
	_var(t, "DimLabel",      "Label", maxi(int(FONT_DIM     * scale), FONT_DIM),     C_DIM)
	_var(t, "TitleLabel",    "Label", maxi(int(FONT_TITLE   * scale), FONT_TITLE),   C_BODY_TEXT)
	_var(t, "AmbientLabel",  "Label", maxi(int(FONT_AMBIENT * scale), FONT_AMBIENT), C_AMBIENT_TEXT)
	_var(t, "NarratorLabel", "Label", maxi(int(FONT_BODY    * scale), FONT_BODY),    C_NARRATOR)
	_var(t, "StartTitle",    "Label", maxi(int(FONT_BIG     * scale), FONT_BIG),     C_TITLE_TEXT)
	_var(t, "TagLabel",      "Label", maxi(int(FONT_DIM     * scale), FONT_DIM),     C_TAG_TEXT)
	# Apply heavy sans to display/title variants
	if _font_sans_heavy != null:
		t.set_font("font", "TitleLabel", _font_sans_heavy)
		t.set_font("font", "StartTitle", _font_sans_heavy)
	return t

static func _var(t: Theme, name: String, base: String, size: int, color: Color) -> void:
	t.set_type_variation(name, base)
	t.set_font_size("font_size", name, size)
	t.set_color("font_color", name, color)

# ── Typewriter speeds (seconds per character) ────────────────────────────────
const SPEED_FAST   := 0.020
const SPEED_NORMAL := 0.040
const SPEED_SLOW   := 0.060

# ── Dark Earth Palette ───────────────────────────────────────────────────────
const C_BG           := Color(0.062, 0.048, 0.038)   # deepest bg (minigame, screens)
const C_BG_MAP       := Color(0.08,  0.09,  0.06)    # ASCII map bg — green tint intentional
const C_PANEL_BG     := Color(0.10,  0.078, 0.060)   # panel fill
const C_PANEL_BORDER := Color(0.50,  0.36,  0.14)    # panel border
const C_HEADER_BG    := Color(0.06,  0.05,  0.04)    # speaker header strip
const C_CHAR_BORDER  := Color(0.32,  0.24,  0.10)    # portrait border (GameScene)
const C_BODY_TEXT    := Color(0.88,  0.84,  0.74)    # body / dialogue text
const C_SPEAKER_TEXT := Color(0.96,  0.80,  0.38)    # speaker name amber
const C_NARRATOR     := Color(0.62,  0.58,  0.48)    # narrator text
const C_HINT_TEXT    := Color(0.52,  0.48,  0.38)    # "E / Space to interact"
const C_AMBIENT_TEXT := Color(0.68,  0.62,  0.50)    # ambient label
const C_DIM          := Color(0.50,  0.42,  0.30)    # secondary / dim UI text
const C_INNER        := Color(0.50, 0.48, 0.42, 0.65)  # inner monologue: muted, lower opacity
const C_ICON_DIM     := Color(0.25,  0.25,  0.25, 0.40)  # portrait icon inactive
const C_STAMP_BORDER := Color(0.60,  0.08,  0.05)    # red stamp border
const C_RED          := Color(0.85,  0.25,  0.20)    # reject / danger
const C_GREEN        := Color(0.30,  0.72,  0.30)    # approve / success
const C_TITLE_TEXT   := Color(0.92,  0.86,  0.72)    # start screen title
const C_TAG_TEXT     := Color(0.52,  0.46,  0.34)    # start screen tagline
const C_HOVER_RED    := Color(0.68,  0.10,  0.06)    # start screen button hover

# ── Choice buttons ───────────────────────────────────────────────────────────
const C_CHOICE_BG         := Color(0.14, 0.12, 0.09)
const C_CHOICE_HVR        := Color(0.22, 0.18, 0.12)
const C_CHOICE_TXT        := Color(0.88, 0.84, 0.74)
const C_CHOICE_HVTXT      := Color(1.00, 0.96, 0.84)
const C_CHOICE_BORDER     := Color(0.30, 0.22, 0.10)
const C_CHOICE_BORDER_HVR := Color(0.35, 0.30, 0.22)

# ── ASCII map colors (hex strings for BBCode tags) ───────────────────────────
const C_WALL        := "#8A8270"
const C_FLOOR       := "#141610"
const C_JUNK        := "#4A3A1A"
const C_DOOR        := "#CC8833"
const C_PLAYER      := "#C8B890"
const C_GLITCH      := "#FF1111"
const C_NPC_DEFAULT := "#888888"
const C_TRAIN       := "#ffbf00"

# ── Character colors ─────────────────────────────────────────────────────────
# CHAR_HEX  — BBCode map rendering (hex strings)
# CHAR_COLOR — UI theme overrides via add_theme_color_override (Color objects)
# Add new characters to BOTH dicts and keep values in sync.
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
	"inner":    "#8C94B8",
}

const CHAR_COLOR := {
	"sam":      Color(0.85, 0.85, 0.85),
	"rat":      Color(0.4,  0.8,  0.4),
	"lee":      Color(0.9,  0.75, 0.2),
	"rachel":   Color(0.5,  0.7,  0.95),
	"sarah":    Color(0.8,  0.5,  0.85),
	"bill":     Color(0.9,  0.5,  0.2),
	"moujia":   Color(0.9,  0.3,  0.3),
	"david":    Color(0.5,  0.7,  0.8),
	"narrator": Color(0.5,  0.5,  0.5),
	"inner":    Color(0.55, 0.58, 0.72),
}
