# Story Editing Guide

Story lives entirely in `story/`. The engine parses these Markdown files at runtime — no recompile needed. Bad syntax silently drops lines or crashes the chapter; errors appear in Godot's Output panel automatically when the game loads.

---

## File Layout

```
story/
  chapters/    ch1.md … ch8.md, epilogue.md   ← dialogue & story
  levels/      station.md, office.md …         ← ambient + intro text for world
  minigame.md                                  ← civil servant mini-game content
  objects.md                                   ← interactable object descriptions
  editing-guideline.md                         ← this file
```

---

## Chapter File Structure

Every chapter file has two parts: **frontmatter** (metadata) and **body** (dialogue lines).

```
---
id: ch1
title: Chapter 1 — 破處
bg_color: #0f0f1a
left_char: sam
right_char: rat
---

[body starts here]
```

### Frontmatter Fields

| Field | Required | Format | Notes |
|---|---|---|---|
| `id` | YES | `ch1` … `ch8`, `epilogue` | Must match filename; used for cross-chapter routing |
| `title` | YES | any string | Shown on chapter card |
| `bg_color` | recommended | `#rrggbb` hex | Background color; crash if invalid hex format |
| `left_char` | recommended | character key | Who appears on the left panel |
| `right_char` | recommended | character key | Who appears on the right panel |

**Character keys** (valid values for `left_char`, `right_char`, `speaker`):

| Key | Display name | Color |
|---|---|---|
| `sam` | 山姆·皮耶爾 | light grey |
| `rat` | 老鼠 | green |
| `lee` | 李先生 | gold |
| `rachel` | 瑞秋 | blue |
| `sarah` | 莎拉（母） | purple |
| `bill` | 比爾 | orange |
| `moujia` | 某甲 | red |
| `david` | 大衛 | teal |
| `narrator` | (no name shown) | grey |

---

## Body Syntax

### Dialogue Line

```
[speaker position] text goes here
more text on next line (joined automatically)
```

A tag `[...]` starts a new entry. Text on the tag line and all following lines (until the next tag) become that entry's dialogue text.

**`speaker`** — one of the character keys above, or `_none` (shorthand for narrator with no portrait active).

**`position`** — `left`, `right`, or `none` (controls which portrait is highlighted).

```
[sam left] 「為甚麼列寧喜歡穿皮鞋……」

[narrator none] 末班車進站。
皮耶爾把老鼠拽向軌道，用力一推。

[_none] (shorthand — same as [narrator none])
```

### Optional Tag Modifiers

Modifiers go inside `[...]` after the position, separated by spaces.

```
[speaker position modifier1 modifier2]
```

| Modifier | Format | Effect |
|---|---|---|
| `speed:fast` / `speed:slow` | `speed:fast` | Typewriter speed |
| `fx:NAME,NAME` | `fx:shake,flash_white` | Visual effect(s) — **comma-separated, no spaces** |
| `sfx:NAME` | `sfx:riser` | Sound effect from `audio/sfx/` |
| `score:NAME` | `score:251019_001` | Non-looping score from `audio/score/` (blocks advance until finish) |
| `next:N` | `next:14` | After this line, jump to line index N (0-based) instead of next |
| `choices` | `choices` | Marks this line as a choice prompt — follow with `- ` choice lines |
| `minigame` | `minigame` | Triggers the civil servant mini-game, then returns here |

**Valid `fx` values:** `shake`, `flash_white`, `flash_black`, `glitch_spike`

**`sfx` and `score` values** — filenames without extension from their respective directories. SFX files can be `.wav` or `.mp3`; score files must be `.mp3`.

```
[narrator none speed:fast fx:shake,flash_white sfx:riser]
老鼠從皮靴內側抽出一把蝴蝶刀，衝向皮耶爾。

[narrator none speed:slow fx:glitch_spike]
「最可悲的是，在我死之前……」

[narrator score:251019_001 none]
《SAM PIERRE》
```

### Choices

A `choices` line must be immediately followed by `- ` lines. Each choice needs a `>> N` jump target (0-based line index).

```
[rat right choices]
「借些錢花花吧……」
- 「你比上次還要嗨，夥計。」 >> 14
- （沉默，繼續抽菸） >> 16
- 「我沒有錢。」 >> 16
```

To find the right index N: count `[tag]` lines in the file starting from 0. Each `[...]` tag = one entry.

### Multi-line Text

Blank lines inside an entry are preserved. Blank lines between entries are ignored.

```
[narrator none]
第一行。

第二行（中間有空行也沒關係）。
```

---

## What Crashes or Silently Breaks

| Mistake | Effect |
|---|---|
| Tag missing `]` — `[sam left` | Entry silently dropped, all text lost |
| `bg_color` not valid hex — `bg_color: dark blue` | Godot error on chapter load |
| Space in `fx:` — `fx:shake, flash_white` | `" flash_white"` not recognized, effect silently ignored |
| Unknown speaker — `[john left]` | No name/color shown; portrait blank |
| `next:abc` (non-integer) | Jumps to line 0, likely wrong |
| CRLF line endings (Windows) | Speaker parsed as `"sam\r"` — no name/color shown |
| Missing frontmatter `id` | Chapter can't be found by router; game skips it |
| Choice missing `>>` | Choice shows but goes nowhere useful (goto -1) |
| `sfx:missing_file` or `score:missing_file` | File not found; playback silently skipped |

---

## Error Checking

Errors surface automatically in Godot's **Output panel** (bottom of editor) when a chapter loads. Look for lines starting with `StoryLinter [filename:line]:`. Fix the issue in the `.md` file, save, and re-run the game — no extra tools needed.

---

## Level Files (`levels/*.md`)

Used for ambient text in the ASCII world — not for story dialogue.

```
level_name: [ 虎寨城地鐵站 // LINE 3 // 02:47 ]

## intro

Intro text shown when player enters the level.

## ambient 44,9

before: Text shown before the player talks to the NPC at grid (44,9).
after: Text shown after.
```

Section headers must be `## intro` or `## ambient X,Y` (grid coords). `before:` and `after:` are single-line values on the same line.

---

## Objects File (`objects.md`)

Interactable objects in the world. Format:

```
# StationLevel

44,9: Text shown when player presses E on this tile.
12,3: Another object description.

# OfficeLevel

5,8: …
```

Section header must be `# LevelName` matching the level script's `_get_level_name()`. Coords are `X,Y` integers.
