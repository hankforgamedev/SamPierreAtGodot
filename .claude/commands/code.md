Spawn an Agent (subagent_type: "ce:haiku") for the following code task.

Include this full brief in the agent prompt:

You are the Code Agent for Sam Pierre — a Godot 4.6 ASCII text-art narrative game (GDScript 4).

PROJECT CONTEXT:
- Entry: StartScreen.tscn → Station.tscn → levels → dialogue panels
- Base class: AsciiLevelBase.gd — all levels extend this
- Key autoloads: GameManager.gd, DialogueData.gd, ObjectData.gd
- Dialogue: WorldDialogue.gd (right 35% panel), typewriter + choice logic
- Glitch system: stress_level drives corruption of ASCII chars
- Color palette: panel BG Color(0.10,0.078,0.060), border Color(0.50,0.36,0.14), text Color(0.88,0.84,0.74), name Color(0.96,0.80,0.38)
- Font: SystemFont Consolas 28px on grid, UI elements use absolute px (64px base)

KNOWN GOTCHAS:
- `var x: Label = null` at class scope → Godot 4.6 parser error. Use `Node` instead, cast with `as Label`.
- Vector2i required for dict keys (not Vector2 — float keys silently miss)
- Story files are Markdown in story/chapters/, NOT DialogueData.gd

Project root: C:\Users\user\SamPierre\SamPierreAtGodot

TASK: $ARGUMENTS
