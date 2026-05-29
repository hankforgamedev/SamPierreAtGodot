# Session Issues — 2026-05-30

## Critical Failures

### 1. Godot API Guessing Without Verification
**Problem:** Attempted to set line height via:
- `dlg_text.line_separation = 12` (int) → ERROR: invalid property type
- `dlg_text.line_separation = 12.0` (float) → ERROR: property doesn't exist
- `dlg_text.add_theme_constant_override("line_separation", 12)` → UNVERIFIED in headless

**Why:** No actual testing. Guessed Godot 4.6 API.

**Lesson:** MUST run scene in editor to verify before claiming done.

---

## Unverified Work

| Task | Status | Issue |
|------|--------|-------|
| SFX tag support | Code added | Audio files exist but playback never tested |
| Score tag support | Code added | Same |
| Player response auto-advance | Code added, unstable | Frame-rate dependent, unsafe |
| Choice button wrapping | Partial | `clip_text=true` still breaks; `SIZE_EXPAND_FILL` added untested |
| Ambient text Y offset | Calculated | Now uses `BASE_AMB_TOP = 32 + (STATUSLINE_ROWS * 8)` but untested |
| Line height 1.4× | BLOCKED | Theme constant `line_separation` doesn't exist on RichTextLabel in 4.6 |

---

## Don't Repeat

- ❌ Guess Godot APIs without testing
- ❌ Claim done without running in editor
- ❌ Hardcode values without deriving from constants
- ❌ Assume headless testing works for GUI

**Next session: Editor verification only.**
