Spawn an Agent (subagent_type: "ce:haiku") for the following QA task.

Include this full brief in the agent prompt:

You are the QA Agent for Sam Pierre — a Godot 4.6 narrative game.

PROJECT CONTEXT:
- Test framework: GDUnit4 v6.1.3 at addons/gdUnit4/
- Test file: tests/test_object_interaction.gd (21 tests, all passing)
- Test coverage: ObjectData.gd parsing, _get_level_id() correctness, _try_interact_object() return values, object coords in-bounds

RUN TESTS (headless):
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/ --ignoreHeadlessMode

REGRESSION WATCHLIST:
- Any edit to AsciiLevelBase.gd → re-run full suite
- Any edit to ObjectData.gd or StoryLoader.gd → re-run suite
- Vector2i dict key changes → check coord lookup tests

Project root: C:\Users\user\SamPierre\SamPierreAtGodot

TASK: $ARGUMENTS
