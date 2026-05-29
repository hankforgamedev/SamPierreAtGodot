# CLAUDE.md

## 1. Think Before Coding

State assumptions explicitly. If multiple interpretations exist, surface them — don't pick silently. If a simpler approach exists, say so. If something is unclear, stop and ask.

## 2. Simplicity First

Minimum code that solves the problem. No features, abstractions, configurability, or error handling beyond what was asked. If 200 lines could be 50, rewrite it. "Would a senior engineer call this overcomplicated?" — if yes, simplify.

## 3. Surgical Changes

Touch only what you must. Don't improve adjacent code, refactor what isn't broken, or reformat. Match existing style. Note unrelated dead code; don't delete it. Clean up only the orphans your own changes created. Every changed line should trace to the user's request.

## 4. Goal-Driven Execution

Define verifiable success criteria, then loop until met.

- "Add validation" → write tests for invalid inputs, then make them pass
- "Fix the bug" → write a test that reproduces it, then make it pass
- "Refactor X" → tests pass before and after

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

## 5. Verification Before Claims

- NEVER claim work is complete, tests pass, or issues are fixed without running the actual verification command and showing output
- Use case-insensitive search by default (grep -i) unless specified otherwise
- When user provides a spec with N items, verify each one individually and report [Unverified] for any you couldn't confirm

## Running the Project

Open in **Godot 4.6** editor and press F5 (runs DevMenu — chapter/level picker), or F6 to run the current scene. No CLI build step — GDScript is interpreted.

To run from terminal (project root):

```
godot --path .                           # DevMenu (main scene)
godot --path . scenes/StartScreen.tscn  # full playthrough
```

### Dev Environment

Requirements:

- Godot 4.6 binary (no compilation — GDScript is interpreted)
- Download: https://godotengine.org/download

Run:

```
godot --path . scenes/DevMenu.tscn       # dev mode — chapter/level picker
godot --path . scenes/StartScreen.tscn  # full playthrough
```

Audio assets (drop here when ready):

```
res://audio/sfx/*.wav       (export from jsfxr as WAV)
res://audio/ambient/*.ogg
```

## Architecture

### Entry Flow

`StartScreen.tscn` → `Station.tscn` (2.5D world) → NPCs trigger inline dialogue → doors transition to other levels. The old `GameScene.tscn` (full-screen visual novel) is still used for cutscene/flashback sequences via `GameManager.start_chapter()`.

### Global Singletons (Autoload)

- **`GameManager`** (`scripts/GameManager.gd`) — character name/label constants (`SPEAKER_NAMES`, `CHAR_LABELS`), `current_chapter_id`, `resume_line` (for mini-game return), `start_chapter()`, `go_to_level()`. Character *colors* live in `GameTheme.CHAR_COLOR` and `GameTheme.CHAR_HEX`.
- **`DialogueData`** (`scripts/DialogueData.gd`) — all story content as `CHAPTERS` array; pure data, no logic

### ASCII World System (grid-based, no physics)

- **`AsciiLevelBase.gd`** — base `Control` class for all levels; handles grid movement, collision (`#`/`I`/`|` block), E-key interaction, glitch rendering, `stress_level` variable drives glitch frequency
- **`StationLevel.gd`**, **`OfficeLevel.gd`**, **`StreetLevel.gd`**, **`RestaurantLevel.gd`** — each extends `AsciiLevelBase`; overrides `_get_map_data()` (Array[String]), `_get_player_spawn()` (Vector2i), `_get_npcs()` (Vector2i → Dict), `_get_level_name()`
- **`WorldDialogue.gd`** — right-side panel (right 35% of screen); mirrors GameScene typewriter + choice logic; `open(chapter_id, start_line)` / `close()` / emits `dialogue_closed`
- **NPC dict format**: `{Vector2i: {chapter_id, start_line, char_id, display}}` — or include `next_level` key for door transitions
- **Glitch system**: `_glitch_overlay` (Vector2i → String) randomly corrupts `#`/`%`/`.` chars; chaos pool uses Unicode symbols (Ψ Ω Δ ░ ▓ etc.); scales with `stress_level`
- **Font**: `SystemFont` with Consolas/Courier New at 28px set programmatically in `_setup_display()`

### Dialogue Line Schema

Each line in `DialogueData.CHAPTERS[n].lines[]` is a Dictionary:

```
speaker  : String              # "sam"|"rat"|"lee"|"rachel"|"sarah"|"bill"|"moujia"|"david"|"narrator"
text     : String
active   : "left"|"right"|"none"
choices  : [{text, goto}]      # optional — renders choice buttons
next     : int                 # optional — overrides default index+1
minigame : any                 # presence triggers CivilServantGame.tscn, saves resume_line
```

### Mini-game Integration

A line with `minigame` field saves `GameManager.resume_line = index + 1`, then scene-changes to `CivilServantGame.tscn`. On return, `GameScene._ready()` detects `resume_line > 0` and resumes. `CivilServantGame.tscn` is almost empty — all UI is procedural in `CivilServantMiniGame.gd`.

### Levels

| Scene                    | Script               | Key NPC / Door                                          |
| ------------------------ | -------------------- | ------------------------------------------------------- |
| `Station.tscn`           | `StationLevel.gd`    | Rat `?` @ (44,9) → ch1                                  |
| `Office.tscn`            | `OfficeLevel.gd`     | Lee `L` @ (41,10) → ch3                                 |
| `Street.tscn`            | `StreetLevel.gd`     | Door `>` @ (47,13) → 老蕭餐館                           |
| `LaoxiaoRestaurant.tscn` | `RestaurantLevel.gd` | Moujia `甲` @ (36,11) → ch5; Door `<` @ (2,11) → Street |

### GameTheme — palette + font system

**Everything lives in `scripts/GameTheme.gd`.** Edit there, changes propagate everywhere — no Godot editor, no CLI tool, no .tres.

**Font sizes** — 6 consts at the top of `GameTheme.gd`:

| Const | Default | Consumers |
|---|---|---|
| `FONT_BODY` | 32 | dialogue text, narration, DevMenu labels |
| `FONT_SPEAKER` | 28 | speaker names |
| `FONT_DIM` | 24 | hints, buttons, choice titles, secondary text |
| `FONT_TITLE` | 36 | chapter card big title |
| `FONT_AMBIENT` | 18 | ASCII world HUD, NPC ambient hint |
| `FONT_BIG` | 64 | start screen title |

**Palette colors** — `scripts/GameTheme.gd` (`class_name GameTheme`, no autoload needed).

**Never hardcode palette values or character colors inline.** Use `GameTheme.*` constants. The only allowed exceptions are one-off dramatic-effect colors (e.g., stamp overlay alphas) which must have an inline comment explaining why.

| Prefix | Contents |
|--------|----------|
| `C_BG*` | Background depths (`C_BG`, `C_BG_MAP`) |
| `C_PANEL_*` | Panel fill + border |
| `C_BODY_TEXT`, `C_SPEAKER_TEXT`, `C_NARRATOR`, `C_DIM` | Text hierarchy |
| `C_CHOICE_*` | Choice button scheme |
| `C_HINT_TEXT`, `C_AMBIENT_TEXT` | World UI labels |
| `C_RED`, `C_GREEN`, `C_TITLE_TEXT`, etc. | One-off named colors |
| `CHAR_HEX` | BBCode hex strings per character |
| `CHAR_COLOR` | `Color` objects per character for `add_theme_color_override` |
| `BASE_MAP_FONT` | Root design font (28px); ASCII map grid scales from this |
| `SPEED_FAST/NORMAL/SLOW` | Typewriter speeds in seconds/char |

Adding a new character: add to **both** `CHAR_HEX` and `CHAR_COLOR` in `GameTheme.gd`.

## Design Language

### Mandarin Focus & Full-Width Characters

Game is **Mandarin-native** (not English with Chinese labels). ASCII map scenes use **full-width (全形) characters** exclusively for consistency — no mixing ASCII and CJK widths. Glitch overlay symbols, walls, NPCs, doors all use full-width equivalents.

### Keyboard as First-Class Input

Keyboard input is **not an afterthought**. Every UI/menu (start screen, game-over, choices, level HUDs) must be **fully keyboard-navigable**. Godot's built-in focus/input handling covers this without manual wiring — use it. Mouse clicks work out of the box for clickable objects; keyboard must have equal priority.

## Known Issues — Dialogue Choice Behavior

**Status:** Unstable. Scheduled for full fix 2026-05-31.

**Symptoms:**
- Choice button text wrapping inconsistent (multi-line clipping with long CJK text)
- Player response auto-advance timing frame-dependent (sometimes skips, sometimes waits)
- WorldDialogue vs GameScene choice flow differ (inconsistent behavior across scenes)

**Root Cause:**
Partial fixes layered without unified design:
1. `custom_minimum_size = Vector2(0, 0)` + `clip_text = true` (commit 6bdd1ae) — prevents overflow but breaks text flow
2. `size_flags_horizontal = Control.SIZE_EXPAND_FILL` — helps width but doesn't solve clipping
3. `_is_player_line` flag + `_advance()` in `_process()` — timing unsafe, depends on frame rate

**Affected Files:**
- `scripts/WorldDialogue.gd` — `_build_choices()` L:240-265, `_process()` L:92-101, `_show_line()` L:176
- `scripts/GameScene.gd` — `_build_choices()` L:282-313 (no auto-advance — inconsistent)

**Fix Scope (TODO):**
- Decouple choice flow from typewriter timing (use signal, not frame-based advance)
- Set explicit button dimensions instead of clip_text
- Unify GameScene + WorldDialogue choice behavior
- Test with long Mandarin choice text (full-width chars break differently than ASCII)

**Do Not Touch Until:** Ready to fix all three points in single session.

