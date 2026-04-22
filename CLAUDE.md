# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Running the Project

Open in **Godot 4.6** editor and press F5, or run a specific scene with F6. There is no CLI build step — GDScript is interpreted.

To run from terminal (project root):
```
godot --path . scenes/StartScreen.tscn
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
| Scene | Script | Key NPC / Door |
|---|---|---|
| `Station.tscn` | `StationLevel.gd` | Rat `?` @ (44,9) → ch1 |
| `Office.tscn` | `OfficeLevel.gd` | Lee `L` @ (41,10) → ch3 |
| `Street.tscn` | `StreetLevel.gd` | Door `>` @ (47,13) → 老蕭餐館 |
| `LaoxiaoRestaurant.tscn` | `RestaurantLevel.gd` | Moujia `甲` @ (36,11) → ch5; Door `<` @ (2,11) → Street |

### Color Palette (Dark Earth)
All UI uses the same constants (defined per-script, not in a shared file):
- Panel BG: `Color(0.10, 0.078, 0.060)` — Panel border: `Color(0.50, 0.36, 0.14)`
- Speaker name: `Color(0.96, 0.80, 0.38)` — Body text: `Color(0.88, 0.84, 0.74)`

### Deprecated Files
`scenes/Chapter1.tscn` and `scripts/Chapter1.gd` are unused — do not reference them.
