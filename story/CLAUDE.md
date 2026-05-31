# Story System — Interdependencies

## Files to Update When Adding Dialogue Features

When adding a new **line modifier** (tag) to the dialogue system (like `sfx:`, `score:`, `fx:`), update these files in order:

### 1. **scripts/StoryLoader.gd** — Parse the tag

Add an `elif` branch in `_apply_tag()` (around line 176) that matches the new modifier and writes it to the line dict.

```gdscript
elif p.begins_with("mytag:"):
    entry["mytag"] = p.substr(6)
```

### 2. **scripts/StoryLinter.gd** — Validate the tag

Add validation in `lint_chapter()` (around line 92) after the `fx:` block. Check that the value is valid; if not, call `push_error()`.

```gdscript
elif p.begins_with("mytag:"):
    var val := p.substr(6)
    if val == "":
        push_error("StoryLinter [%s:%d]: mytag: must have a value" % [path, ln])
```

### 3. **scripts/GameScene.gd** — Apply the effect

In `_show_line()` (around line 257), after the Score block and before Typewriter, read the tag from the line dict and execute the effect.

```gdscript
var mytag_val: String = line.get("mytag", "") as String
if mytag_val != "":
    _do_mytag(mytag_val)
```

### 4. **story/editing-guideline.md** — Document for editors

- Add row to "Optional Tag Modifiers" table (line ~94)
- Add example usage in code block (line ~104)
- If applicable, add error case to "What Crashes or Silently Breaks" (line ~139)

## Tags

Canonical tag list:

@editing-guideline.md

To find a tag's code, grep its prefix in `StoryLoader._apply_tag()` (parse) and `StoryLinter.lint_chapter()` (validate).

**Label routing (dev note):** `>>`/`next:` reference a `label:NAME`, not a raw index. `StoryLoader._resolve_refs()` rewrites every label → int index after parse (two-pass), so `GameScene`/`WorldDialogue` stay int-based — no consumer change. `label:` is structural, not a per-line effect, so it skips the "GameScene applies the effect" step of the 4-step tag procedure.

## Key File Refs

- **StoryLoader.gd** — `_apply_tag()` method (L:176-207)
- **StoryLinter.gd** — modifier validation loop (L:76-101)
- **GameScene.gd** — `_show_line()` method (L:215-270)
- **editing-guideline.md** — modifiers table (L:94-104) + examples + errors
