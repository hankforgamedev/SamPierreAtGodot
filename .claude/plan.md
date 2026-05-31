# Story Port & Build Plan

## Status

- **Ported:** ch1 (破處), ch5 (某甲) → game dialogue format ✓
- **Remaining:** ~20-30 chapters yet to be converted into `/story/` root (raw prose to game screenplay markup file)
- **Scenes:** 4 ASCII levels done (Station, Office, Street, Restaurant); ~10 more chapters need dedicated ASCII scenes; ~5+ transit rooms between levels

---

## Phase 1: Bulk Import Pipeline (Chapters 2–8, Epilogue)

Goal: Convert raw prose chapters → dialogue-game format in ~1 batch.

### Step 1: Auto-Extract via Python Script

Write `scripts/story_transform.py` to:

1. Read each `.md` file in `/story/` (not in `/chapters/`)
2. Parse prose into:
   - Opening narrative (context, setting, internal monologue)
   - Dialogue blocks (speaker, text)
   - Action/stage direction (transitions, fight sequences)
3. Infer `speaker` and `position` from context clues (quoted text → who's talking)
4. Output to `/story/chapters/chN.md` with minimal frontmatter (id, title, bg_color, left_char, right_char)
5. Flag ambiguous sections for manual review

**Manual post-pass:** Verify speaker attribution, add missing effects (`speed:`, `fx:`, `sfx:`) based on tone, set label anchors for routing.

### Step 2: Validation & Linting

Run `StoryLinter` on all imported chapters to catch:

- Missing frontmatter fields
- Invalid speaker keys
- Undefined label refs
- Bad hex colors

### Step 3: Playtest & Feedback Loop

Route through chapters sequentially; record:

- Dialogue pacing (speed: tags correct?)
- Visual effects hit right moments?
- Speaker/position correct?
- Any silent parse drops?

---

## Phase 2: ASCII Scene Build (Chapters 1, 3, 5 + ~7 more)

Currently:

- **ch1** (破處 / subway) → `Station.tscn` ✓
- **ch3** (辦公室) → `Office.tscn` ✓
- **ch5** (餐館) → `Restaurant.tscn` ✓
- Transitions: Street.tscn (老蕭→Restaurant link)

### Planned new scenes (~10 chapters):

- [ ] Police precinct? (`ch?` — internal monologue-heavy, needs cell/desk props)
- [ ] Apartment/home? (ch? — flashback or late-night dialogue)
- [ ] ?? (TBD per script review)

### Each new scene:

1. Draft ASCII map in level script (`*Level.gd`)
2. Spawn NPCs + interactables (`.md` coords from `objects.md`)
3. Wire chapter routing (`_get_chapter_id()`)
4. Add dev-menu entry
5. Test keyboard nav + typewriter + glitch scaling

### Transit rooms (~5):

- No story dialogue, just movement & ambiance
- Placeholder: 3x3 room with exit doors
- Upgrade: add ambient text (`levels/transit_*.md`)
- Examples: alley, corridor, stairwell

---

## Phase 3: Dialogue Feature Gaps

Current line modifiers work; missing:

- [ ] **Background music** (looping score) vs **one-shot cinematic** score — tag distinction + playback logic
- [ ] **Portrait/sprite swaps** — e.g., character changes clothes; need a tag to swap `left_char` mid-chapter?
- [ ] **Screen shake intensity** — `fx:shake` is hardcoded; parametrize?
- [ ] **Pause length** — currently implicit in line structure; need `pause:Xs` tag?

---

## Open Items from Backlog

### Resolved ✓

- [x] Remove obsolete scenes/scripts
- [x] Convert ASCII maps to full-width (全形)
- [x] Integer division warning (WorldDialogue.apply_scale)
- [x] Dialog options with consequences
- [x] Per-line typewriter speed
- [x] Procedural symbol map generator
- [x] Dev menu (Ctrl+WASD, keyboard nav, GameTheme styling)
- [x] StartScreen quit button (gag)
- [x] Interactable object hints (pulsed amber)
- [x] Chapter cards in ASCII scenes
- [x] Inner-voice emphasis ([wave] for CJK)

### Pending

- [ ] **Auto-advance player (`sam`) lines in `WorldDialogue`** — current `call_deferred` guard works, but edge cases remain; may need explicit state machine
- [ ] **GDUnit4 plugin integration** — tests for dialogue routing + mini-game return path (resume_line → resync chapter state)
- [ ] **Auto-interact NPC** — press E required; design: auto-trigger on proximity or require explicit E? (impacts world pacing + immersion)
- [ ] **Hardcoded path audit** — no device-specific paths found; verify after bulk import that all refs use `res://` canonical form
- [ ] **Glitch system edge cases** — high stress_level → can grid become unreadable? Clamp chaos pool density?
- [ ] **Playtest feedback from 8+ sessions** — extract action items from notes in `/playtest_records/` (if saved)
- [ ] **Screen reader / accessibility** — future: audio descriptions for blind/low-vision; captions for deaf (not blocking initial launch)

---

## Skill Split (for Parallel Work)

Once plan approved:

- **SK (code):** `story_transform.py` script, ASCII map builds, feature gaps
- **HankL (story):** Post-transform manual pass (speaker/effect verification), scene breakdown for new ASCII levels

---

## Timeline Estimate

- Phase 1 (auto-extract): ~2h (script build + validation loop)
- Phase 1 (manual review): ~4h (HankL + SK pair)
- Phase 2 (new ASCII scenes): ~1d per scene (map draft, props, testing)
- Phase 3 (dialogue features): ~4h each

**Total to playable "first loop" (all chapters, 4 ASCII scenes):** ~1 week aggressive, ~2 weeks measured.

---

## Notes for Future

- Keep `.md` source of truth; engine reads at runtime
- Frontmatter fields must match `StoryLoader` expectations (see `story/CLAUDE.md`)
- Label routing is case-insensitive but ALL-CAPS by convention
- No hardcoded chapter indices — all routing via `id` field
