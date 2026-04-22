extends Control

var dialogues = [
	{"speaker": "山姆·皮耶爾", "text": "又結束了糟糕的一天。", "active": "sam"},
	{"speaker": "山姆·皮耶爾", "text": "他從警局大門走了出來，無奈地嘆了口氣，點了一根卡斯特。", "active": "sam"},
	{"speaker": "山姆·皮耶爾", "text": "年久失修的長椅上，皮耶爾坐著。嘎吱——", "active": "sam"},
	{"speaker": "老鼠", "text": "嘿……山姆，對嗎？好久不見，呵。", "active": "rat"},
	{"speaker": "山姆·皮耶爾", "text": "我們見過嗎？", "active": "sam"},
	{"speaker": "老鼠", "text": "你怎麼這麼無情？我可是你老媽的情人，哈哈……", "active": "rat"},
	{"speaker": "山姆·皮耶爾", "text": "原來是你啊，老鼠。", "active": "sam"},
]

var current_index = 0

func _ready():
	show_dialogue(current_index)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		advance()
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		advance()

func advance():
	current_index += 1
	if current_index >= dialogues.size():
		# 結束第一章
		get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")
		return
	show_dialogue(current_index)

func show_dialogue(index: int):
	var d = dialogues[index]
	$DialogueBox/DialogueLayout/SpeakerName.text = d["speaker"]
	$DialogueBox/DialogueLayout/DialogueText.text = d["text"]
	# 高亮當前角色
	$StageArea/SamIcon.modulate = Color(1, 1, 1, 1) if d["active"] == "sam" else Color(0.5, 0.5, 0.5, 0.5)
	$StageArea/RatIcon.modulate = Color(1, 1, 1, 1) if d["active"] == "rat" else Color(0.5, 0.5, 0.5, 0.5)
