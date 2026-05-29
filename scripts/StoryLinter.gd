class_name StoryLinter

const VALID_SPEAKERS: PackedStringArray = [
	"sam", "rat", "lee", "rachel", "sarah", "bill", "moujia", "david", "narrator", "_none", "inner"
]
const VALID_POSITIONS: PackedStringArray = ["left", "right", "none"]
const VALID_CHARS: PackedStringArray = [
	"sam", "rat", "lee", "rachel", "sarah", "bill", "moujia", "david", "narrator"
]
const VALID_SPEEDS: PackedStringArray = ["fast", "slow"]
const VALID_FX: PackedStringArray = ["shake", "flash_white", "flash_black", "glitch_spike"]


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
				elif p.begins_with("next:"):
					var val := p.substr(5)
					if not val.is_valid_int():
						push_error("StoryLinter [%s:%d]: next: must be integer, got '%s'" % [path, ln, val])
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
				var goto_str := s.substr(sep + 4).strip_edges()
				if not goto_str.is_valid_int():
					push_error("StoryLinter [%s:%d]: Choice >> target must be integer, got '%s'" % [path, ln, goto_str])


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
