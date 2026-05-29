# SPEC: Remaining Bugs — Sam Pierre
**Branch:** `fixer-upper` | **Updated:** 2026-05-29 | **Source:** 8th playtest

Three bugs from SPEC-fixer-upper.md not yet fixed. Everything else is done.

---

## B1 — Train Y position wrong (not on track)

**File:** `scripts/StationLevel.gd:77`

**Symptom:** Train animates at wrong vertical position — not aligned with the track row.

**Code:**
```gdscript
var track_y := _base_map_pos.y + float(TRACK_ROW) * float(_font_size)
train.position = Vector2(vp_size.x + 40.0, track_y)
```

**Hypothesis:** `Label.position` is the top-left corner; map characters are also top-left. The train label's own height is not subtracted, so the train sits *below* the intended row rather than *on* it. Or `_base_map_pos` doesn't account for the map's top margin inside the Control.

**Fix approach:**
1. Print `_base_map_pos`, `TRACK_ROW`, `_font_size`, and `train.size` at runtime to confirm actual vs expected Y.
2. Likely fix: `track_y = _base_map_pos.y + float(TRACK_ROW) * float(_font_size)` is correct if the map label renders from its own top-left. Cross-check `TRACK_ROW = 15` against the actual track row in `_get_map_data()` (should be the `═` row).
3. If still off: add `- train.size.y / 2.0` to vertically center train glyph on the track row.

**Constraint:** Train label uses `theme_type_variation = "TitleLabel"` — font size scales. Any y-correction must use `_font_size` not a literal.

---

## B3 — Station crash: interacting with `>` after ambient text

**File:** `scripts/GameScene.gd` / `scripts/StationLevel.gd`

**Symptom:** Interacting with the `>` exit door after ambient text "出口在那。天還沒亮。" crashes the game.

**Known state:**
- `GameScene._ready()` has `if chapter.is_empty(): return` guard — prevents empty-chapter null crash.
- The `>` door triggers `GameManager.start_chapter("ch2")` → `change_scene_to_file("res://scenes/GameScene.tscn")`.

**Hypotheses (in order of likelihood):**
1. Scene transition fires while a tween or `await get_tree().create_timer(...)` is still running in `StationLevel`. The freed node tries to call back into a signal → null instance error.
2. `DialogueData.get_chapter("ch2")` returns empty (chapter ID mismatch) — but the guard should handle this; check if it returns before `_setup_characters()` which may also crash on empty.
3. `GameScene.tscn` has a reference to a node that was renamed or deleted.

**Fix approach:**
1. Run in Godot editor debugger; reproduce crash; get full stack trace. Don't patch without it.
2. If hypothesis 1: cancel all active tweens before scene change — `get_tree().create_tween()` in `_trigger_train_death()` should be stored and `.kill()`ed before any `change_scene_to_file`.
3. If hypothesis 2: add `print("chapter:", GameManager.current_chapter_id, " data:", chapter)` before the empty guard.

**Note:** `# [DEBUG] train y position wrong` comment on line 62 of StationLevel.gd is stale — remove after B1 is fixed.

---

## B4 — Chapter 2: previous dialogue lines invisible after advancing

**File:** `scripts/WorldDialogue.gd`

**Symptom:** In WorldDialogue (ASCII map scenes), advancing to the next line makes previous lines disappear instead of accumulating above.

**Current code:**
```gdscript
# _update_display() at line 191:
dlg_text.text = _log_bbcode + _cur_entry_header \
    + "[color=" + _cur_body_hex + "]" + _typing_text + "[/color]"
dlg_text.scroll_to_line(dlg_text.get_line_count())
```

**Hypothesis:** `_log_bbcode` isn't being appended correctly. Check `_update_display()` call sites:
- Line 92: `open()` — resets `_log_bbcode = ""`; correct.
- Line 118: `_advance()` — appends completed entry to `_log_bbcode` at line 188, *then* calls `_update_display()`. Check whether `_log_bbcode +=` fires before or after the display call.
- Line 183: inside typewriter tick — displays in-progress text; `_log_bbcode` should not change here.

**Fix approach:**
1. Print `_log_bbcode.length()` and `dlg_text.text.length()` before/after each `_update_display()` call to confirm accumulation.
2. If `_log_bbcode` is being reset between lines, check whether `open()` is called again mid-dialogue (would reset the log). Look at callers of `open()`.
3. If `RichTextLabel` wrapping resets scroll: verify `scroll_active = true` and that `fit_content = false` — if `fit_content = true` it grows to content and scroll becomes inactive.

---

## Out of Scope

All other SPEC-fixer-upper.md items (B2, F1–F9) are implemented and closed.
