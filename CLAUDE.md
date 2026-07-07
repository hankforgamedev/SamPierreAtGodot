# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **Companion docs (read these too):** `SPEC.md` (vision, pillars, guardrails, backlog) · `STATE.md` (what's in progress right now) · `DECISIONS.md` (why things were decided). This file = **how the code is structured**; those = what/why/now.

## Branch Reality — READ FIRST

The game is in its **3D era**. The current, active architecture is **3D first-person (Arctic Eggs style)** on branch **`arctic-3d-proto`** (this branch). The old **2D ASCII text-art** version is **archived, untouched**, on `main` and `papers-please-ui` — it is *not* the current game. Everything below describes the 3D system unless a section is explicitly labeled **[Legacy 2D]**.

## Running the Project

Open in **Godot 4.6** editor and press F5 (main scene is `scenes3d/Arctic.tscn`), or run a scene with F6. GDScript is interpreted — no build step.

From terminal (project root):
```
godot --path . scenes3d/Arctic.tscn
```

After adding any `class_name`, run `--import` once to refresh the global class cache, or you'll get "Could not find type X":
```
godot --headless --path . --import
```

Run the test suite (GDUnit4 v6.1.3, currently 42 tests):
```
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/ --ignoreHeadlessMode
```

## Architecture (3D)

### Entry Flow
`scenes3d/Arctic.tscn` (minimal entry; its root runs `Arctic3D.gd`) → host builds a low-res SubViewport + dither shader → loads a level scene → first-person exploration → interacting with an NPC opens `DialogueBox3D` (chapter dialogue) → doors transition between levels.

### Global Singletons (Autoload)
- **`GameManager`** (`scripts/GameManager.gd`) — character color/name constants, `current_chapter_id`, `resume_line` (mini-game return), `start_chapter()`, `go_to_level()`
- **`DialogueData`** (`scripts/DialogueData.gd`) — `CHAPTERS` array **loaded at runtime from `story/chapters/*.md`** via `StoryLoader.load_chapter()` (story is now decoupled from code — see Story Data Files). Accessors: `get_chapter(id)`, `get_chapter_index(id)`, `get_next_chapter_id(id)`
- **`ObjectData`** (`scripts/ObjectData.gd`) — object-interaction data

### 3D World System
- **`scripts3d/Arctic3D.gd`** (`extends Node`) — the **host**. Builds the low-res viewport (`VIEW_SHRINK = 6` → 320×180) + `psx_dither` shader, the HUD/interact prompt, loads levels (`START_LEVEL = Station.tscn`), captures the mouse. Routes input: mouse motion → `FPPlayer.rotate_look()` (forwarded from outside the SubViewport), interact key → `DialogueBox3D.advance()` or `_try_interact()`, ESC → toggle mouse capture. **Host only** — no game logic beyond viewport/level-loading/HUD/input routing.
- **`scripts3d/FPPlayer.gd`** (`class_name FPPlayer`, `CharacterBody3D`) — first-person controller. WASD via global `Input` polling (not the input map / not SubViewport forwarding), `rotate_look()` called by the host. `RayCast3D` (range 2.4) drives `current_target()` for interaction. Camera/collision built in `_ready()`.
- **`scripts3d/DialogueBox3D.gd`** (`class_name DialogueBox3D`, `Control`) — chapter dialogue UI: **no panel border, plain text + black outline** (Arctic Eggs look). Shares the exact same data as everything else (`DialogueData` chapters). Typewriter + choices + `next` + `minigame`, mirroring 2D `WorldDialogue`. Signals: `closed`, `choices_visible_changed(active)`, `line_fx(effects)`.
  - ⚠️ **Anchor gotcha:** must use `set_anchors_and_offsets_preset(PRESET_FULL_RECT)`, **not** `set_anchors_preset` — the latter recomputes offsets from the current 0×0 min-size and pins a pure `Control` to the top-left at zero size. (Root cause of two 9th-playtest UI bugs.)
- **Levels = pure scene data, no scripts:** `scenes3d/Station.tscn` (rat/ch1), `Office.tscn` (lee/ch3), `Restaurant.tscn` (moujia/ch5). Geometry, furniture, lights, spawn, and interactables all live in the `.tscn` (editor-editable). **Interaction is by node metadata** (convention in `tools/level_builder_lib.gd`):
  - NPC node: meta `chapter_id` / `start_line` / `char_id` → opens dialogue
  - Door node: meta `next_level` / `display_name` → level transition
- **Scene build tools** (`tools/`, run as SceneTree scripts to (re)generate `.tscn`, then edit in-editor as source of truth): `level_builder_lib.gd` (shared static lib, `preload`ed), `build_station.gd` / `build_office.gd` / `build_restaurant.gd` (per-level layout), `measure_models.gd` (model sizing), `smoke_levels.gd` (smoke test). **Do not generate geometry in `_ready()`** — it must exist in the `.tscn`.
- **`shaders/psx_dither.gdshader`** — color quantization + 4×4 Bayer dithering + green-grey tint (uniforms: `color_steps` / `saturation` / `tint`).
- **CC0 assets:** `assets/models/kenney_furniture/` (Kenney Furniture Kit, ×2 scale ≈ human proportions, `LICENSE.txt` included).

### Dialogue Line Schema
Each line in a chapter's `lines[]` is a Dictionary (shared by 3D and legacy 2D):
```
speaker  : String              # "sam"|"rat"|"lee"|"rachel"|"sarah"|"bill"|"moujia"|"david"|"narrator"
text     : String
active   : "left"|"right"|"none"
choices  : [{text, goto}]      # optional — renders choice buttons
next     : int                 # optional — overrides default index+1
minigame : any                 # presence triggers CivilServantGame.tscn, saves resume_line
```
Chapter markdown also supports per-line `speed:` (fast/normal/slow) and `fx:` (shake, flash_white, flash_black, glitch_spike, …) tags — see `story/chapters/ch1.md` for live examples.

### Mini-game Integration
A line with a `minigame` field saves `GameManager.resume_line`, then scene-changes to `CivilServantGame.tscn`. On return, resume logic detects `resume_line > 0` and continues. `CivilServantGame.tscn` is nearly empty — all UI is procedural in `CivilServantMiniGame.gd`. (Per SPEC.md the civil-servant mini-game is the *loop mechanic*, not a side-game.)

### Story Data Files (decoupled — Markdown, never JSON)
Story prose belongs to co-author **Sam K.** and is edited directly as Markdown — **do not change story text without asking Hank** (SPEC.md §5).
- `story/chapters/ch1.md … ch8.md`, `epilogue.md` — chapter dialogue (parsed by `StoryLoader.load_chapter`)
- `story/levels/*.md` — level intro + ambient before/after text
- `story/objects.md` — object-interaction descriptions
- `story/minigame.md` — mini-game text
- **`scripts/StoryLoader.gd`** — parses the above Markdown into the runtime dictionaries. Format = Markdown (preferred) or YAML, **never JSON** (writers must be able to read/edit it).

### Color Palette (Dark Earth)
Constants defined per-script (not shared):
- Panel/BG: `Color(0.10, 0.078, 0.060)` — Border/accent: `Color(0.50, 0.36, 0.14)`
- Speaker name: `Color(0.96, 0.80, 0.38)` — Body text: `Color(0.88, 0.84, 0.74)` — Narrator: `Color(0.62, 0.58, 0.48)`

## [Legacy 2D] ASCII World System — archived on `main` / `papers-please-ui`

Not used on this branch. Kept for reference / in case 2D work resumes. Grid-based ASCII renderer, no physics:
- **`AsciiLevelBase.gd`** — base `Control`; grid movement, collision (`#`/`I`/`|`), E-key interaction, glitch rendering driven by `stress_level`
- **`StationLevel.gd` / `OfficeLevel.gd` / `StreetLevel.gd` / `RestaurantLevel.gd`** — override `_get_map_data()` / `_get_player_spawn()` / `_get_npcs()` / `_get_level_name()`
- **`WorldDialogue.gd`** — right-35%-of-screen dialogue panel; the 3D `DialogueBox3D` is its successor
- **Glitch system** — `_glitch_overlay` corrupts chars with a Unicode chaos pool, scaling with `stress_level`
- 2D entry flow was `StartScreen.tscn` → `Station.tscn` → levels; `GameScene.tscn` was the full-screen VN for cutscenes
- **Deprecated even within 2D:** `scenes/Chapter1.tscn`, `scripts/Chapter1.gd`, and `BaseLevel.gd` / `PlayerController.gd` / `NPC.gd` — do not reference
