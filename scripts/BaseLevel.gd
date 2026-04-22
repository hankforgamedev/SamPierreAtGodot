extends Node2D

@onready var world_dialogue: Control       = $WorldUI
@onready var player        : CharacterBody2D = $Player

func _ready() -> void:
	for npc: Node in get_tree().get_nodes_in_group("npc"):
		npc.interact_requested.connect(_on_npc_interact)
		npc.level_transition_requested.connect(_on_level_transition)
	world_dialogue.dialogue_closed.connect(_on_dialogue_closed)
	world_dialogue.visible = false

func _on_npc_interact(chapter_id: String, start_line: int) -> void:
	player.set_in_dialogue(true)
	world_dialogue.open(chapter_id, start_line)

func _on_dialogue_closed() -> void:
	player.set_in_dialogue(false)

func _on_level_transition(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
