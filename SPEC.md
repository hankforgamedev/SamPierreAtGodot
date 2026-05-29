# SPEC: Bug Fixes & Feature Pass (Fixer-Upper Branch)

## Goal

Eight targeted fixes and additions to the Godot 4.6 game. Priority order: #8 (crash) → #1 (minigame keyboard) → #3 (gameover screen) → #2 (inner speaker) → #6 (SFX) → #4 (text overflow) → #7 (map alignment audit) → #5 (font import answer). No refactors beyond what each fix requires.

---

## Scope — what's in

### #1 — Minigame keyboard input (`CivilServantMiniGame.gd`)

Add `_input(event)` to `CivilServantMiniGame`:

| Key | Action |
|---|---|
| A / Left | Reject (`_on_reject()`) — only if buttons not disabled |
| D / Right | Approve (`_on_approve()`) — only if buttons not disabled |
| E / Space / Enter | Dismiss Lee panel (`_dismiss_lee()`) — only if Lee panel visible |

No other keys. No mouse changes. Button `disabled` flag already gates double-press; keyboard must respect it too.

---

### #2 — `inner` speaker display

**Problem:** `SPEAKER_NAMES["inner"] = "（心裡）"` renders as a speaker label in a different font/size, and `[i]` wrapping makes the font wrong.

**Fix (two parts):**

1. In `GameManager.gd`: change `"inner"` SPEAKER_NAMES value to `""` (empty string). This makes the speaker bar show `— — —` like narrator.
2. In `WorldDialogue._show_line()`: the existing `is_inner` path wraps text in `[i][/i]` BBCode — that's correct. But ensure the body color uses `C_NARRATOR` (same muted tone as narrator) at reduced opacity (target ~65% alpha). Since BBCode opacity isn't trivially done, use `C_NARRATOR` color but darkened: `C_NARRATOR.darkened(0.25)` — call it `C_INNER`.
3. Add `C_INNER := C_NARRATOR.darkened(0.25)` to `GameTheme.gd`.
4. In `WorldDialogue._show_line()`: when `is_inner`, set `body_color = GameTheme.C_INNER` instead of `spk_color`.

Font size: `inner` body uses `normal_font_size` (= `FONT_BODY`) via RichTextLabel theme — no special size needed. The broken size was caused by the `[i]` tag inheriting a wrong override; removing the speaker name display fixes the cascade.

**Same fix applies to `GameScene.gd`:** `dlg_text.theme_type_variation` should be `"NarratorLabel"` when `is_inner`, and `inner` check added alongside `narrator` check. Body text gets `CHAR_COLOR["inner"]` which is already defined.

---

### #3 — GameOver screen (new)

**Trigger:** `StationLevel._trigger_train_death()` currently ends with `get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")`. Replace that line with `get_tree().change_scene_to_file("res://scenes/GameOver.tscn")`.

**New files:**
- `scenes/GameOver.tscn` — minimal scene, root = Control, script attached
- `scripts/GameOver.gd`

**GameOver screen layout (procedural, no editor):**
- Full-screen dark bg (`GameTheme.C_BG`)
- Centered VBox: death message text (from `GameManager.gameover_text`, see below) + two buttons
- Button 1: `"重試"` (Retry) — plays `SoundManager.play_sfx("riser")`, then after 0.5s loads `res://scenes/Station.tscn`
- Button 2: `"去死吧"` (Fuck This) — immediate `get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")`

**GameManager additions:**
```gdscript
var gameover_text: String = ""
var gameover_retry_scene: String = "res://scenes/Station.tscn"
```

`StationLevel._trigger_train_death()` sets `GameManager.gameover_text` to the death flavor text before changing scene, so GameOver screen can display it.

**Design assumption:** Retry always restarts from Station (the only death location in scope). If more death triggers are added later, they set `GameManager.gameover_retry_scene` before transitioning.

---

### #4 — Dialogue text overflow

**Problem (two symptoms):**
1. Text truncated mid-string in some paths
2. Text renders outside panel

**Root cause (WorldDialogue):** `dlg_text` is a `RichTextLabel` with `clip_contents = true` on the panel (already set, line 54). The scroll is enabled but the panel height may not give enough room. Check: `fit_content = false` means the label won't grow — scroll should handle it. Likely the issue is that `visible_characters` cap was applied somewhere, or the scroll isn't triggered.

**Root cause (GameScene):** `dlg_text` is a plain `Label` (not RichTextLabel) — no scroll. Long text overflows bottom of panel without clipping.

**Fix:**
- `GameScene.gd`: confirm `dlg_panel` has `clip_contents = true` in the scene file; if not, set it in `_apply_theme()`. Set `dlg_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART`. Do NOT truncate.
- `WorldDialogue.gd`: ensure `scroll_active = true` (already set). After `_update_display()`, call `dlg_text.scroll_to_line(dlg_text.get_line_count())` (already present in the non-typing path). Verify no `visible_characters` cap is set externally.
- Neither system should impose a character limit. If content overflows vertically, the scroll bar handles it.

---

### #5 — Custom font import (answer only, no code change until fonts are placed)

**How to import OTF/TTF in Godot 4.6:**
1. Drop the font files into `res://fonts/` (create the directory).
2. Godot auto-imports them as `FontFile` resources.
3. In `GameTheme.build_scaled_theme()`, add:
   ```gdscript
   var sans := load("res://fonts/YourSans.otf") as FontFile
   var serif := load("res://fonts/YourSerif.otf") as FontFile
   t.set_font("font", "Label", sans)
   t.set_font("normal_font", "RichTextLabel", serif)
   ```
4. For CJK: Godot 4 loads only the glyphs actually used at runtime (dynamic font loading), so a full CJK font (e.g. NotoSansCJK) won't tank startup. First-frame cost exists; acceptable for a VN.
5. Fallback chain: use `SystemFont` with `fallbacks` array pointing to your FontFile if you want to mix system monospace + custom CJK.

**Action required:** put font files in `res://fonts/`, then we wire them in one session.

---

### #6 — Object interaction panel SFX

**Problem:** `_show_panel_text()` in `AsciiLevelBase.gd` uses a `Tween` to animate `visible_characters`, but never calls `SoundManager.play_type_click()`. The tween has no per-character callback.

**Fix:** Replace the Tween-based typewriter with a `_process`-driven approach, same pattern as `WorldDialogue._process()`:

In `AsciiLevelBase.gd`:
- Remove the `Tween` typewriter approach for `_panel_text_label`.
- Add instance vars: `_panel_typed_count: int`, `_panel_type_timer: float`, `_panel_full_text: String`, `_panel_typing: bool`.
- In `_show_panel_text()`: initialize these vars, set `_panel_typing = true`.
- In `_process()`: when `_panel_typing`, tick timer + advance `_panel_typed_count` + call `SoundManager.play_type_click()`, same logic as WorldDialogue.
- Advance check in `_input()` (E/space skips to end, already handled by `_typewriter_tween.kill()`) — adapt to set `_panel_typing = false` and show full text.

Keep `_typewriter_tween` variable for compatibility if other code references it; or rename cleanly (within-file only, no cross-file impact).

---

### #7 — Map alignment audit (all 4 levels)

**Problem:** CJK characters in map strings are 2 display columns wide in monospace. Any CJK char in a map row shifts all subsequent characters right by 1, causing misalignment.

**Audit:** Read all four `_get_map_data()` arrays in `StationLevel.gd`, `OfficeLevel.gd`, `StreetLevel.gd`, `RestaurantLevel.gd`. For each row, check if CJK chars appear. If yes, they need either:
- Replaced with ASCII equivalents (preferred for collision/NPC grid accuracy), or
- The game needs a separate "display string" vs "collision string" (out of scope for v0 — see Non-goals).

**Expected result:** all map rows pure ASCII, alignment consistent. NPC positions in `_get_npcs()` must match the corrected map positions.

---

### #8 — Exit interaction crash (most important, fix first)

**Error:** `Cannot call method 'set_input_as_handled' on a null value` at `AsciiLevelBase.gd:181`.

**Root cause:** `_input()` calls `_try_interact()`, which may call `get_tree().change_scene_to_file(...)` (for `next_level` or `start_chapter` NPCs). After `change_scene_to_file()`, the node begins freeing. When `_input()` returns to line 181 and calls `get_viewport().set_input_as_handled()`, the viewport is null.

**Fix:** Add a guard before line 181:
```gdscript
if not is_inside_tree():
    return
get_viewport().set_input_as_handled()
```

This is a one-line fix. No restructuring needed.

---

## Design decisions

| Decision | Choice | Reason |
|---|---|---|
| GameOver retry target | Always Station.tscn | Only death trigger in current scope; GameManager var allows future extension |
| `inner` speaker name | Empty string (shows `— — —`) | User intent: no speaker label for inner monologue |
| `inner` body color | `C_NARRATOR.darkened(0.25)` | Readable but clearly distinct from narrator; user wants "lower opacity" feel |
| Object SFX approach | `_process()` tick, not Tween | Tween has no per-step callback; `_process()` pattern matches WorldDialogue (already working) |
| CJK in maps | Replace with ASCII | Collision grid assumes 1 char = 1 cell; CJK breaks this assumption throughout |

---

## Open questions

- #3: Should GameOver show the death narration text scrolling before revealing buttons, or just static text?
- #4: Are there specific lines/chapters where truncation is worst? Helps verify the fix.
- #5: What are the font names / which weights needed (regular only, or bold/italic too)?

---

## Out of scope for v0

- Map display string vs collision string separation (would fix CJK map rendering without replacing chars, but requires AsciiLevelBase refactor)
- Gameover screen for failure modes other than train death
- Font system for the full map/monospace display (only dialogue fonts are in scope for #5)
- Difficulty-specific retry checkpoints
- Animated GameOver screen transitions beyond what `StationLevel` already provides
