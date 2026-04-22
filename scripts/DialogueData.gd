extends Node

# ── Line fields ───────────────────────────────────────────────
# speaker  : "sam" | "rat" | "lee" | "rachel" | "sarah" | "bill" | "moujia" | "david" | "narrator"
# text     : String
# active   : "left" | "right" | "none"
# choices  : Array of {"text": String, "goto": int}  ← optional; shows choice buttons
# next     : int  ← optional; overrides default index+1 after this line

const CHAPTERS : Array = [
	{
		"id": "ch1",
		"title": "Chapter 1 — 破處",
		"bg_color": Color(0.06, 0.06, 0.10),
		"left_char": "sam",
		"right_char": "rat",
		"lines": [
			# 0
			{"speaker": "narrator", "text": "虎寨城，下城地鐵站。深夜，末班車前。\n月台上沒有其他人——霉味、鼠屍臭、尿騷味充斥整個空間。", "active": "none"},
			# 1
			{"speaker": "narrator", "text": "又結束了糟糕的一天。", "active": "none"},
			# 2
			{"speaker": "sam", "text": "（點了一根卡斯特，凝視月台柱子上的塗鴉）\n「為甚麼列寧喜歡穿皮鞋，史達林卻總是穿靴子？」", "active": "left"},
			# 3
			{"speaker": "sam", "text": "「因為列寧時代，俄羅斯的血水只淹到腳踝。」\n……沒有很好笑。", "active": "left"},
			# 4
			{"speaker": "rat", "text": "「嘿……山姆，對嗎？好久不見，呵。」", "active": "right"},
			# 5
			{"speaker": "sam", "text": "「我們見過嗎？」", "active": "left"},
			# 6
			{"speaker": "rat", "text": "「你怎麼這麼無情？我可是你老媽的情人，哈哈……」", "active": "right"},
			# 7
			{"speaker": "sam", "text": "「原來是你啊，老鼠。」", "active": "left"},
			# 8
			{"speaker": "rat", "text": "「最近過得如何啊老兄，有沒有宰了你那肥豬上司？」", "active": "right"},
			# 9
			{"speaker": "sam", "text": "「正在考慮了，別著急。」", "active": "left"},
			# 10
			{"speaker": "rat", "text": "「好朋友啊？你過得快樂嗎？」", "active": "right"},
			# 11
			{"speaker": "sam", "text": "「多謝你了，老鼠，我特別煩悶。」", "active": "left"},
			# 12
			{"speaker": "rat", "text": "「別再叫我老鼠！……說說看嘛，還是你抽菸也是為了耍帥？」", "active": "right"},
			# 13  ← CHOICE: 老鼠伸手借錢
			{
				"speaker": "rat",
				"text": "「借些錢花花吧，我把錢都拿去買粉吸掉了。不然借我一百——一個你看我吃，一個我吃給你看——」",
				"active": "right",
				"choices": [
					{"text": "「你比上次還要嗨，夥計。先坐下冷靜一下。」", "goto": 14},
					{"text": "（沉默，繼續抽菸，不理他）", "goto": 16},
					{"text": "「我沒有錢。」", "goto": 16},
				]
			},
			# 14  ← choice A 分支：Sam 出言勸阻
			{"speaker": "sam", "text": "「你比上次還要嗨，夥計，我覺得你得先坐下來冷靜一下。」", "active": "left", "next": 16},
			# 15  ← (不使用，保留索引對齊)
			{"speaker": "narrator", "text": "老鼠的左眼、左手開始抽動。他的右臉也開始抽搐。", "active": "none"},
			# 16  ← 匯流點
			{"speaker": "rat", "text": "「你幹嘛？朋友一場，何……何必這樣！」", "active": "right"},
			# 17
			{"speaker": "narrator", "text": "皮耶爾站起來，想要從這場鬧劇抽身，但老鼠一把抓住了他。", "active": "none"},
			# 18
			{"speaker": "sam", "text": "「滾開。」", "active": "left"},
			# 19
			{"speaker": "narrator", "text": "老鼠從皮靴內側抽出一把蝴蝶刀，衝向皮耶爾。\n\n皮耶爾反應過來掏槍時，下腹已經被刺中了。", "active": "none"},
			# 20
			{"speaker": "narrator", "text": "「最可悲的是，在我死之前，我一刻都沒有活成我想要的樣子……\n\n操！一次就好，就算只有一次也好，我想活著，真正的活著——」", "active": "none"},
			# 21
			{"speaker": "narrator", "text": "砰！子彈射穿老鼠的肺。\n\n末班車進站。皮耶爾把老鼠拽向軌道，用力一推。", "active": "none"},
			# 22
			{"speaker": "narrator", "text": "「唰，噗吱！」\n\n鮮血濺到皮耶爾的臉上和白襯衫上，朱紅的顏料渲染了好一幅抽象畫。", "active": "none"},
			# 23
			{"speaker": "sam", "text": "（靠在柱子上，緩緩滑坐到地上）\n……某種程度上，他很快樂。", "active": "left"},
			# 24
			{"speaker": "narrator", "text": "他的身體越來越輕。\n\n一片黑，最後什麼都沒有了。", "active": "none"},
		]
	},
	{
		"id": "ch2",
		"title": "Chapter 2 — 重生",
		"bg_color": Color(0.08, 0.04, 0.04),
		"left_char": "sam",
		"right_char": "sarah",
		"lines": [
			{"speaker": "narrator", "text": "六點半。早上的鬧鐘響了。", "active": "none"},
			{"speaker": "sam", "text": "「……」\n（看著自己的雙手）\n我……活著？", "active": "left"},
			{"speaker": "narrator", "text": "昨晚的傷，消失了。下腹的刺傷，沒有了。\n\n血衣、蝴蝶刀、月台、老鼠——全都不見了。", "active": "none"},
			{"speaker": "sam", "text": "「真巧，操你媽。」", "active": "left"},
			{"speaker": "narrator", "text": "皮耶爾數著子彈把玩著彈匣，好似數著自己荒唐虛度的生命。\n\n包裡：一個酒壺、一把左輪槍。", "active": "none"},
			{"speaker": "narrator", "text": "新聞大聲播著：「犯罪集團『鼠黨』一名成員陳屍於碼頭廣場，全身四十多處中彈……」", "active": "none"},
			{"speaker": "sarah", "text": "「這簡直沒有天理，太殘忍了。」", "active": "right"},
			{"speaker": "sarah", "text": "「親愛的，出門注意安全，最近市裡真亂吶。」", "active": "right"},
			{"speaker": "sam", "text": "「好的媽，記得自己熱食物吃。冰箱的牛奶過期了，不要喝。」", "active": "left"},
			{"speaker": "sarah", "text": "「真巧，醫生也跟我說少喝點酒。」", "active": "right"},
			{"speaker": "sam", "text": "「不改變的話，你的肝炎永遠不會好。」", "active": "left"},
			{"speaker": "sarah", "text": "「知道了，乖兒子。」", "active": "right"},
			{"speaker": "narrator", "text": "才剛踏出門就想躺回床上，或許醒來就是個錯誤。\n\n死灰的天空下，黯淡的路像冥府擺渡人卡戎一樣向他招手。", "active": "none"},
			{"speaker": "sam", "text": "（日記）\n「我們為何起床？我們為何工作？」", "active": "left"},
		]
	},
	{
		"id": "ch3",
		"title": "Chapter 3 — 馱獸",
		"bg_color": Color(0.04, 0.04, 0.08),
		"left_char": "sam",
		"right_char": "lee",
		"lines": [
			{"speaker": "narrator", "text": "「虎寨城警局下城總局」——牆上斗大的金字映著光，照的人心裡發寒。", "active": "none"},
			{"speaker": "narrator", "text": "警局裡，冷冽的日光燈散發著令人不安的死氣。辦公室裡的人臉上都沒有任何表情，甚至連血色都沒有。\n\n除了——李先生。", "active": "none"},
			{"speaker": "lee", "text": "「哎呀呀，山姆，」（油膩地瞇著眼）「您遲到了，三分鐘，皮耶爾先生，根據市府法規，您是要被扣三天的薪水的。」", "active": "right"},
			{"speaker": "narrator", "text": "皮耶爾盯著他看了一會，沒有回應。", "active": "none"},
			# CHOICE: 如何回應李先生
			{
				"speaker": "sam",
				"text": "（心裡）\n這個死胖子……",
				"active": "left",
				"choices": [
					{"text": "「是，李先生。對不起。」（低頭）", "goto": 5},
					{"text": "（沉默，走回桌子）", "goto": 5},
					{"text": "「您說得是。」（心裡想把他從窗口扔出去）", "goto": 5},
				]
			},
			# 5  ← 匯流
			{"speaker": "narrator", "text": "拘留室裡嗑完藥被抓回來的毒蟲們，是總局裡最自得其樂的一群人。\n\n皮耶爾在辦公桌前坐下，開始處理一疊永遠處理不完的文書。", "active": "none"},
			# 6  ← 小遊戲觸發
			{"speaker": "narrator", "text": "", "active": "none", "minigame": "civil_servant"},
			# 7
			{"speaker": "sam", "text": "（心裡）\n身而為人苦難無盡。\n\n我們所能做的，最多就是追求快樂。", "active": "left"},
		]
	},
	{
		"id": "ch4",
		"title": "Chapter 4 — 追殺比爾",
		"bg_color": Color(0.08, 0.03, 0.03),
		"left_char": "sam",
		"right_char": "bill",
		"lines": [
			{"speaker": "narrator", "text": "比爾。李先生的姪子。同樣在局裡工作，同樣的油光滿面，同樣讓人想打。", "active": "none"},
			{"speaker": "bill", "text": "「嘿山姆，這麼晚下班，辛苦你了耶。」\n（拍肩）「叔叔說你最近表現不錯喔——」", "active": "right"},
			{"speaker": "sam", "text": "（沉默）", "active": "left"},
			{"speaker": "bill", "text": "「哎，你這人真的很難聊耶，難怪朋友少——」", "active": "right"},
			{"speaker": "narrator", "text": "地鐵進站。\n\n皮耶爾看著月台邊緣，看著比爾，計算著距離。", "active": "none"},
			{"speaker": "narrator", "text": "他記得老鼠的死。他記得那種感覺——那種短暫的、真實的活著。", "active": "none"},
			# CHOICE: 動手嗎？
			{
				"speaker": "narrator",
				"text": "車輪的尖嘯聲愈發刺耳。\n\n——那個念頭又來了。",
				"active": "none",
				"choices": [
					{"text": "動手。", "goto": 7},
					{"text": "忍住。走開。", "goto": 8},
				]
			},
			# 7  ← 動手
			{"speaker": "narrator", "text": "他動手了。\n\n媒體的標題隔天出現：「警察英雄殉職——比爾先生，疑遭仇人推落月台。」", "active": "none", "next": 9},
			# 8  ← 忍住
			{"speaker": "narrator", "text": "他沒有動手。\n\n但那個念頭，不會消失。", "active": "none", "next": 9},
			# 9  ← 匯流
			{"speaker": "sam", "text": "（日記）\n「沒有人懷疑山姆·皮耶爾。\n\n——或許因為沒有人記得山姆·皮耶爾。」", "active": "left"},
		]
	},
	{
		"id": "ch5",
		"title": "Chapter 5 — 某甲",
		"bg_color": Color(0.04, 0.07, 0.04),
		"left_char": "sam",
		"right_char": "moujia",
		"lines": [
			# 0
			{"speaker": "narrator", "text": "老蕭餐館。國慶日。\n下城區少數幾個讓人稍微忘記現實的地方。", "active": "none"},
			# 1
			{"speaker": "moujia", "text": "「你就是山姆·皮耶爾？」", "active": "right"},
			# 2
			{"speaker": "sam", "text": "「你是？」", "active": "left"},
			# 3
			{"speaker": "moujia", "text": "「叫我某甲就好。」（笑）「我對你有些好奇。」", "active": "right"},
			# 4
			{"speaker": "sam", "text": "「大家都對我好奇，然後都失望了。」", "active": "left"},
			# 5
			{"speaker": "moujia", "text": "「人與人之間並不能互相理解，不是嗎？」", "active": "right"},
			# 6
			{"speaker": "sam", "text": "「……你說的沒錯。」", "active": "left"},
			# 7
			{"speaker": "moujia", "text": "「這個城市腐爛了，山姆。從李先生那種人，到整個警局，到政府。我們有些人決定做些什麼。」", "active": "right"},
			# 8
			{"speaker": "sam", "text": "「革命？」（苦笑）「你是認真的。」", "active": "left"},
			# 9  ← CHOICE
			{
				"speaker": "moujia",
				"text": "「鐵皮屋的人很認真。我們要讓這座城市知道，有些事情是不被允許的。\n\n——你願意聽更多嗎？」",
				"active": "right",
				"choices": [
					{"text": "「我不是那種人。」", "goto": 10},
					{"text": "「……告訴我更多。」", "goto": 11},
				]
			},
			# 10  ← 拒絕分支
			{"speaker": "sam", "text": "「我不是那種人。」\n（轉身，走出了老蕭餐館）", "active": "left", "next": 12},
			# 11  ← 接受分支
			{"speaker": "sam", "text": "「……告訴我更多。」\n（拿起酒杯，沉默地喝了一口）", "active": "left", "next": 12},
			# 12  ← 匯流
			{"speaker": "moujia", "text": "「你已經是那種人了，山姆。你只是還不知道。」", "active": "right"},
			# 13
			{"speaker": "narrator", "text": "無論如何，皮耶爾那天晚上獨自離開了老蕭餐館。\n\n城市的夜晚吞噬了他的身影，那個問題還在空氣裡漂浮著。", "active": "none"},
		]
	},
	{
		"id": "ch6",
		"title": "Chapter 6 — 多愁善感",
		"bg_color": Color(0.05, 0.05, 0.09),
		"left_char": "sam",
		"right_char": "rachel",
		"lines": [
			{"speaker": "narrator", "text": "移民區。霓虹燈把街道染成骯髒的粉紅色。\n\n皮耶爾沒打算來這裡。但他的腳帶他來了。", "active": "none"},
			{"speaker": "narrator", "text": "她站在一扇半開的門前。比高中時瘦了，眼神不一樣了，但那個笑容——", "active": "none"},
			{"speaker": "rachel", "text": "「山姆？」\n（沉默了三秒）「……山姆！」", "active": "right"},
			{"speaker": "sam", "text": "「瑞秋。」", "active": "left"},
			{"speaker": "narrator", "text": "他們去了老蕭餐館。點了兩杯便宜的威士忌。", "active": "none"},
			{"speaker": "rachel", "text": "「你還記得那次我們翹課去看海嗎？」", "active": "right"},
			{"speaker": "sam", "text": "「校長那天把我的頭發剃掉了。」", "active": "left"},
			{"speaker": "rachel", "text": "「但海是真的很美。」\n（停頓）「你現在怎麼樣？」", "active": "right"},
			# CHOICE
			{
				"speaker": "sam",
				"text": "（想了一下，該說什麼好？）",
				"active": "left",
				"choices": [
					{"text": "「在警局做書記。」", "goto": 9},
					{"text": "「不怎麼樣。你呢？」", "goto": 10},
				]
			},
			# 9
			{"speaker": "sam", "text": "「在警局做書記。」", "active": "left", "next": 11},
			# 10
			{"speaker": "sam", "text": "「不怎麼樣。你呢？」", "active": "left", "next": 11},
			# 11 ← 匯流
			{"speaker": "rachel", "text": "「你知道的。」\n（喝了一口）「傷心總是難免的，山姆。」", "active": "right"},
			# 12
			{"speaker": "narrator", "text": "她離開前說了一句話：\n\n「海的味道像哈密瓜。」\n\n皮耶爾不知道那是什麼意思，但他記住了。", "active": "none"},
		]
	},
	{
		"id": "ch7",
		"title": "Chapter 7 — 阿母，拍謝啦！",
		"bg_color": Color(0.07, 0.04, 0.07),
		"left_char": "sam",
		"right_char": "sarah",
		"lines": [
			{"speaker": "narrator", "text": "他們說山姆·皮耶爾死了。\n\n補償金匯到了母親的帳戶。", "active": "none"},
			{"speaker": "narrator", "text": "但皮耶爾還活著。他站在自己家門口。", "active": "none"},
			{"speaker": "sarah", "text": "「……你怎麼……你不是……」\n（後退）「你死了！政府說你死了！」", "active": "right"},
			{"speaker": "sam", "text": "「我沒有死，媽。」", "active": "left"},
			{"speaker": "sarah", "text": "「補償金！他們說……他們說是你的撫卹金……」", "active": "right"},
			{"speaker": "sam", "text": "「你把錢花在哪了？」", "active": "left"},
			{"speaker": "narrator", "text": "公寓裡有新的電視機、新的沙發。床頭櫃上兔頭牌伏特加換成了更貴的洋酒。", "active": "none"},
			{"speaker": "sarah", "text": "（哭）「我以為你死了！一個母親能怎麼辦……」", "active": "right"},
			# CHOICE
			{
				"speaker": "sam",
				"text": "（看著那瓶洋酒，看著母親，有些話堵在喉嚨裡）",
				"active": "left",
				"choices": [
					{"text": "「媽，你知道我小時候說的第一個字是什麼嗎？」", "goto": 9},
					{"text": "（什麼也沒說，走進房間，關上門）", "goto": 11},
				]
			},
			# 9
			{"speaker": "sarah", "text": "「……什麼？」", "active": "right"},
			# 10
			{"speaker": "sam", "text": "「伏特加。」\n\n我不知道那算不算你的錯，媽。但我記得。", "active": "left"},
			# 11 ← 匯流
			{"speaker": "narrator", "text": "窗外是十樓的夜空。\n\n皮耶爾轉過身，聽到了一聲他再也無法聽見第二次的聲音。", "active": "none"},
			# 12
			{"speaker": "narrator", "text": "……\n\n樓下一片嘈雜。\n\n他坐在地板上，什麼都沒做。", "active": "none"},
		]
	},
	{
		"id": "ch8",
		"title": "Chapter 8 — 幽靈的歸宿",
		"bg_color": Color(0.02, 0.02, 0.05),
		"left_char": "sam",
		"right_char": "lee",
		"lines": [
			{"speaker": "narrator", "text": "之後有多少天，皮耶爾自己也數不清了。\n\n他在城市裡游蕩，像一個沒有目的地的幽靈。", "active": "none"},
			{"speaker": "narrator", "text": "某甲的鐵皮屋幫，對警察局發動了攻擊。\n\n李先生現在是市長了。", "active": "none"},
			{"speaker": "narrator", "text": "地鐵月台。最後一次。\n\n市長專車路線，今晚改道了。李先生會搭地鐵。", "active": "none"},
			{"speaker": "lee", "text": "（不認得皮耶爾）「讓開，你知道我是誰嗎？」", "active": "right"},
			{"speaker": "sam", "text": "「知道。」", "active": "left"},
			{"speaker": "narrator", "text": "皮耶爾把刀插進去的時候，李先生沒有立刻理解發生了什麼事。", "active": "none"},
			{"speaker": "sam", "text": "「小可愛、小可愛……肥肥小胖豬。」", "active": "left"},
			{"speaker": "narrator", "text": "李先生在月台邊緣顫抖著，他的臉——開始變形。\n\n豬嘴、豬耳、豬蹄。", "active": "none"},
			{"speaker": "sam", "text": "「人生是無窮的苦悶……不管你多麼努力想辦法推動它，它總是會把你輾過去。」", "active": "left"},
			{"speaker": "sam", "text": "「但今晚輪到你了。」", "active": "left"},
			{"speaker": "narrator", "text": "車輪的尖嘯聲。\n\n最後一次。", "active": "none"},
			{"speaker": "narrator", "text": "「唰，噗吱！」\n\n這一次，血也染到了皮耶爾自己。\n\n他沒有躲開。", "active": "none"},
		]
	},
	{
		"id": "epilogue",
		"title": "後記 — 夢",
		"bg_color": Color(0.0, 0.0, 0.0),
		"left_char": "narrator",
		"right_char": "sam",
		"lines": [
			{"speaker": "narrator", "text": "沒有人記得山姆·皮耶爾。", "active": "none"},
			{"speaker": "narrator", "text": "沒有人記得那個住在十坪貧民窟、失眠、煙酒上癮、在警局做書記的平庸男人。", "active": "none"},
			{"speaker": "narrator", "text": "——你要不要聽我的故事？", "active": "none"},
			{"speaker": "narrator", "text": "我叫山姆·皮耶爾。\n\n我死過很多次，但我還在這裡。", "active": "none"},
			{"speaker": "narrator", "text": "或許「還在這裡」本身，就是最大的玩笑。", "active": "none"},
			{"speaker": "narrator", "text": "如果真的有神，祂得向我乞求原諒。", "active": "none"},
			{"speaker": "narrator", "text": "……", "active": "none"},
			{"speaker": "narrator", "text": "六點半。早上的鬧鐘響了。\n\n——", "active": "none"},
			{"speaker": "narrator", "text": "《SAM PIERRE》\n\nby Hank L. and Sam K.\n\n版權所有，翻印必究。", "active": "none"},
		]
	},
]

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
