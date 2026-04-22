extends Node

var current_chapter_id: String = "ch1"
var resume_line: int = 0

const CHAR_LABELS = {
	"sam":      "[SAM]",
	"rat":      "[鼠]",
	"lee":      "[李]",
	"rachel":   "[瑞]",
	"sarah":    "[母]",
	"bill":     "[比]",
	"moujia":   "[甲]",
	"david":    "[衛]",
	"narrator": "[  ]",
}

const CHAR_COLORS = {
	"sam":      Color(0.85, 0.85, 0.85),
	"rat":      Color(0.4, 0.8, 0.4),
	"lee":      Color(0.9, 0.75, 0.2),
	"rachel":   Color(0.5, 0.7, 0.95),
	"sarah":    Color(0.8, 0.5, 0.85),
	"bill":     Color(0.9, 0.5, 0.2),
	"moujia":   Color(0.9, 0.3, 0.3),
	"david":    Color(0.5, 0.7, 0.8),
	"narrator": Color(0.5, 0.5, 0.5),
}

const SPEAKER_NAMES = {
	"sam":      "山姆·皮耶爾",
	"rat":      "老鼠",
	"lee":      "李先生",
	"rachel":   "瑞秋",
	"sarah":    "莎拉（母）",
	"bill":     "比爾",
	"moujia":   "某甲",
	"david":    "大衛",
	"narrator": "",
}

func start_chapter(chapter_id: String) -> void:
	current_chapter_id = chapter_id
	get_tree().change_scene_to_file("res://scenes/GameScene.tscn")

func go_to_level(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
