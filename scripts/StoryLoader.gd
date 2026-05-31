class_name StoryLoader
# Parses story Markdown files in res://story/ into the dictionaries
# expected by DialogueData, ObjectData, level scripts, and CivilServantMiniGame.


# ── Public API ────────────────────────────────────────────────────────────────

static func load_chapter(path: String) -> Dictionary:
	var content := _read(path)
	if content == "":
		return {}
	StoryLinter.lint_chapter(path, content)
	var fm := _parse_frontmatter(content)
	var meta: Dictionary = fm[0]
	var body := content.substr(fm[1] as int)
	if meta.has("bg_color"):
		meta["bg_color"] = Color.html(meta["bg_color"])
	meta["lines"] = _parse_chapter_body(body)
	return meta


static func load_objects(path: String) -> Dictionary:
	var content := _read(path)
	if content == "":
		return {}
	var result: Dictionary = {}
	var level := ""
	for raw in content.split("\n"):
		var line := raw.strip_edges()
		if line == "":
			continue
		if line.begins_with("# "):
			level = line.substr(2).strip_edges()
			result[level] = {}
		elif level != "":
			var colon := line.find(": ")
			if colon == -1:
				continue
			var key_str := line.left(colon).strip_edges()
			var text_str := line.substr(colon + 2)
			var xy := key_str.split(",")
			if xy.size() == 2:
				var vec := Vector2i(int(xy[0]), int(xy[1]))
				(result[level] as Dictionary)[vec] = {"text": text_str}
	return result


static func load_level_text(path: String) -> Dictionary:
	var content := _read(path)
	if content == "":
		return {}
	var result: Dictionary = {"ambient": {}}
	var section := ""
	var amb_key := ""
	var intro_lines: Array = []
	for raw in content.split("\n"):
		var line := raw.strip_edges()
		if line.begins_with("level_name: "):
			result["level_name"] = line.substr(12)
		elif line.begins_with("## intro"):
			section = "intro"
			intro_lines = []
		elif line.begins_with("## ambient "):
			if section == "intro":
				result["intro"] = _join_lines(intro_lines)
			section = "ambient"
			amb_key = line.substr(11).strip_edges()
			if not (result["ambient"] as Dictionary).has(amb_key):
				(result["ambient"] as Dictionary)[amb_key] = {}
		elif line.begins_with("before: ") and section == "ambient":
			((result["ambient"] as Dictionary)[amb_key] as Dictionary)["before"] = line.substr(8)
		elif line.begins_with("after: ") and section == "ambient":
			((result["ambient"] as Dictionary)[amb_key] as Dictionary)["after"] = line.substr(7)
		elif section == "intro":
			intro_lines.append(raw.strip_edges(false, true))
	if section == "intro":
		result["intro"] = _join_lines(intro_lines)
	return result


static func load_minigame(path: String) -> Dictionary:
	var content := _read(path)
	if content == "":
		return {}
	var result: Dictionary = {}
	var section := ""
	for raw in content.split("\n"):
		var line := raw.strip_edges()
		if line.begins_with("# "):
			section = line.substr(2).strip_edges()
		elif section != "":
			if line.begins_with("- "):
				if not result.has(section):
					result[section] = []
				if result[section] is Array:
					(result[section] as Array).append(line.substr(2))
			elif line != "" and not line.begins_with("#"):
				result[section] = line
	return result


# ── Internals ─────────────────────────────────────────────────────────────────

static func _read(path: String) -> String:
	var fa := FileAccess.open(path, FileAccess.READ)
	if fa == null:
		push_error("StoryLoader: cannot open " + path)
		return ""
	var s := fa.get_as_text()
	fa.close()
	return s


static func _parse_frontmatter(content: String) -> Array:
	var meta := {}
	if not content.begins_with("---"):
		return [meta, 0]
	var end := content.find("\n---", 3)
	if end == -1:
		return [meta, 0]
	for raw in content.substr(4, end - 4).split("\n"):
		var line := raw.strip_edges()
		if line == "":
			continue
		var colon := line.find(": ")
		if colon != -1:
			meta[line.left(colon).strip_edges()] = line.substr(colon + 2).strip_edges()
	return [meta, end + 4]


static func _parse_chapter_body(body: String) -> Array:
	var entries: Array = []
	var current: Dictionary = {}
	var text_lines: Array = []

	for line in body.split("\n"):
		if line.begins_with("["):
			if not current.is_empty():
				current["text"] = _join_lines(text_lines)
				entries.append(current)
			current = {}
			text_lines = []
			var close := line.find("]")
			if close == -1:
				continue
			_apply_tag(current, line.substr(1, close - 1))
			var after := line.substr(close + 1).strip_edges()
			if after != "":
				text_lines.append(after)

		elif line.strip_edges().begins_with("- ") and current.get("_has_choices", false):
			var s := line.strip_edges().substr(2)
			var sep := s.rfind(" >> ")
			var goto_tok := ""
			var choice_text := s
			var choice_entry: Dictionary = {}
			if sep != -1:
				var after_arrow := s.substr(sep + 4).strip_edges()
				# Parse goto label and optional modifiers (next_level: / next_chapter:)
				var tokens := after_arrow.split(" ", false, 1)
				if tokens.size() > 0:
					goto_tok = tokens[0]
				if tokens.size() > 1:
					var mods := tokens[1].strip_edges()
					if mods.begins_with("next_level:"):
						choice_entry["next_level"] = mods.substr(11).strip_edges()
					elif mods.begins_with("next_chapter:"):
						choice_entry["next_chapter"] = mods.substr(13).strip_edges()
				choice_text = s.left(sep).strip_edges()
			choice_entry["text"] = choice_text
			choice_entry["goto"] = goto_tok  # label string; resolved to int index in _resolve_refs
			if not current.has("choices"):
				current["choices"] = []
			(current["choices"] as Array).append(choice_entry)

		else:
			text_lines.append(line)

	if not current.is_empty():
		current["text"] = _join_lines(text_lines)
		entries.append(current)

	for e in entries:
		(e as Dictionary).erase("_has_choices")

	_resolve_refs(entries)
	return entries


# Converts label strings on `next` and choice `goto` into integer entry indices.
# Labels are case-insensitive. Unresolved/duplicate labels push_error (caught by StoryLinter).
static func _resolve_refs(entries: Array) -> void:
	var labels: Dictionary = {}
	for i in entries.size():
		var e: Dictionary = entries[i]
		if e.has("label"):
			var key: String = (e["label"] as String).strip_edges().to_lower()
			if labels.has(key):
				push_error("StoryLoader: duplicate label '%s'" % key)
			labels[key] = i
	for e in entries:
		if e.has("next"):
			e["next"] = _resolve_label(e["next"], labels)
		if e.has("choices"):
			for c in (e["choices"] as Array):
				var cd: Dictionary = c
				if cd.has("next_level") or cd.has("next_chapter"):
					continue  # cross-scene/chapter routing — in-chapter goto unused
				cd["goto"] = _resolve_label(cd.get("goto"), labels)


static func _resolve_label(tok, labels: Dictionary) -> int:
	var key: String = str(tok).strip_edges().to_lower()
	if labels.has(key):
		return labels[key] as int
	push_error("StoryLoader: unresolved label '%s'" % str(tok))
	return -1


static func _apply_tag(entry: Dictionary, tag: String) -> void:
	var parts := tag.split(" ", false)
	if parts.is_empty():
		return
	var speaker: String = parts[0]
	if speaker == "_none":
		entry["speaker"] = "narrator"
		entry["active"] = "none"
		return
	entry["speaker"] = speaker
	entry["active"] = "none"
	for i in range(1, parts.size()):
		var p: String = parts[i]
		if p in ["left", "right", "none"]:
			entry["active"] = p
		elif p == "choices":
			entry["_has_choices"] = true
		elif p == "minigame":
			entry["minigame"] = "civil_servant"
		elif p.begins_with("next:"):
			entry["next"] = p.substr(5)  # label string; resolved to int index in _resolve_refs
		elif p.begins_with("label:"):
			entry["label"] = p.substr(6)
		elif p.begins_with("speed:"):
			entry["speed"] = p.substr(6)
		elif p.begins_with("fx:"):
			var fx: Array = []
			for s in p.substr(3).split(","):
				fx.append(s)
			entry["fx"] = fx
		elif p.begins_with("score:"):
			entry["score"] = p.substr(6)
		elif p.begins_with("sfx:"):
			entry["sfx"] = p.substr(4)


static func _join_lines(lines: Array) -> String:
	while lines.size() > 0 and (lines[0] as String).strip_edges() == "":
		lines.remove_at(0)
	while lines.size() > 0 and (lines[-1] as String).strip_edges() == "":
		lines.remove_at(lines.size() - 1)
	if lines.is_empty():
		return ""
	var parts: PackedStringArray
	for l in lines:
		parts.append(l as String)
	return "\n".join(parts)
