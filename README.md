# Sam Pierre

A Disco Elysium-style narrative game set in Huk-Zai City. ASCII text-art world exploration meets visual-novel dialogue.

**By Hank L. and Sam K.**

---

## Running the Game

Open in **Godot 4.6** and press **F5**, or run a specific scene with **F6**.

```
godot --path . scenes/StartScreen.tscn
```

No build step — GDScript is interpreted.

---

## Architecture

The game runs in two alternating modes that hand off to each other via `GameManager.start_chapter()` and `get_tree().change_scene_to_file()`.

### Mode 1 — ASCII World (exploration)

A grid-based Control scene. The player walks around an ASCII map, approaches NPCs and objects, and triggers dialogue.

```
Station.tscn  (root: Control / StationLevel)
├── MapDisplay       RichTextLabel   ← full-screen ASCII grid (BBCode rendered)
├── HUD              Label           ← level name, bottom-left
└── WorldUI          WorldDialogue   ← right 35% panel; hidden until dialogue opens
    └── RightPanel
        └── Margin → Inner (VBox)
            ├── SpeakerBar (HBox)
            │   ├── SpeakerAccent   ColorRect   ← coloured accent bar
            │   └── SpeakerName     Label
            ├── Divider             ColorRect
            ├── DialogueText        Label       ← typewriter target
            └── ChoicePanel (VBox)  [hidden]
                ├── ChoiceTitle     Label
                └── ChoiceButtons   VBox        ← buttons built at runtime
```

All four world scenes (Station, Office, Street, LaoxiaoRestaurant) share this identical structure. Their root node carries a level-specific script that extends `AsciiLevelBase`.

**Script inheritance:**

```
Control
└── AsciiLevelBase          scripts/AsciiLevelBase.gd
    ├── StationLevel        scripts/StationLevel.gd
    ├── OfficeLevel         scripts/OfficeLevel.gd
    ├── StreetLevel         scripts/StreetLevel.gd
    └── RestaurantLevel     scripts/RestaurantLevel.gd
```

Each subclass overrides four hooks and nothing else:

| Hook | Returns | Purpose |
|---|---|---|
| `_get_map_data()` | `Array[String]` | ASCII art rows |
| `_get_player_spawn()` | `Vector2i` | Starting grid cell |
| `_get_npcs()` | `Dictionary` | `Vector2i → NPC dict` |
| `_get_level_name()` | `String` | HUD text |
| `_get_scene_intro()` | `String` | Panel text shown on entry (optional) |
| `_get_level_id()` | `String` | Key into `ObjectData.OBJECTS` |

**NPC dict format** (value in `_get_npcs()` dictionary):

```gdscript
{
    "chapter_id":  "ch1",     # opens WorldDialogue on interact
    "start_line":  0,
    "char_id":     "rat",     # key into GameManager.CHAR_COLORS / SPEAKER_NAMES
    "display":     "?",       # character shown on map
    "ambient_a":   "...",     # hint text before talking
    "ambient_b":   "...",     # hint text after talking
    # OR:
    "next_level":  "res://scenes/Street.tscn",   # door — changes scene
    # OR:
    "start_chapter": "ch2",  # transitions to GameScene
}
```

### Mode 2 — Visual Novel (GameScene)

Full-screen dialogue presentation. Used for cutscenes and chapter sequences between world levels.

```
GameScene.tscn  (root: Control / GameScene)
├── BG                          ← layered ColorRects + vignettes
├── ChapterTitle                Label   ← dim chapter label top-left
├── MainLayout                  HBoxContainer
│   ├── LeftCharPanel           Panel   ← left portrait (icon + name)
│   ├── CenterCol               VBox
│   │   ├── DialoguePanel       Panel   ← speaker name + body text
│   │   └── ChoicePanel         VBox    ← choice buttons [hidden]
│   └── RightCharPanel          Panel   ← right portrait (icon + name)
├── BottomBar                   ← progress counter + "SPACE/CLICK" hint
└── ChapterCard                 ColorRect   ← full-screen chapter title card
```

---

## Global Singletons (Autoload)

### `GameManager`

State and character data. Always available.

| What | Type | Purpose |
|---|---|---|
| `current_chapter_id` | `String` | Which chapter to load in GameScene |
| `resume_line` | `int` | Line index to resume at after a mini-game |
| `CHAR_COLORS` | `Dictionary` | `"rat" → Color(...)` |
| `SPEAKER_NAMES` | `Dictionary` | `"rat" → "老鼠"` |
| `CHAR_LABELS` | `Dictionary` | `"rat" → "[鼠]"` |
| `start_chapter(id)` | method | Sets `current_chapter_id`, goes to GameScene |
| `go_to_level(path)` | method | Direct scene change |

### `DialogueData`

Pure data. All story content lives here as `CHAPTERS: Array[Dictionary]`.

**Chapter dict:**
```gdscript
{
    "id":         "ch1",
    "title":      "Chapter 1 — 破處",
    "bg_color":   Color(...),
    "left_char":  "sam",
    "right_char": "rat",
    "lines":      [ ... ]
}
```

**Line dict:**
```gdscript
{
    "speaker": "rat",           # key into GameManager lookups
    "text":    "...",
    "active":  "right",         # "left" | "right" | "none" — which portrait highlights
    # optional:
    "choices": [{"text": "...", "goto": 14}],
    "next":    16,              # jump to line 16 instead of index+1
    "minigame": true,           # triggers CivilServantGame; saves resume_line
    "fx":      ["shake"],       # triggers AsciiLevelBase FX
    "speed":   "slow",          # "fast" | "normal" | "slow"
}
```

### `ObjectData`

Interactable world objects. Dictionary keyed by level id, then by `Vector2i` grid position.

```gdscript
"station": {
    Vector2i(14, 11): {"text": "垃圾。或者說是歷史。"},
}
```

Pressing E near any of these grid cells shows the scene intro panel.

---

## Operational Flow

```
StartScreen
    │  "開始遊戲"
    ▼
Station.tscn  (ch1 world)
    │  E near Rat → WorldDialogue ch1
    │  dialogue ends → _transition_to_ch2()
    ▼
GameScene  (ch1 → ch2 — cutscene chapters)
    │  chapter ends → GameScene._go_next_chapter()
    │  ch3 is in LEVEL_CHAPTERS → Office.tscn
    ▼
Office.tscn  (ch3 world)
    │  E near Lee → WorldDialogue ch3
    │  E near door → start_chapter("ch4") → GameScene
    ▼
GameScene  (ch4)
    │  ends → Street.tscn
    ▼
Street.tscn
    │  E near door → LaoxiaoRestaurant.tscn
    ▼
LaoxiaoRestaurant.tscn  (ch5 world)
    │  E near 某甲 → WorldDialogue ch5
    │  E near door → start_chapter("ch6") → GameScene
    ▼
GameScene  (ch6)
    │  ends → StartScreen (loop / credits placeholder)
```

### Font scaling

All UI sizes derive from a single constant `BASE_MAP_FONT = 28` (the original design font size). At startup, `AsciiLevelBase._compute_font_size()` fits the map into the viewport and produces `_font_size`. Every other element — HUD, ambient labels, dialogue panel, choice buttons — divides by `BASE_MAP_FONT` and multiplies by `_font_size` to scale proportionally.

---

## Adding Content

### New level

1. Create `scripts/XyzLevel.gd` extending `AsciiLevelBase`, implement the six hooks.
2. Duplicate `scenes/Station.tscn`, attach `XyzLevel.gd` to the root.
3. Wire up an NPC entry in an existing level with `"next_level": "res://scenes/Xyz.tscn"`.

### New dialogue

Add a chapter dict to `DialogueData.CHAPTERS`. Reference its `"id"` from an NPC's `"chapter_id"` (for world dialogue) or from `GameManager.start_chapter()` (for GameScene).

### New interactable object

Add an entry to `ObjectData.OBJECTS["level_id"]` at the desired `Vector2i` position, with a `"text"` field. Place a `%` tile at that grid cell in the map data.

---

## File Map

```
scripts/
  GameManager.gd       — autoload: state + character constants
  DialogueData.gd      — autoload: all story content
  ObjectData.gd        — autoload: world interactables
  AsciiLevelBase.gd    — base class for all ASCII world levels
  StationLevel.gd      — ch1 world
  OfficeLevel.gd       — ch3 world
  StreetLevel.gd       — ch4 world
  RestaurantLevel.gd   — ch5 world
  WorldDialogue.gd     — right-panel dialogue system (used in all worlds)
  GameScene.gd         — full-screen visual novel mode
  CivilServantMiniGame.gd  — mini-game (procedural UI)
  StartScreen.gd       — title screen

scenes/
  StartScreen.tscn
  Station.tscn / Office.tscn / Street.tscn / LaoxiaoRestaurant.tscn
  WorldUI.tscn         — shared dialogue panel (instanced into each world)
  GameScene.tscn       — visual novel layout
  CivilServantGame.tscn
```
