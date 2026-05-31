# Today's goal: SLC instead of MVP

遊玩心得 1st~8th 剩下的 issue
summarize -> extract action item -> spec -> fix

Unable to enable addon plugin at: 'res://addons/gdUnit4/plugin.gd' parsing of config failed.

- [x] add readme
- [x] fix conversation & character dialogue script system
  - md text -> convo options -> scene operational flow outcomes
- [ ] 自動 interact, instad of pressing E/enter/space (etc.)
- [ ] TDD? Paradigm (skill & instruction), then HOOK
- [x] run godot debugger from commandline to streamline playtest.
  - [x] godot MCP for claude?
  - [x] LSP available
- [ ] 八次遊玩心得裡面提到的 action items
  - @playtest_records/

- [x] remove obsolete scenes/scripts and deprecated files

- [x] Convert ASCII level maps to full-width (全形) characters
  - Affects StationLevel, OfficeLevel, StreetLevel, RestaurantLevel, AsciiLevelBase
  - WALL_SYMS, \_apply_glitch, \_sym_bbcode, CHAR_ASPECT all updated
  - 19 bad-length rows fixed via Python (to_fw()); Office row 7 desk positions realigned to match objects.md coords

- [x] Unable to enable addon plugin at: 'res://addons/gdUnit4/plugin.gd' parsing of config failed.

- [ ] ask about GDaddons (specifically that GD unit test thingy)

- [x] ask about GD MCP for claude, or can it read from the GD language server (offered by official godot extension for VScode)

- [ ] make sure no path hardcoding ("res://" is fine, that is the intended way. just nothing about device-specific path, especially considering that the developers use different OS and devices to access this repo)

- [x] Integer division warning (`WorldDialogue.apply_scale`) — fixed with `roundi(float(...)/float(...))`. Import now clean.

~~this shit everywhere:~~ (resolved)

~~WARNING: Integer division. Decimal part will be discarded.
at: GDScript::reload (res://scripts/WorldDialogue.gd:71)~~

- [x] dialog options that actually have consequences
  - [x] play diff sfx
  - [x] go to a different scene/chapter (label routing + `next_level:`/`next_chapter:` on choices)
- [~] the dialog panel logic in ascii scenes should just reuse that of the pure dialog game scenes (chapters)
  - PARTIAL: shared `Typewriter.gd` (reveal cadence + speed); render kept distinct on purpose (VN page-flip vs world-dialog log-append). `_build_choices`/`_select_choice` still per-file.
- [x] pure dialog scene now uses per-line typewriter speed (GameScene reads `speed:` via Typewriter; was hardcoded NORMAL)

- [x] procedural symbol map generator (`ProceduralMapGen.gd`, flood-fill reachability for NPC + exit)

---

## New Ideas (9th review)

- [x] **1. DX / dev menu** — (a) ctrl+WASD / ctrl+arrows dash to next wall (`AsciiLevelBase._input` + `_dash_dir`); (b) dev menu keyboard nav (first button `grab_focus`); (c) dev menu uses `GameTheme` + rebuilt layout (bg, 64px margins, content-width buttons, no full-width stretch).
- [x] **2. StartScreen quit btn** — no real quit (web/native users quit themselves). Now a gag: press → btn text "你不能" in red (`StartScreen._on_quit`).
- [x] **3. Interactable object hints** — object cells now render pulsed amber (`GameTheme.C_OBJECT_HINT`, `[pulse]` in `AsciiLevelBase._draw_map`) so they're discoverable.
- [x] **4. Chapter cards in ascii scenes** — `ChapterCard.gd` (shared full-screen card) shown on scene ENTER, one scene = one chapter (`AsciiLevelBase._get_chapter_id()`: Station→ch1, Office→ch3, Restaurant→ch5). Not per-NPC-talk.
- [x] **5. Inner-voice emphasis** — `[i]` italics dropped: CJK has no italic cut; Godot fakes oblique → glyphs vanish on web (缺字). Replaced with web-safe animated BBCode `[wave]` (see `GameTheme.INNER_FX_OPEN/CLOSE`; swap to `[pulse]`/`[shake]`). Bold now wired (`SourceHanSerifTC-Bold` → `bold_font` slot), so `[b]` works for CJK. For styling: color + font_size + animated effects.
