---
name: avoiding-shishan-code
description: Prevents 屎山代碼 (code rot) in the Sam Pierre Godot project. Use when writing, refactoring, or reviewing any GDScript, scene, or tool script — especially when adding a new system, copying code between files, or deciding whether to keep an old file.
---

# Avoiding 屎山代碼

**Core principle:** Every commit either shrinks the mountain or grows it. Git history is the archive — the working tree is not a museum.

## Hard Rules

| Rule | Concrete meaning in this repo |
|------|-------------------------------|
| Delete, don't deprecate | A file superseded by new code is deleted in the same commit. No "kept but unused" scripts, no `## Deprecated` sections in CLAUDE.md growing over time. |
| No junk files | `*.tmp`, `*.uid*.tmp`, editor backup files never get committed. If found tracked, untrack and gitignore them. |
| One source of truth | Shared constants (color palette, character names) live in exactly one place (autoload or shared script). Story text lives in DialogueData / story files — never hardcoded in scene scripts, node metadata, or UI code. |
| Extract before the second copy | Copying a helper function into a second file is the signal to extract it into a shared class. Applies to `tools/build_*.gd` geometry helpers and per-script UI styling. |
| One script, one job | Scene host, UI component, player controller, and data are separate scripts. A script that mixes viewport setup + UI construction + dialogue state is over budget — split it. |
| Extend, don't parallel | Before writing system #2 for something (dialogue, levels, interaction), extend system #1 or replace it entirely. Two half-systems for one job is the definition of 屎山. |
| Boy-scout rule, scoped | When editing a file, delete its dead code and stale comments. Don't refactor unrelated files in the same commit. |

## Decision Test

Before adding any file or system, answer:

1. Does something in the repo already do 80% of this? → extend it.
2. Will this make an existing file obsolete? → delete that file now.
3. Am I about to copy more than ~5 lines from another file? → extract shared code first.

## Known Debt (delete on sight when touching related code)

- `scripts/BaseLevel.gd`, `scripts/PlayerController.gd`, `scripts/NPC.gd` — superseded by ASCII system, unused
- `scenes/Chapter1.tscn`, `scripts/Chapter1.gd` — deprecated per CLAUDE.md
- Tracked `*.tmp` files (`project.godot*.tmp`, `*.uid*.tmp`, `scripts/Start.tscn*.tmp`)
- Color palette constants duplicated per-script instead of shared
