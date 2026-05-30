# Today's goal: SLC instead of MVP

遊玩心得 1st~8th 剩下的 issue
summarize -> extract action item -> spec -> fix

Unable to enable addon plugin at: 'res://addons/gdUnit4/plugin.gd' parsing of config failed.

- [x] add readme
- [x] fix conversation & character dialogue script system
  - md text -> convo options -> scene operational flow outcomes
- [ ] 自動 interact, instad of pressing E/enter/space (etc.)
- [ ] TDD? Paradigm (skill & instruction), then HOOK
- [ ] run godot debugger from commandline to streamline playtest.
  - [ ] godot MCP for claude?
  - [x] LSP available
- [ ] 八次遊玩心得裡面提到的 action items
- [ ] severe code quality issues
  - (INTEGER_DIVISION): Integer division. Decimal part will be discarded.gdscript(30)

- [x] remove obsolete scenes/scripts and deprecated files

- [x] Convert ASCII level maps to full-width (全形) characters
  - Affects StationLevel, OfficeLevel, StreetLevel, RestaurantLevel, AsciiLevelBase
  - WALL_SYMS, \_apply_glitch, \_sym_bbcode, CHAR_ASPECT all updated
  - 19 bad-length rows fixed via Python (to_fw()); Office row 7 desk positions realigned to match objects.md coords

- [x] Unable to enable addon plugin at: 'res://addons/gdUnit4/plugin.gd' parsing of config failed.

- [ ] ask about GDaddons (specifically that GD unit test thingy)

- [x] ask about GD MCP for claude, or can it read from the GD language server (offered by official godot extension for VScode)

path hardcoding ("res://" is fine, that is the intended way. just nothing about device-specific path, especially considering that the developers use different OS and devices to access this repo)

this shit everywhere:

WARNING: Integer division. Decimal part will be discarded.
at: GDScript::reload (res://scripts/WorldDialogue.gd:71)
GDScript backtrace (most recent call first):
[0] go_to_level (res://scripts/GameManager.gd:40)
[1] <anonymous lambda> (res://scripts/DevMenu.gd:30)

- [ ] dialog options that actually have consequences
  - [x] play diff sfx
  - [ ] go to a different scene/chapter
- [ ] the dialog panel logic in ascii scenes should just reuse that of the pure dialog game scenes (chapters)
- [ ] pure dialog scene doesn't seem to be using different typewrite speed setting despite intending to do so. this is the inconsistency caused by the issue mentioned just above.

- [ ] procedural symbol map generator. just make sure NPC & exit can be reached by player.
