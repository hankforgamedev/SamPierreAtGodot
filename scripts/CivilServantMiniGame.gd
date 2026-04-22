extends Control

const C_BG       := Color(0.062, 0.048, 0.038)
const C_PANEL    := Color(0.10,  0.078, 0.060)
const C_BORDER   := Color(0.50,  0.36,  0.14)
const C_AMBER    := Color(0.96,  0.80,  0.38)
const C_BODY     := Color(0.88,  0.84,  0.74)
const C_DIM      := Color(0.50,  0.42,  0.30)
const C_RED      := Color(0.85,  0.25,  0.20)
const C_GREEN    := Color(0.30,  0.72,  0.30)

const QUOTA      := 6
const LEE_CHANCE := 0.35

const NAMES := [
	"陳大腸","王八蛋","李狗蛋","張三豐","趙大柱",
	"錢多多","孫無敵","周小明","吳無聊","鄭無奈",
	"林北北","黃有錢","劉不才","徐沒用","許無名",
	"曾被捕","馮好人","蔡壞人","潘混混","謝天謝地",
]

const CHARGES := [
	"深夜在公共場所朗誦詩歌",
	"擾亂公共秩序（對著牆壁大叫）",
	"無照販賣臭豆腐",
	"偷竊一個便當（價值八十元）",
	"散布謠言（內容：市長是豬）",
	"非法持有過期牛奶",
	"在地鐵站連續打嗝超過三次",
	"拒絕配合警察詢問（原因：問題太無聊）",
	"塗鴉（內容：明日政府倒台）",
	"持有危險物品（一把削鉛筆刀）",
	"佔用公共長椅超過五小時",
	"於禁止區域放聲大哭",
	"在警察面前做鬼臉",
	"拒絕離開（原因：不知道要去哪裡）",
	"流浪（前職業：公務員）",
	"疑似在思考（無法證實）",
	"無理由站在路中間超過十分鐘",
	"對著電線桿說話（持續四十分鐘）",
	"在地鐵上唱歌（無人鼓掌）",
	"非法存在（細節不明）",
]

const OFFICERS := [
	"警員 比爾","警員 老王","警員 阿明","巡佐 大強",
	"警員 小李","警員 David","巡佐 陳甲","警員 無名氏",
	"警員 張某","警員 李某（非本局李先生）",
]

const NOTES := [
	"（嫌疑人在拘留期間要求提供蠟筆）",
	"（嫌疑人稱自己是「時代的錯誤」）",
	"（逮捕現場：警局門口）",
	"（嫌疑人表示：「無所謂。」）",
	"（嫌疑人要求見律師，但找不到律師）",
	"（嫌疑人主動走進警局自首，不知道自己犯了什麼罪）",
	"（嫌疑人在訊問時睡著了）",
	"（案件相關人員已全數失蹤）",
	"（備注欄由前任書記用咖啡漬蓋住，無法辨識）",
	"（逮捕時間：凌晨三點。原因：「感覺」）",
	"（嫌疑人拒絕說出姓名，但留下了一首詩）",
	"（檔案夾封面有人畫了一隻貓）",
	"","","","","",
]

const LEE_LINES := [
	"「皮耶爾，你的效率讓我十分失望。」",
	"「請不要把咖啡杯放在文件上。謝謝。」",
	"「你今天的表情很差，建議你微笑。」",
	"「我叔叔說你是優秀員工。我表示懷疑。」",
	"「這份文件的格式不對。重新整理一下。謝謝。」",
	"「皮耶爾，你有沒有在聽？」",
	"「效率就是生命。你的生命好像很沒有效率。」",
	"「局長說要提高本月結案率。加油！加油加油加油。」",
	"「你昨天遲到了三分鐘。今天也遲到了兩分鐘。我都有記錄。」",
	"「請整理一下桌面。謝謝。謝謝。謝謝。」",
	"「皮耶爾，微笑。這是命令。」",
	"「我注意到你今天歎氣了七次。這影響辦公室氣氛。」",
]

const MOODS := [
	"日光燈發出低沉的嗡嗡聲。",
	"隔壁同事的鍵盤聲比心跳還要規律。",
	"窗外的天空一如既往地灰。",
	"皮耶爾的筆快沒水了。",
	"辦公室的時鐘慢了十五分鐘。沒有人修。",
	"有人在微波牛肉便當。",
	"印表機又卡紙了。和昨天一樣。",
	"飲水機的水空了。",
	"有同事在打哈欠。",
	"隔壁在爭論某個表格要用黑筆還是藍筆。",
	"文件疊的高度已經超過皮耶爾的視線。",
]

var _rng        := RandomNumberGenerator.new()
var _processed  := 0
var _used_names := []

var _quota_lbl   : Label
var _case_num    : Label
var _name_lbl    : Label
var _charge_lbl  : Label
var _officer_lbl : Label
var _note_lbl    : Label
var _mood_lbl    : Label
var _approve_btn : Button
var _reject_btn  : Button
var _stamp_lbl   : Label
var _lee_panel   : Panel
var _lee_lbl     : Label


func _ready() -> void:
	_rng.randomize()
	_build_ui()
	_next_case()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = C_BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var hdr := Label.new()
	hdr.text = "虎寨城警局下城總局  ─  文書處理站"
	hdr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hdr.add_theme_color_override("font_color", C_DIM)
	hdr.add_theme_font_size_override("font_size", 12)
	hdr.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hdr.offset_top    = 14
	hdr.offset_bottom = 36
	add_child(hdr)

	_quota_lbl = Label.new()
	_quota_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_quota_lbl.add_theme_color_override("font_color", C_AMBER)
	_quota_lbl.add_theme_font_size_override("font_size", 13)
	_quota_lbl.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_quota_lbl.offset_top    = 38
	_quota_lbl.offset_bottom = 60
	add_child(_quota_lbl)

	var doc := Panel.new()
	doc.anchor_left   = 0.5;  doc.anchor_right  = 0.5
	doc.anchor_top    = 0.5;  doc.anchor_bottom = 0.5
	doc.offset_left   = -255; doc.offset_right  = 255
	doc.offset_top    = -180; doc.offset_bottom = 125
	doc.add_theme_stylebox_override("panel", _sty(C_PANEL, C_BORDER, 2, 22))
	add_child(doc)

	var inner := VBoxContainer.new()
	inner.set_anchors_preset(Control.PRESET_FULL_RECT)
	inner.add_theme_constant_override("separation", 10)
	doc.add_child(inner)

	_case_num    = _lbl("", 11, C_DIM)
	_name_lbl    = _lbl("", 16, C_BODY)
	_charge_lbl  = _lbl("", 14, C_AMBER)
	_officer_lbl = _lbl("", 12, C_DIM)
	_note_lbl    = _lbl("", 12, C_DIM)
	_charge_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_note_lbl.autowrap_mode   = TextServer.AUTOWRAP_WORD_SMART

	inner.add_child(_case_num)
	inner.add_child(HSeparator.new())
	inner.add_child(_name_lbl)
	inner.add_child(_charge_lbl)
	inner.add_child(_officer_lbl)
	inner.add_child(_note_lbl)

	_mood_lbl = _lbl("", 11, C_DIM)
	_mood_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mood_lbl.anchor_left   = 0.5;  _mood_lbl.anchor_right  = 0.5
	_mood_lbl.anchor_top    = 0.5;  _mood_lbl.anchor_bottom = 0.5
	_mood_lbl.offset_left   = -255; _mood_lbl.offset_right  = 255
	_mood_lbl.offset_top    = 136;  _mood_lbl.offset_bottom = 158
	add_child(_mood_lbl)

	var btn_row := HBoxContainer.new()
	btn_row.anchor_left   = 0.5;  btn_row.anchor_right  = 0.5
	btn_row.anchor_top    = 0.5;  btn_row.anchor_bottom = 0.5
	btn_row.offset_left   = -210; btn_row.offset_right  = 210
	btn_row.offset_top    = 163;  btn_row.offset_bottom = 213
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 40)
	add_child(btn_row)

	_reject_btn  = _btn("◀  駁回", C_RED)
	_approve_btn = _btn("核准  ▶", C_GREEN)
	_reject_btn.pressed.connect(_on_reject)
	_approve_btn.pressed.connect(_on_approve)
	btn_row.add_child(_reject_btn)
	btn_row.add_child(_approve_btn)

	_stamp_lbl = Label.new()
	_stamp_lbl.visible = false
	_stamp_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stamp_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	_stamp_lbl.add_theme_font_size_override("font_size", 56)
	_stamp_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_stamp_lbl)

	_lee_panel = Panel.new()
	_lee_panel.visible = false
	_lee_panel.anchor_left   = 0.5;  _lee_panel.anchor_right  = 0.5
	_lee_panel.anchor_top    = 0.5;  _lee_panel.anchor_bottom = 0.5
	_lee_panel.offset_left   = -220; _lee_panel.offset_right  = 220
	_lee_panel.offset_top    = -85;  _lee_panel.offset_bottom = 85
	_lee_panel.add_theme_stylebox_override("panel",
		_sty(Color(0.12, 0.09, 0.07), Color(0.9, 0.75, 0.2), 2, 20))
	add_child(_lee_panel)

	var lv := VBoxContainer.new()
	lv.set_anchors_preset(Control.PRESET_FULL_RECT)
	lv.add_theme_constant_override("separation", 12)
	_lee_panel.add_child(lv)

	lv.add_child(_lbl("李先生", 12, Color(0.9, 0.75, 0.2)))
	_lee_lbl = _lbl("", 14, C_BODY)
	_lee_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lv.add_child(_lee_lbl)
	var ok := _btn("（點頭）", C_DIM)
	ok.pressed.connect(_dismiss_lee)
	lv.add_child(ok)


func _sty(bg: Color, border: Color, bw: int, mg: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(bw)
	s.set_content_margin_all(mg)
	return s


func _lbl(txt: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = txt
	l.add_theme_color_override("font_color", color)
	l.add_theme_font_size_override("font_size", size)
	return l


func _btn(txt: String, color: Color) -> Button:
	var b := Button.new()
	b.text = txt
	b.add_theme_color_override("font_color", color)
	b.add_theme_font_size_override("font_size", 15)
	b.add_theme_stylebox_override("normal",
		_sty(C_PANEL, color.darkened(0.4), 1, 12))
	b.add_theme_stylebox_override("hover",
		_sty(color.darkened(0.55), color, 1, 12))
	b.add_theme_stylebox_override("pressed",
		_sty(color.darkened(0.55), color, 1, 12))
	return b


func _next_case() -> void:
	_update_quota()
	var charge  : String = CHARGES[_rng.randi() % CHARGES.size()]
	var officer : String = OFFICERS[_rng.randi() % OFFICERS.size()]
	var note    : String = NOTES[_rng.randi() % NOTES.size()]
	var yr := _rng.randi_range(88, 113)
	var mo := _rng.randi_range(1, 12)
	var dy := _rng.randi_range(1, 28)

	_case_num.text    = "案號 CH-%04d  ·  %d年%02d月%02d日" % [
		_rng.randi_range(1000, 9999), yr, mo, dy]
	_name_lbl.text    = "姓名：%s" % _pick_name()
	_charge_lbl.text  = "罪名：%s" % charge
	_officer_lbl.text = "逮捕：%s" % officer
	_note_lbl.text    = note
	_mood_lbl.text    = MOODS[_rng.randi() % MOODS.size()]

	_approve_btn.disabled = false
	_reject_btn.disabled  = false


func _pick_name() -> String:
	if _used_names.size() >= NAMES.size():
		_used_names.clear()
	while true:
		var n : String = NAMES[_rng.randi() % NAMES.size()]
		if not _used_names.has(n):
			_used_names.append(n)
			return n
	return ""


func _update_quota() -> void:
	_quota_lbl.text = "今日配額：%d / %d  份已處理" % [_processed, QUOTA]


func _on_approve() -> void:
	_approve_btn.disabled = true
	_reject_btn.disabled  = true
	_show_stamp("核\n准", Color(0.20, 0.65, 0.20, 0.85))


func _on_reject() -> void:
	_approve_btn.disabled = true
	_reject_btn.disabled  = true
	_show_stamp("駁\n回", Color(0.75, 0.15, 0.15, 0.85))


func _show_stamp(text: String, color: Color) -> void:
	_stamp_lbl.text = text
	_stamp_lbl.add_theme_color_override("font_color", color)
	_stamp_lbl.visible = true
	await get_tree().create_timer(0.65).timeout
	_stamp_lbl.visible = false
	_processed += 1
	if _processed >= QUOTA:
		_finish_game()
	elif _rng.randf() < LEE_CHANCE:
		_show_lee()
	else:
		_next_case()


func _show_lee() -> void:
	_lee_lbl.text = LEE_LINES[_rng.randi() % LEE_LINES.size()]
	_lee_panel.visible    = true
	_approve_btn.disabled = true
	_reject_btn.disabled  = true


func _dismiss_lee() -> void:
	_lee_panel.visible = false
	_next_case()


func _finish_game() -> void:
	_update_quota()
	_approve_btn.visible = false
	_reject_btn.visible  = false
	_mood_lbl.text = "今日配額完成。皮耶爾把最後一份文件壓到那永遠處理不完的那疊文書裡去。"
	await get_tree().create_timer(2.8).timeout
	get_tree().change_scene_to_file("res://scenes/GameScene.tscn")
