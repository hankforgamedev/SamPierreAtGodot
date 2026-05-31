class_name StoryLinter

const VALID_SPEAKERS: PackedStringArray = [
	"sam", "rat", "lee", "rachel", "sarah", "bill", "moujia", "david", "narrator", "_none", "inner"
]
const VALID_POSITIONS: PackedStringArray = ["left", "right", "none"]
const VALID_CHARS: PackedStringArray = [
	"sam", "rat", "lee", "rachel", "sarah", "bill", "moujia", "david", "narrator"
]
const VALID_SPEEDS: PackedStringArray = ["fast", "slow"]
const VALID_FX: PackedStringArray = ["shake", "flash_white", "flash_black", "glitch_spike", "train"]


static func lint_chapter(path: String, content: String) -> void:
	if "\r\n" in content:
		push_error("StoryLinter [%s]: CRLF line endings — save file as LF (Unix). Speaker names will break." % path)

	if not content.begins_with("---"):
		push_error("StoryLinter [%s]: Missing frontmatter — file must start with ---" % path)
		return

	var end_fm := content.find("\n---", 3)
	if end_fm == -1:
		push_error("StoryLinter [%s]: Unclosed frontmatter — missing closing ---" % path)
		return

	var fm := _parse_fm(content.substr(4, end_fm - 4))
	var fm_lines: int = content.substr(0, end_fm + 4).count("\n") + 1

	if not fm.has("id"):
		push_error("StoryLinter [%s]: Frontmatter missing required field: id" % path)
	if not fm.has("title"):
		push_error("StoryLinter [%s]: Frontmatter missing required field: title" % path)
	if fm.has("bg_color") and not Color.html_is_valid(fm["bg_color"] as String):
		push_error("StoryLinter [%s]: bg_color invalid hex '%s' — use #rrggbb format" % [path, fm["bg_color"]])
	for field in ["left_char", "right_char"]:
		if fm.has(field) and (fm[field] as String) not in VALID_CHARS:
			push_error("StoryLinter [%s]: %s unknown value '%s'" % [path, field, fm[field]])

	var body := content.substr(end_fm + 4)
	var body_lines := body.split("\n")
	var in_choices := false

	# Pre-scan: collect all defined labels (case-insensitive) so refs can be validated.
	var labels: Dictionary = {}
	for bl: String in body_lines:
		var st := bl.strip_edges()
		if not st.begins_with("["):
			continue
		var cl := st.find("]")
		if cl == -1:
			continue
		for tk: String in st.substr(1, cl - 1).split(" ", false):
			if tk.begins_with("label:"):
				var lk := tk.substr(6).strip_edges().to_lower()
				if lk == "":
					push_error("StoryLinter [%s]: label: must have a value" % path)
				elif labels.has(lk):
					push_error("StoryLinter [%s]: duplicate label '%s'" % [path, lk])
				else:
					labels[lk] = true

	for i in body_lines.size():
		var line: String = body_lines[i]
		var stripped := line.strip_edges()
		if stripped == "":
			continue
		var ln: int = fm_lines + i + 1

		if stripped.begins_with("["):
			in_choices = false
			var close := line.find("]")
			if close == -1:
				push_error("StoryLinter [%s:%d]: Tag missing ] — %s" % [path, ln, stripped])
				continue

			var tag := line.substr(1, close - 1)
			var parts := tag.split(" ", false)
			if parts.is_empty():
				push_error("StoryLinter [%s:%d]: Empty tag []" % [path, ln])
				continue

			var speaker: String = parts[0]
			if speaker == "_none":
				continue

			if speaker not in VALID_SPEAKERS:
				push_error("StoryLinter [%s:%d]: Unknown speaker '%s'" % [path, ln, speaker])

			if parts.size() < 2:
				push_error("StoryLinter [%s:%d]: Tag missing position — [%s] needs left/right/none" % [path, ln, speaker])
				continue

			var pos_found := false
			for j in range(1, parts.size()):
				var p: String = parts[j]
				if p in VALID_POSITIONS:
					pos_found = true
				elif p == "choices":
					in_choices = true
				elif p == "minigame":
					pass
				elif p.begins_with("label:"):
					pass  # collected + dup-checked in pre-scan
				elif p.begins_with("next:"):
					var val := p.substr(5).strip_edges()
					if not labels.has(val.to_lower()):
						push_error("StoryLinter [%s:%d]: next: unknown label '%s'" % [path, ln, val])
				elif p.begins_with("speed:"):
					var val := p.substr(6)
					if val not in VALID_SPEEDS:
						push_error("StoryLinter [%s:%d]: speed '%s' invalid — use fast or slow" % [path, ln, val])
				elif p.begins_with("fx:"):
					var raw := p.substr(3)
					if " " in raw:
						push_error("StoryLinter [%s:%d]: fx values must not have spaces — use fx:shake,flash_white" % [path, ln])
					for fx: String in raw.split(","):
						var fx_clean := fx.strip_edges()
						if fx_clean != "" and fx_clean not in VALID_FX:
							push_error("StoryLinter [%s:%d]: Unknown fx '%s'" % [path, ln, fx_clean])
				elif p.begins_with("sfx:"):
					var val := p.substr(4)
					if val == "":
						push_error("StoryLinter [%s:%d]: sfx: must have a value" % [path, ln])
				elif p.begins_with("score:"):
					var val := p.substr(6)
					if val == "":
						push_error("StoryLinter [%s:%d]: score: must have a value" % [path, ln])
				else:
					push_error("StoryLinter [%s:%d]: Unknown tag modifier '%s'" % [path, ln, p])

			if not pos_found:
				push_error("StoryLinter [%s:%d]: Tag missing position (left/right/none) — [%s]" % [path, ln, tag])

		elif stripped.begins_with("- ") and in_choices:
			var s := stripped.substr(2)
			var sep := s.rfind(" >> ")
			if sep == -1:
				push_error("StoryLinter [%s:%d]: Choice missing '>> N' — %s" % [path, ln, stripped])
			else:
				var after_arrow := s.substr(sep + 4).strip_edges()
				var tokens := after_arrow.split(" ", false, 1)
				var goto_str := tokens[0] if tokens.size() > 0 else ""
				var has_cross := tokens.size() > 1 and (tokens[1].strip_edges().begins_with("next_level:") or tokens[1].strip_edges().begins_with("next_chapter:"))
				if not has_cross and not labels.has(goto_str.to_lower()):
					push_error("StoryLinter [%s:%d]: Choice >> unknown label '%s'" % [path, ln, goto_str])
				if tokens.size() > 1:
					var mods := tokens[1].strip_edges()
					if not mods.begins_with("next_level:") and not mods.begins_with("next_chapter:"):
						push_error("StoryLinter [%s:%d]: Unknown choice modifier '%s' — use next_level: or next_chapter:" % [path, ln, mods])


static func _parse_fm(fm_text: String) -> Dictionary:
	var result: Dictionary = {}
	for raw: String in fm_text.split("\n"):
		var line := raw.strip_edges()
		if line == "":
			continue
		var colon := line.find(": ")
		if colon != -1:
			result[line.left(colon).strip_edges()] = line.substr(colon + 2).strip_edges()
	return result
