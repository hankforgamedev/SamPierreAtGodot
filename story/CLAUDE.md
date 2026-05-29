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

## Current Tags

| Tag | Parser | Linter | GameScene | Docs |
|-----|--------|--------|-----------|------|
| `speed:` | L:198 | L:88-91 | (built-in typewriter) | G:96 |
| `fx:` | L:199-203 | L:92-99 | (not yet impl.) | G:97, 102 |
| `sfx:` | L:204-205 | L:100-102 | GS:265-267 | G:97 |
| `score:` | L:206-207 | L:103-105 | GS:257-261 | G:98 |
| `next:` | L:195-196 | L:84-87 | (built-in) | G:99 |
| `choices` | L:191-192 | L:80-81 | GS:252-255 | G:100 |
| `minigame` | L:193-194 | L:82-83 | GS:218-222 | G:100 |

## Key File Refs

- **StoryLoader.gd** — `_apply_tag()` method (L:176-207)
- **StoryLinter.gd** — modifier validation loop (L:76-101)
- **GameScene.gd** — `_show_line()` method (L:215-270)
- **editing-guideline.md** — modifiers table (L:94-104) + examples + errors
