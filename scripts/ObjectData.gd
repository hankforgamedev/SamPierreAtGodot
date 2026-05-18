extends Node

var OBJECTS: Dictionary = {}

func _ready() -> void:
	OBJECTS = StoryLoader.load_objects("res://story/objects.md")
