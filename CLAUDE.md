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

- **`GameManager`** (`scripts/GameManager.gd`) — character color/name constants, `current_chapter_id`, `resume_line` (for mini-game return), `start_chapter()`, `go_to_level()`
- **`DialogueData`** (`scripts/DialogueData.gd`) — all story content as `CHAPTERS` array; pure data, no logic

### ASCII World System (grid-based, no physics)

- **`AsciiLevelBase.gd`** — base `Control` class for all levels; handles grid movement, collision (`#`/`I`/`|` block), E-key interaction, glitch rendering, `stress_level` variable drives glitch frequency
- **`StationLevel.gd`**, **`OfficeLevel.gd`**, **`StreetLevel.gd`**, **`RestaurantLevel.gd`** — each extends `AsciiLevelBase`; overrides `_get_map_data()` (Array[String]), `_get_player_spawn()` (Vector2i), `_get_npcs()` (Vector2i → Dict), `_get_level_name()`
- **`WorldDialogue.gd`** — right-side panel (right 35% of screen); mirrors GameScene typewriter + choice logic; `open(chapter_id, start_line)` / `close()` / emits `dialogue_closed`
- **NPC dict format**: `{Vector2i: {chapter_id, start_line, char_id, display}}` — or include `next_level` key for door transitions
- **Glitch system**: `_glitch_overlay` (Vector2i → String) randomly corrupts `#`/`%`/`.` chars; chaos pool uses Unicode symbols (Ψ Ω Δ ░ ▓ etc.); scales with `stress_level`
- **Font**: `SystemFont` with Consolas/Courier New at 28px set programmatically in `_setup_display()`
- **`BaseLevel.gd`**, **`PlayerController.gd`**, **`NPC.gd`** — superseded by ASCII system, kept but unused

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

### Color Palette (Dark Earth)

All UI uses the same constants (defined per-script, not in a shared file):

- Panel BG: `Color(0.10, 0.078, 0.060)` — Panel border: `Color(0.50, 0.36, 0.14)`
- Speaker name: `Color(0.96, 0.80, 0.38)` — Body text: `Color(0.88, 0.84, 0.74)`

### Deprecated Files

`scenes/Chapter1.tscn` and `scripts/Chapter1.gd` are unused — do not reference them.
