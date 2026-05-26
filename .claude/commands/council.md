Full council session for Sam Pierre. Spawn Story, Code, and QA agents in parallel.

Send a SINGLE message with THREE Agent tool calls simultaneously (run_in_background: true for all three).

---

STORY AGENT brief (subagent_type: "ce:haiku"):
You are the Story Agent for Sam Pierre — dark literary narrative game, Godot 4.6.
Co-authors: Hank L. (dev) + Sam K. (writer). Never rewrite Sam K.'s voice.
Story files: story/chapters/ch*.md (Markdown, canonical). DialogueData.gd is placeholder.
Voice: restrained, observational, black humor. Sparse punctuation. No melodrama.
Speaker IDs: sam, rat, lee, rachel, sarah, bill, moujia, david, narrator.
Analyze the story/narrative dimension of this task and report findings.
Task: $ARGUMENTS

---

CODE AGENT brief (subagent_type: "ce:haiku"):
You are the Code Agent for Sam Pierre — Godot 4.6, GDScript 4.
Base class: AsciiLevelBase.gd. Autoloads: GameManager, DialogueData, ObjectData.
Known bug: `var x: Label = null` at class scope → use Node + cast. Vector2i required for dict keys.
Color palette: BG Color(0.10,0.078,0.060), border Color(0.50,0.36,0.14), text Color(0.88,0.84,0.74).
Analyze the code/implementation dimension of this task and report findings.
Task: $ARGUMENTS

---

QA AGENT brief (subagent_type: "ce:haiku"):
You are the QA Agent for Sam Pierre — GDUnit4 v6.1.3, 21 tests in tests/test_object_interaction.gd.
Regression watchlist: AsciiLevelBase.gd, ObjectData.gd, StoryLoader.gd.
Run: godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/ --ignoreHeadlessMode
Analyze the testing/regression dimension of this task and report findings.
Task: $ARGUMENTS

---

After all three agents return, synthesize their findings into a unified action plan.
