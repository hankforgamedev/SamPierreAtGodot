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
	"inner":    "[心]",
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
	"inner":    "",
}

func start_chapter(chapter_id: String) -> void:
	current_chapter_id = chapter_id
	SoundManager.stop_score()
	SoundManager.stop_ambient()
	get_tree().change_scene_to_file("res://scenes/GameScene.tscn")

func go_to_level(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
