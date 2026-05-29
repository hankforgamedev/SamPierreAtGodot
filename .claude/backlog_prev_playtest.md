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

Unable to enable addon plugin at: 'res://addons/gdUnit4/plugin.gd' parsing of config failed.

ask about GDplugin and addons (specifically that GD unit test thingy)

ask about GD MCP for claude, or can it read from the GD language server (offered by official godot extension for VScode)

path hardcoding ("res://" is fine, that is the intended way. just nothing about device-specific path, especially considering that the developers use different OS and devices to access this repo)
