# 物件互動系統 Implementation Plan

> **Status:** DRAFT

## Specification

**Problem:** 地圖上只有 NPC 和出口可以互動。玩家走過椅子、桌子、垃圾堆、海報，什麼都沒發生——世界是空的。

**Goal:** 玩家靠近任何可互動物件時按 E，出現山姆皮耶爾對該物件的短評或黑色笑話（全屏面板，同進場景面板）。不需要 NPC，不需要對話 chapter——就是世界的質感。

**Scope:**
- In: ObjectData.gd autoload、四個場景的物件定義、AsciiLevelBase E 鍵邏輯擴充、面板重構為通用 text panel
- Out: 物件互動狀態（只能互動一次 vs 重複）暫不處理、動畫效果暫不處理

**Success Criteria:**

- [ ] 玩家靠近物件位置按 E，全屏面板出現皮耶爾的反應文字
- [ ] 面板按 E 關閉，繼續自由移動
- [ ] NPC 優先於物件（NPC 和物件同時相鄰時，NPC 對話優先）
- [ ] 四個場景各有至少 3 個可互動物件
- [ ] 進場景面板功能不受影響

## Context Loading

```
read scripts/AsciiLevelBase.gd
read scripts/StationLevel.gd
read scripts/OfficeLevel.gd
read scripts/RestaurantLevel.gd
read scripts/StreetLevel.gd
read project.godot
```

## Tasks

### ObjectData 子系統

#### Task 1: 建立 ObjectData.gd 並加入 autoload

**Context:** `scripts/DialogueData.gd`（參考 autoload 結構）, `project.godot`

**Steps:**

1. [ ] 建立 `scripts/ObjectData.gd`，定義 `const OBJECTS: Dictionary`，key 為 level_id（String），value 為 `Dictionary`（`Vector2i` → `{text: String}`）
   - 所有位置必須用 `Vector2i(x, y)` literal，不得用 `Vector2`（float），否則執行時 key 查找靜默回傳 null
2. [ ] 填入四個場景的物件及皮耶爾反應文字，對照各場景地圖選定位置，每場景至少 3 個
3. [ ] 在 `project.godot` autoload 區塊加入 ObjectData（順序在 DialogueData 之後）

**Verify:** Godot 編輯器開啟不報 parser error；`ObjectData.OBJECTS["station"]` 在 GDScript console 可讀取

---

### AsciiLevelBase + Level 腳本子系統

Task 2 和 Task 3 必須同一 agent 執行（Task 3 的 `_get_level_id()` 需要 Task 2 定義的虛方法才能驗證）。

#### Task 2: 重構面板為通用 text panel + 加入物件互動邏輯

**Context:** `scripts/AsciiLevelBase.gd`（重點：`_input()`、`_setup_scene_panel()`、`_open_scene_panel()`）

**Steps:**

1. [ ] 新增 `_panel_text_label: Node = null`（用 `Node` 型別避免 Godot 4.6 class 層級 `Label` 宣告 bug；存取時用 `as Label` cast）；在 `_setup_scene_panel()` 建立 text label 後存入
2. [ ] 新增 `_show_panel_text(text: String)` 方法：
   ```gdscript
   func _show_panel_text(text: String) -> void:
       if _panel_text_label == null:
           return
       (_panel_text_label as Label).text = text
       _open_scene_panel()  # 只設 visible=true + _scene_panel_open=true，不重建 Panel
   ```
3. [ ] 修改 `_ready()` 場景進場呼叫：改用 `_show_panel_text(_get_scene_intro())`（`_setup_scene_panel()` 仍先呼叫建立節點）
4. [ ] 新增 `_get_level_id() -> String` 虛方法（預設 `""`）
5. [ ] 新增 `_objects: Dictionary`，在 `_ready()` 從 `ObjectData.OBJECTS.get(_get_level_id(), {})` 載入
6. [ ] 新增 `_try_interact_object() -> bool`：用與 NPC 偵測完全相同的四方向陣列掃描 `_objects`，找到相鄰物件 → `_show_panel_text(obj["text"])` → return `true`；否則 return `false`
7. [ ] 修改 `_input()` E 鍵邏輯（明確的 fall-through 順序）：
   ```gdscript
   if _scene_panel_open:
       _close_scene_panel()
       return
   if _in_dialogue:
       return
   var near_npc := false
   for dir in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
       if (_player_pos + dir) in _npcs:
           near_npc = true
           break
   if near_npc:
       _try_interact()
   elif not _try_interact_object():   # false = 沒有物件 → 才重開進場面板
       _open_scene_panel()
   ```

**Verify:** 進場面板正常開關；靠近 ObjectData 定義位置按 E 出現對應文字；NPC 相鄰時優先觸發對話；沒有任何相鄰物件時 E 重開進場面板

#### Task 3: 四個 level 各加 `_get_level_id()`

**Context:** `scripts/StationLevel.gd`, `scripts/OfficeLevel.gd`, `scripts/RestaurantLevel.gd`, `scripts/StreetLevel.gd`

**Steps:**

1. [ ] `StationLevel`: `func _get_level_id() -> String: return "station"`
2. [ ] `OfficeLevel`: `func _get_level_id() -> String: return "office"`
3. [ ] `RestaurantLevel`: `func _get_level_id() -> String: return "restaurant"`
4. [ ] `StreetLevel`: `func _get_level_id() -> String: return "street"`

**Verify:** 各場景進入後 `_objects` 正確載入（臨時加 `print(_objects.size())` 在 `_ready()` 末尾確認後刪除）

---

## Review Notes

devils-advocate 審查發現的問題，已全部納入修正：

- **Label 型別** — `_panel_text_label` 宣告為 `Node`（避免 Godot 4.6 bug），存取時 `as Label` cast
- **`_open_scene_panel()` 冪等性** — 明確說明該方法只改 `visible`/flag，不重建節點
- **Task 3 依賴 Task 2** — 合併為同一 agent 執行，避免虛方法未定義就驗證
- **四方向定義** — 指定用與 NPC 偵測完全相同的方向陣列
- **`_try_interact_object()` 回傳值** — E 鍵邏輯改為 `elif not _try_interact_object()`，false 才 fallthrough 到重開面板
- **Vector2i vs Vector2** — ObjectData 說明中明確要求所有位置用 `Vector2i` literal
