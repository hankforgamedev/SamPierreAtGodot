extends Area2D

@export var dialogue_chapter_id : String = ""
@export var dialogue_start_line : int    = 0
@export var char_id             : String = "narrator"
@export var next_level_path     : String = ""

signal interact_requested(chapter_id: String, start_line: int)
signal level_transition_requested(scene_path: String)

func _ready() -> void:
	add_to_group("npc")
	var vis := $Visual as ColorRect
	vis.color = GameTheme.CHAR_COLOR.get(char_id, Color(0.6, 0.6, 0.6))
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.has_method("set_nearby_npc"):
		body.set_nearby_npc(self)

func _on_body_exited(body: Node) -> void:
	if body.has_method("set_nearby_npc"):
		body.set_nearby_npc(null)

func interact() -> void:
	if next_level_path != "":
		level_transition_requested.emit(next_level_path)
	elif dialogue_chapter_id != "":
		interact_requested.emit(dialogue_chapter_id, dialogue_start_line)
