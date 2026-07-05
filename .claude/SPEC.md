# SPEC.md — Story Engine & Content Pipeline

Fully consolidates and replaces `.claude/backlog_prev_playtest.md` and `.claude/plan.md` (both deleted, content merged below — this is now the only copy). This is the source of truth for what v1 is; a fresh `.claude/plan.md` should be written next to break the Design Decisions + Tactical Backlog below into implementation steps.

## Goal

A Mandarin-native, keyboard-first narrative game (Godot 4.6, GDScript) mixing ASCII-grid world scenes with visual-novel dialogue sequences, adapted from an existing prose story (~20-30 chapters, partially converted). Built by a two-person team: SK (code) and HankL (writer, non-coder). This spec defines the mechanics, data model, and workflow needed to take the *existing* partial port to a complete, playable start-to-end experience.

## Workflow (process convention, not enforced folder structure)

**IDEA → SPEC → PLAN → CODE → TEST & PLAYTEST**, looped per feature/phase:

1. Idea raised (either party)
2. `SPEC.md` updated if the idea changes scope/behavior (this file)
3. `.claude/plan.md` updated with concrete steps
4. Code written
5. Tested (unit/manual) and playtested (full scene walkthrough)

No new `.claude/ideas/`, `.claude/specs/` directories — this is documented convention only, kept in `CLAUDE.md`.

## Scope — v1 stop criteria

**v1 is done when:** all existing raw prose chapters are converted to screenplay format, wired into the transition graph (see below), and a player can play start-to-end with no missing scenes or dead ends. Polish items (VFX richness, portraits, full save/load) are explicitly allowed to lag behind this.

Out of scope for v1 (deferred, tracked as backlog):
- Character portraits/art (text+ASCII only for v1)
- Full save/load with slots (v1 gets minimal auto-checkpoint only)
- Accessibility (screen reader, captions) — future, not blocking
- Bulk import of remaining chapters is **infrastructure-now, execution-later** — raw text (HankL) is still being written; the pipeline (Phase 1 below) should exist and be validated on available chapters, but importing all ~20-30 is not gated on this spec being "done."

## Design Decisions

### 1. Mandatory interaction before scene exit

ASCII scenes get a per-NPC `mandatory: true` flag in the existing NPC dict (`{Vector2i: {chapter_id, start_line, char_id, display, mandatory}}`). If any NPC in a scene is flagged mandatory and hasn't been talked to, the exit tile is **hard-blocked** (acts like a wall/collider) until that dialogue has triggered at least once. Pure transit scenes (no mandatory NPCs) are unaffected — exits stay open by default.

### 2. No dialogue replay of completed long-form conversations

Track a per-NPC "completed" flag (persisted at least for session, ideally in the checkpoint save). Re-interacting (E-press) with an NPC whose full dialogue has already played shows one short, hand-authored filler/acknowledgement line instead of replaying the whole thing. This avoids forcing players to re-sit through paragraph-by-paragraph advance on content they've seen, since there's no "skip all" — only "next paragraph."

### 3. Auto-advance: line tag + global player setting

Two independent layers, both required:
- **Author-side**: `auto_advance` per-line tag in the dialogue schema, alongside existing `speed:`/`fx:`/`sfx:` tags. Default off if unset. Lets HankL force specific narration beats to auto-play (e.g. rapid internal-monologue bursts).
- **Player-side**: a new **Settings screen** (accessible from StartScreen and in-game pause) with an auto-advance on/off toggle and a typewriter-speed slider, persisted to a config file across sessions. Because reading speed varies per player and per playthrough state, this shouldn't be author-guessed alone.
- **Convenience**: a quick keybind (mid-dialogue) to toggle auto-advance on/off without opening the settings screen, for players who don't want to leave the flow to tune it.

This replaces the current `call_deferred`/`_auto_advance_queued` guard behavior in `WorldDialogue`, which is reported as unintuitive.

### 4. Pipeline: raw text → screenplay → scene

Formalized three-stage content pipeline:
```
文本 (raw prose, /story/*.md)
  → 遊戲對話劇本 (screenplay format, /story/chapters/chN.md — speaker/text/tags)
    → ASCII world scene (WorldDialogue + AsciiLevelBase)  OR  pure VN scene (GameScene)
```
The `story_transform.py` script (Phase 1 in old plan.md) automates stage 1→2; stage 2→3 (which scenes get ASCII treatment vs pure VN) remains an editorial/manual decision per chapter.

### 5. Drop chapter numbers → transition graph model

Numeric chapter ordering (`current_chapter_id` as sequence index) is replaced by a **string-`id`-based transition graph**, inspired loosely by Detroit: Become Human's flowchart (without its branching complexity — this story is not meant to have multiple branching endings, just non-linear scene routing/hubs like the Station/Street/Office/Restaurant hub-and-spoke that already exists).

- **Storage**: GDScript data array, same pattern as current `DialogueData.CHAPTERS` — new `SceneGraph.gd` with nodes:
  ```
  { id: String, type: "ascii" | "vn", scene_path: String, entry_line: int,
    transitions: [{ to: String, condition: <optional> }] }
  ```
  No new file formats or Inspector tooling — stays consistent with existing hand-edited GDScript data style.
- **Chapter cards**: still shown on scene entry, but display a **title only**, no ordinal number (routing no longer implies "chapter 5 comes after chapter 4" — the graph can have hubs/loops).
- All routing (`_get_chapter_id()`, `GameManager.start_chapter()`, etc.) migrates from numeric index lookups to `id`-string lookups against `SceneGraph`.

### 6. Checkpoint save (minimal, not full save/load)

Auto-checkpoint at scene/node entry (graph node transition = save point). No manual save slots, no save menu. Closing the game and reopening resumes at the last entered node. Full save/load system is deferred post-v1, once the graph model has stabilized (building persistence against a still-changing data model was flagged as premature).

### 7. Insanity VFX — new dedicated system

For scenes where the protagonist's sanity breaks, build a **separate VFX layer** from the existing ASCII glitch system (`stress_level` + chaos-pool overlay in `AsciiLevelBase`) — shader-based screen effects, audio distortion, etc., triggered by story flags. Kept independent because the existing glitch system is tuned for ambient world-corruption flavor, not a dramatic sanity-break set-piece; conflating the two risks compromising both.

### 8. Portraits/assets

Text-only for v1 — no character portrait art planned. ASCII-world + colored speaker names (current `GameTheme.CHAR_COLOR`/`CHAR_HEX`) remains the visual language. Portraits are a stretch goal, out of scope until story content is substantially complete.

## Principles

### DX (developer experience)
- GDScript, interpreted, no build step — F5/F6 in Godot 4.6 editor is the primary dev loop (see CLAUDE.md "Running the Project").
- Godot MCP + LSP tooling already available — use for scene/script inspection instead of manual editor screenshots where possible.
- Data-as-code: story content, NPC placement, and now the transition graph all live in plain GDScript arrays/dicts — no external DSLs, no custom Resource/Inspector tooling, so both SK and (with light guidance) HankL can read/edit source files directly.

### UX
- **Keyboard-first**: every menu, dialogue, and world interaction must be fully keyboard-navigable (existing principle, `design_keyboard_first`). New Settings screen and quick-toggle auto-advance keybind must follow this — no mouse-only controls.
- **Readability**: full-width (全形) CJK typography in ASCII scenes, no mixed-width chars; no italic (CJK fonts have none) — emphasis via color/size/animated BBCode (`[wave]`/`[pulse]`/`[shake]`) per existing `GameTheme` conventions.
- **Controls should feel smooth**, not fight the player: this spec's replay-avoidance (item 2) and player-tunable auto-advance (item 3) both exist specifically to fix reported friction (forced re-reads, unintuitive auto-advance).

### Game feel
- Humor/jokes, narration voice, and story beats are HankL's domain (screenplay content).
- VFX (glitch overlay, new insanity system), light/shadow, animation, SFX/music are engine-side levers that should react to *story state* (stress_level, sanity flags, chapter/node context) rather than being static per-scene decoration.
- Music: distinguish looping background score vs one-shot cinematic score (carried over from old plan.md Phase 3 — still open, tag distinction + playback logic not yet implemented).

## Current Status & Tactical Backlog

*(merged from old `.claude/plan.md` / `.claude/backlog_prev_playtest.md`, both deleted — this is now the only copy)*

### Status snapshot (as of 2026-07-05)
- **Ported to game format:** ch1 (破處), ch5 (某甲)
- **Remaining:** ~20-30 chapters still raw prose, not yet converted
- **ASCII scenes built:** Station, Office, Street, Restaurant (4 total)
- **Still needed:** ~10 more dedicated ASCII scenes, ~5+ transit rooms between levels

### Phase 1 — Bulk Import Pipeline (chapters 2-8, epilogue)
Goal: convert raw prose → screenplay format in one batch.
1. **Auto-extract script** (`scripts/story_transform.py`): read each `.md` in `/story/` (not `/chapters/`), parse into opening narrative / dialogue blocks (speaker+text) / action-stage-direction, infer speaker+position from quote context, output `/story/chapters/chN.md` with minimal frontmatter (id, title, bg_color, left_char, right_char), flag ambiguous sections for manual review.
2. **Manual post-pass** (HankL+SK): verify speaker attribution, add missing `speed:`/`fx:`/`sfx:` tags, set label anchors for routing.
3. **Validation**: run `StoryLinter` — catches missing frontmatter fields, invalid speaker keys, undefined label refs, bad hex colors.
4. **Playtest loop**: route through sequentially, record pacing correctness, VFX timing, speaker/position accuracy, silent parse drops.

Per this SPEC's scope decision: this phase is infrastructure to build now; full execution across all chapters waits on HankL finishing the raw text.

### Phase 2 — ASCII Scene Build
Planned new scenes (~10, TBD per script review):
- [ ] Police precinct (internal-monologue-heavy; needs cell/desk props)
- [ ] Apartment/home (flashback or late-night dialogue)
- [ ] others TBD

Per-scene checklist: draft ASCII map in level script → spawn NPCs/interactables from `objects.md` coords → wire routing (migrate to `SceneGraph` id per Design Decision 5, not `_get_chapter_id()` chapter-index) → add DevMenu entry → test keyboard nav + typewriter + glitch scaling.

Transit rooms (~5, e.g. alley/corridor/stairwell): no story dialogue, just movement/ambiance. Placeholder = 3x3 room with exit doors; upgrade = ambient text via `levels/transit_*.md`. Free-exit by default per Design Decision 1 (no mandatory NPC).

### Phase 3 — Dialogue Feature Gaps (still open, unaffected by this SPEC except where noted)
- [ ] Background music (looping) vs one-shot cinematic score — tag distinction + playback logic
- [ ] Portrait/sprite swaps mid-chapter — deferred, see Design Decision 8 (no portraits planned for v1 at all)
- [ ] Screen-shake intensity parametrization (`fx:shake` currently hardcoded)
- [ ] Explicit `pause:Xs` tag (currently implicit in line structure)

### Resolved ✓ (carried forward for history, already shipped)
Remove obsolete scenes/scripts · convert ASCII maps to full-width (全形) · fix integer division warning (WorldDialogue.apply_scale) · dialog options with consequences · per-line typewriter speed · procedural symbol map generator · dev menu (Ctrl+WASD, keyboard nav, GameTheme styling) · StartScreen quit button (gag) · interactable object hints (pulsed amber) · chapter cards in ASCII scenes · inner-voice emphasis ([wave] for CJK) · readme added · conversation/dialogue script system fixed · Godot debugger CLI · Godot MCP + LSP available.

### Pending (not yet superseded by a SPEC decision above)
- [ ] **GDUnit4 plugin integration** — tests for dialogue routing + mini-game return path (resume_line → resync chapter state)
- [ ] **Auto-interact NPC** — design choice: proximity trigger vs explicit E-press? (affects world pacing/immersion; separate from the mandatory-exit-block decision, which only concerns *exiting*, not *entering* dialogue)
- [ ] **Hardcoded path audit** — verify all refs use `res://` canonical form once bulk import lands
- [ ] **Glitch system edge cases** — can high `stress_level` make the grid unreadable? Clamp chaos pool density?
- [ ] **Playtest feedback extraction** from 8+ prior sessions, if notes saved in `/playtest_records/`

### Skill split (once tactical plan re-approved)
- **SK (code)**: `story_transform.py`, ASCII map builds, `SceneGraph` migration, feature gaps
- **HankL (story)**: post-transform manual pass (speaker/effect verification), scene breakdown for new ASCII levels

### Timeline estimate (rough, pre-SPEC — revisit when plan.md is rewritten)
Phase 1 auto-extract ~2h, manual review ~4h (HankL+SK pair); Phase 2 ~1 day per new scene; Phase 3 ~4h per feature. Rough total to a playable "first loop" (all chapters, 4 ASCII scenes): ~1 week aggressive, ~2 weeks measured. Superseded by v1 stop criteria above (full text conversion + full graph), which is larger scope than this original estimate covered.

### Notes for future implementers
- `.md` files stay source of truth; engine reads at runtime — no compiled/baked story data
- Frontmatter fields must match `StoryLoader` expectations (see `story/CLAUDE.md`)
- Label routing is case-insensitive but ALL-CAPS by convention
- No hardcoded chapter indices — all routing via `id` field (now formalized as the `SceneGraph` node id, Design Decision 5)

## Open Questions

- Exact node granularity for `SceneGraph`: does every dialogue-choice branch get its own node, or only scene/chapter-level transitions? (Current assumption: scene/chapter-level only — in-scene branching stays inside the screenplay's `choices`/`goto` mechanism, not the graph.)
- Text completion timeline: raw prose is still being actively written by HankL — no committed date for when all ~20-30 chapters will be ready for bulk import. Revisit Phase 1 execution timing once closer.
- Checkpoint save data format/location not yet designed (what state beyond "current node id" needs persisting — completed-NPC flags from item 2, settings from item 3, stress_level?).
- Portrait/asset stretch-goal timing not committed — revisit once text conversion is substantially complete.
- Background-music vs one-shot-score tag design (old plan.md Phase 3, item 1) still unresolved.
- Screen-shake intensity parametrization and explicit `pause:Xs` tag (old plan.md Phase 3, items 3-4) still open.
- GDUnit4 test integration and hardcoded-path audit (old plan.md "Pending") still open, unaffected by this spec.

## Out of Scope for v0/v1 (deferred)

- Full save/load (multiple slots, manual save menu)
- Character portrait art
- Accessibility features (screen reader, captions)
- Branching/multiple-ending complexity in the transition graph (kept simple, hub-and-spoke — not a full Detroit-style branching narrative)
- Formal enforced spec/plan/idea folder structure (process stays convention-only)
- Full bulk import execution of all remaining chapters (pipeline built now, execution follows text completion)
