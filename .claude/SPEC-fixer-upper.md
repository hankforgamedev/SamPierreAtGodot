# Fixer-Upper Spec — Sam Pierre
**Branch:** `fixer-upper` | **Date:** 2026-05-29 | **Based on:** 8th playtest

---

## Goal

Fix 12 issues found in the 8th playtest of *Sam Pierre*: a mix of crash bugs, hardcoded-font regressions, input/UX friction, dialogue readability problems, and missing developer tooling. Target audience: the two-person team (SK + HankL) iterating toward a demo-ready build. No new story content; no mobile support. Pure engine/code quality pass.

---

## Scope

### In

| ID | Issue | Type |
|----|-------|------|
| B1 | Train Y position wrong (not on track) | Bug |
| B2 | Font sizes hardcoded in `_setup_scene_panel()` and `WorldDialogue.apply_scale()` | Bug |
| B3 | Station crash: interacting with `>` after ambient text "出口在那。天還沒亮。" | Bug |
| B4 | Chapter 2: previous dialogue lines invisible after advancing | Bug |
| F1 | Keybinding unification: Space/Enter should trigger `interact`; document all bindings | Feature |
| F2 | SFX system: SoundManager autoload + documented asset import path for jsfxr exports | Feature |
| F3 | Diagonal WASD movement on desktop (hold two keys simultaneously) | Feature |
| F4 | Font/color visibility: ambient label and HUD info line barely readable | Fix |
| F5 | NPC symbol oscillation (±1 cell) during active dialogue | Feature |
| F6 | Inner thoughts: remove `（心裡）` prefix; use `inner` speaker ID with italic + muted color | Feature |
| F7 | DevMenu.tscn: dev-only main scene for jumping to any chapter/level | Feature |
| F8 | City name: standardize all occurrences to "Huk-Zai City" | Fix |
| F9 | Dev environment setup section in CLAUDE.md + README.md | Docs |

### Explicit Non-Goals (v0 out-of-scope)

- **Mobile / virtual joystick** — defer; no touch target defined
- **English → Chinese translation sweep** — agreed to be a separate content pass; flagged but not scoped here
- **Story content gaps** (missing lines between "皮耶爾被刺中" and "子彈射穿老鼠的肺") — writing task for HankL, not a code issue
- **SFX production** — user has jsfxr assets; this spec only wires the system; actual sounds are provided externally
- **New chapters or levels**
- **CI/CD or automated testing pipeline**

---

## Design Decisions

### F1 — Keybinding Unification

**Problem:** `interact` (world E-key) and `ui_accept` (dialogue Space/Enter) are separate input actions. Players expecting Space to work in the world are confused.

**Decision:** Add `Space` and `Enter` as secondary keys for the `interact` action in `project.godot`. Do not remove `E`. Dialogue advance in `WorldDialogue._input()` already checks `ui_accept` (Space/Enter) and mouse click — no change needed there. The scene intro panel's "Press E to interact" hint text updates to "E / Space to interact".

**Tradeoff:** `Space` being bound to both `jump` (up movement in `_tick_movement`) and `interact` creates a conflict. Resolution: rename the up-movement action from `jump` to `move_up` and bind it only to `W` + `Up arrow`. `Space` goes exclusively to `interact`.

### F2 — SFX System

**Asset location:** `res://audio/sfx/*.wav` for UI/interaction sounds, `res://audio/ambient/*.ogg` for looping ambient. User exports jsfxr sounds as `.wav` and drops them there.

**SoundManager autoload:** New singleton `SoundManager.gd` registered in project.godot. API:
```gdscript
SoundManager.play_sfx("interact")   # plays res://audio/sfx/interact.wav if it exists
SoundManager.play_ambient("station") # loops res://audio/ambient/station.ogg
SoundManager.stop_ambient()
```
Silently no-ops if the file doesn't exist — prevents crashes before all assets are ready. Bus: SFX on "SFX" bus, ambient on "Ambient" bus, both routed to Master.

**Ambient triggers:** Each level subclass can override `_get_ambient_track() -> String` (returns track name or `""`). `AsciiLevelBase._ready()` calls `SoundManager.play_ambient()` with that value.

### F3 — Diagonal Movement

**Problem:** `_tick_movement()` uses `elif` chains — only one direction registers per frame.

**Decision:** Replace `elif` chain with additive direction accumulation:
```gdscript
var dir := Vector2i.ZERO
if Input.is_action_pressed("move_left"):  dir.x -= 1
if Input.is_action_pressed("move_right"): dir.x += 1
if Input.is_action_pressed("move_up"):    dir.y -= 1
if Input.is_action_pressed("move_down"):  dir.y += 1
```
Diagonal `_try_move` attempts x first, then y if x is blocked (standard platformer feel on grid). Hold-delay and repeat-rate logic remains unchanged.

**Tradeoff:** Diagonal on a character grid can feel odd visually. Acceptable — game is about atmosphere, not precision movement.

### F5 — NPC Oscillation

**Decision:** During `_in_dialogue == true`, the NPC involved in dialogue oscillates its `display` symbol ±1 column on a 0.4s timer. Implemented via a `_dialogue_npc_pos: Vector2i` var set in `_try_interact()` and a `_npc_anim_timer: float` ticked in `_process()`. The NPC is drawn at `_dialogue_npc_pos + Vector2i(anim_offset, 0)` where `anim_offset` alternates between -1, 0, +1. Does not actually move the NPC dict entry — only affects rendering in `_draw_map()`.

**Constraint:** Only works for single-NPC dialogue (current architecture). Fine for now.

### F6 — Inner Thoughts

**Decision:** Add `"inner"` as a valid speaker ID in `GameManager.SPEAKER_NAMES` and `CHAR_COLORS`. Assign a desaturated slate color (e.g. `Color(0.55, 0.58, 0.72)`). In `WorldDialogue._show_line()`, if `spk_key == "inner"`, wrap body text in `[i]...[/i]` BBCode before typewriter rendering.

Story markdown: replace `（心裡）` prefix on narrator lines with `speaker: inner`. StoryLoader already handles arbitrary speaker keys — no parser change needed.

### F7 — DevMenu

**Structure:**
- `scenes/DevMenu.tscn` — grid of buttons: one per level (Station, Office, Street, Restaurant) + one per chapter (ch1–ch8 + epilogue) + "Full Playthrough" (loads StartScreen.tscn normally).
- Set `DevMenu.tscn` as `project.godot` `application/run/main_scene` during development. Full-playthrough path uses `GameManager.go_to_level("res://scenes/StartScreen.tscn")`.
- **Not hidden behind a hotkey** — it's the literal main scene. Swap back to `StartScreen.tscn` before shipping.

**Why not a hotkey:** A hotkey in-game means it bleeds into distribution builds. A separate main scene is explicit and reversible.

### B2 — Font Hardcoding

Both `_setup_scene_panel()` (panel body `font_size=64`, hint `font_size=22`) and `WorldDialogue.apply_scale()` (speaker 32, dialogue 40, choices 26) ignore the scale factor. All must use `BASE_* * map_font_size / BASE_MAP_FONT` pattern already established elsewhere.

### B3 — Station Crash (needs investigation)

**Hypothesis:** `>` at (47,9) triggers `GameManager.start_chapter("ch2")` → `change_scene_to_file("res://scenes/GameScene.tscn")`. `GameScene._ready()` uses `GameManager.current_chapter_id` ("ch2") and `resume_line` (0). Crash may be:
1. `GameScene.tscn` references a deleted/renamed node → hard Godot error
2. `DialogueData.get_chapter("ch2")` returns empty dict and `GameScene` doesn't guard
3. Scene transition called while a tween/timer is still running (freed-node signal callback)

**Fix approach:** Instrument with `print()` statements; run in Godot editor debugger to get full stack trace before patching.

### B4 — Chapter 2 Scroll

`WorldDialogue._update_display()` sets `dlg_text.text = _log_bbcode + current_line`. The `RichTextLabel` has `scroll_following = true` but `fit_content = false`. If the panel height is constrained, older lines should scroll into view. Likely the panel is not tall enough at small resolutions, or `scroll_active` is being overridden somewhere. Fix: verify panel vertical sizing; add explicit `dlg_text.scroll_to_line(dlg_text.get_line_count())` after each `_update_display()` call if auto-scroll isn't working.

### F4 — Visibility

`hud_label` and `_ambient_label` both compute font size from `BASE_HUD_FONT * _font_size / BASE_MAP_FONT` = `13 * 28/28 = 13px` at design resolution — extremely small. Raise `BASE_HUD_FONT` to `18` and `BASE_AMB_FONT` from `14` to `16`. The ambient label color `Color(0.52, 0.48, 0.38)` is also too dim; raise to `Color(0.68, 0.62, 0.50)`.

### F8 — City Name

Canonical: **"Huk-Zai City"**. Grep all `.md`, `.gd`, `.tscn`, `README.md` for "Tiger Fortress" and replace. No deeper localization pass in this spec.

---

## Implementation Order (priority)

1. **B3** — crash blocks any ch2 testing
2. **B2 + F4** — font hardcoding + visibility (same pass, same files)
3. **F1** — keybinding unification (affects all input testing from here on)
4. **F3** — diagonal movement (low risk, contained to `_tick_movement`)
5. **B1** — train Y position (visual, isolated to `StationLevel.gd`)
6. **B4** — Chapter 2 scroll (dialogue UX)
7. **F6** — inner thoughts (speaker system + story file edits)
8. **F5** — NPC oscillation (rendering only)
9. **F7** — DevMenu (new file, no risk to existing scenes)
10. **F2** — SFX system (new autoload; implement shell, fill assets separately)
11. **F8** — city name sweep
12. **F9** — dev docs

---

## Dev Environment Setup (F9 deliverable)

To be added to both `README.md` and `CLAUDE.md`:

```
### Dev Environment

Requirements:
- Godot 4.6 binary (no compilation needed — GDScript is interpreted)
- Download: https://godotengine.org/download
- No GDNative plugins required. No build step.

Run the project:
  godot --path . scenes/DevMenu.tscn    # dev mode — chapter picker
  godot --path . scenes/StartScreen.tscn # full playthrough

Godot editor:
  Open Godot → Import → select project.godot
  Press F5 to run main scene
  Press F6 to run current scene only

No Godot MCP or GDPlugin required for current scope.
Godot LSP (Language Server Protocol) is built into the editor — 
enable in Editor > Editor Settings > Text Editor > External > Use External Editor
if using VS Code with godot-tools extension.

Audio assets:
  SFX: res://audio/sfx/*.wav   (export from jsfxr as WAV)
  Ambient: res://audio/ambient/*.ogg
```

---

## Open Questions

1. **B3 root cause** — exact crash path unknown until editor debugger run. Stack trace needed before fix.
2. **SFX asset list** — which jsfxr sounds exist? What events should trigger each? (interact, dialogue_advance, scene_transition, menu_select)
3. **English sweep** — agreed as future pass, but no owner or timeline set. Flag for HankL.
4. **NPC oscillation range** — ±1 column works if map is wide enough. Does it visually collide with walls or other NPCs at current spawn positions? Needs playtesting.
5. **DevMenu visual style** — should match game palette (dark earth) or be a plain debug UI? Low stakes, but clarify before implementation.
