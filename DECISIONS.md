# DECISIONS — 《Sam Pierre》決策紀錄

> **L1 決策層。只增不改(append-only)。** 推翻舊決策時**加新行**,不刪舊行——被推翻的那行在「狀態」欄標記 `❌ 已被 YYYY-MM-DD 推翻`。
> 為什麼保留死掉的決策:讓未來的你(和 AI)看得到「這條路試過了、為什麼放棄」,避免重蹈。
> 格式:`日期 | 決策 | 理由 | 狀態`

| 日期 | 決策 | 理由 | 狀態 |
|------|------|------|------|
| (初期) | 平台用 **Godot 4.6**,不切 HTML | 已有 Godot 章節/選項/場景基礎;之後加小遊戲、互動、演出用 Godot 較自然 | ✅ 現行 |
| (初期) | **不做視覺小說** | 原作者之一明令;純對話推進太薄,要保留非閱讀玩法 | ✅ 現行 |
| (初期) | 故事資料用 **Markdown(首選)/ YAML,永不 JSON** | Sam K.(非程式的共同作者)要能直接讀寫劇本;JSON 對寫作者太吵 | ✅ 現行 |
| (初期) | 專案 **closed source,all rights reserved** | Hank 刻意決定,不開源 | ✅ 現行 |
| 2026-05-27 | 議會系統採**輕量版**(3 agent 並行、零指令記憶、自然語言觸發,存 `.claude/commands/`) | 靈感自 Claude-Code-Game-Studios,但 Hank 不想背指令、不想為沒用到的 context 花 token | ✅ 現行 |
| 2026-07-04 | 實驗把美術風格從 **ASCII 2D 轉 3D 第一人稱(Arctic Eggs 風:低解析 + Bayer dither + 綠灰限色)** | 想驗證氛圍方向;AskUserQuestion 確認:留在 Godot 4.6、純 Arctic Eggs 風不保留 ASCII | ✅ 現行(2026-07-06 轉正) |
| 2026-07-06 | 3D 方向**從實驗轉正**——「now it's 3d era of the game」,已 commit + push | 氛圍成立,方向對了 | ✅ 現行 |
| 2026-07-06 | 對話 UI 定案:**無底框純文字 + 黑描邊**(移除橘框) | Hank 要求;貼臉對話不要框 | ✅ 現行 |
| 2026-07-06 | **像真人一樣用 Godot**:場景幾何/擺設必須存在 `.tscn`,不得 `_ready()` 生幾何;複雜場景用建置腳本產 `.tscn` 後以編輯器為準 | godot MCP 的 add_node 太陽春(不支援 sub-resource/transform);要可視化編輯 | ✅ 現行 |
| 2026-07-06 | 加入專案 skill `avoiding-shishan-code`,清掉 tracked *.tmp、.gitignore 加 *.tmp | Hank 要求「no 屎山代碼」 | ✅ 現行 |
| 2026-07-08 | 採用 **L0 SPEC / L1 DECISIONS / L2 STATE** 三層知識架構(移植自 Comma 專案) | 讓資料用更少 token 被找到、一次性紀錄不混進長期規則、任務可交接給便宜模型 | ✅ 現行 |

---
*版權屬原作者 Hank L. & Sam K.*
