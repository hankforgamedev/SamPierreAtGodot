extends Node

# ── Line fields ───────────────────────────────────────────────
# speaker  : "sam" | "rat" | "lee" | "rachel" | "sarah" | "bill" | "moujia" | "david" | "narrator"
# text     : String
# active   : "left" | "right" | "none"
# choices  : Array of {"text": String, "goto": int}  ← optional; shows choice buttons
# next     : int  ← optional; overrides default index+1 after this line
# speed    : "fast" | "slow"                         ← optional
# fx       : Array of String                         ← optional; e.g. ["shake", "flash_white"]
# minigame : "civil_servant"                         ← optional; triggers minigame scene

var CHAPTERS : Array = []

func _ready() -> void:
	for id in ["ch1", "ch2", "ch3", "ch4", "ch5", "ch6", "ch7", "ch8", "epilogue"]:
		CHAPTERS.append(StoryLoader.load_chapter("res://story/chapters/%s.md" % id))

func get_chapter(id: String) -> Dictionary:
	for ch: Dictionary in CHAPTERS:
		if ch["id"] == id:
			return ch
	return {}

func get_chapter_index(id: String) -> int:
	for i: int in CHAPTERS.size():
		if (CHAPTERS[i] as Dictionary)["id"] == id:
			return i
	return -1

func get_next_chapter_id(current_id: String) -> String:
	var idx: int = get_chapter_index(current_id)
	if idx >= 0 and idx < CHAPTERS.size() - 1:
		return (CHAPTERS[idx + 1] as Dictionary)["id"] as String
	return ""
