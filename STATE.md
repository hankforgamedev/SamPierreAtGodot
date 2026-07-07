# STATE — 《Sam Pierre》當前狀態

> **L2 狀態層。本檔可整份覆寫,永遠只反映「現在」。**
> 更新規則:每次收工由 AI 依當日進度**重寫本檔**。過期資訊直接刪除,不保留歷史(歷史在 git log 與 DECISIONS.md)。
> 願景與鐵律不寫這(在 SPEC.md);決策取捨不寫這(在 DECISIONS.md)。
> **分支**:`arctic-3d-proto`(3D 現行主戰場;2D 封存在 `main` / `papers-please-ui`)
> **最後更新**:2026-07-08

## ✅ Done(已成立,別回頭重做)

- [x] 3D 第一人稱 + PSX dither 氛圍成立(Arctic Eggs 風,方向已確認正確)
- [x] 三個 3D 場景以門互通:Station(rat/ch1)、Office(lee/ch3)、Restaurant(moujia/ch5)
- [x] 正式章節對話接上 3D(ch1/ch3/ch5),打字機 / choices / next 都能跑
- [x] CC0 素材入庫:Kenney Furniture Kit(`assets/models/kenney_furniture/`,附 LICENSE)
- [x] GDUnit4 測試 **42 綠**(object_interaction 21 + ambient_b 21)
- [x] 第九次試玩兩個 UI bug 修掉(對話文字飛左上角 / 有選項的對話卡死 → 同根因:`set_anchors_preset` 把純 Control 縮 0x0,改用 `set_anchors_and_offsets_preset`)

## 🔧 Doing / Next(優先高→低,對齊 SPEC.md §6)

- [ ] 🔴 **對話刪減 + 環境敘事承擔(最高)** — 第九次試玩最大不滿:話太多。ch1/ch3/ch5 對話砍 ≥30%,資訊移給場景/告示/氛圍。
  - ⚠️ **動 `story/chapters/` 前必須先跟 Hank 確認刪減幅度**,劇本正文屬 Sam K.,不得擅改字。
- [ ] 🔴 抽菸 / 安眠藥功能(新加,見 SPEC.md §6.7)— 麻痺/逃避機制,呼應輪迴主題;設計待與 Hank 對齊
- [ ] 選擇後果 + 全域旗標系統(`argued_with_mom` / `pushed_someone` …,跨章回應)
- [ ] 暴力/攻擊的心理鋪陳(ch1「攻擊決策太倉促」)
- [ ] 回看 / 對話歷史(scroll-back),3D 版
- [ ] 公務員小遊戲作為輪迴機制(可進可出、`resume_line` 回主線、敘事強化「跳不出循環」)

## 🚫 Blocked / 待決

- **對話刪減幅度**:等 Hank 拍板砍多少、砍哪些,才動 story/chapters/(先保留不動)
- **抽菸/安眠藥的玩法定位**:是純演出 / 狀態管理 / 還是影響旗標?待與 Hank 對齊

## 🧱 品質基線(收工必查)

- 加 `class_name` 後跑 `godot --headless --path . --import`,否則「Could not find type X」
- 全測試綠:`godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/ --ignoreHeadlessMode`
- no 屎山:不留 *.tmp、不硬編可外置資料、不順手多做範圍外的事
- 場景幾何在 .tscn(編輯器可編),不在 `_ready()` 生

## 📌 給下一棒的一句話

3D 時代成立、42 測試綠、兩個 UI bug 已清;下一個最高價值目標是**讓世界自己開口——砍對話、補環境敘事**,但動劇本正文前一定先問 Hank 砍多少。

---
*版權屬原作者 Hank L. & Sam K.*
