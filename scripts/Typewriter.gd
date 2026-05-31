class_name Typewriter
extends RefCounted
# Shared reveal-cursor for both dialogue systems (GameScene VN page-flip +
# WorldDialogue scrollback). Owns only the reveal cadence and speed resolution.
# The text string and HOW it renders (replace page vs append to log) stay with
# each owner — that behavior is intentionally distinct per scene type.

var count : int  = 0       # chars revealed so far
var active: bool = false    # true while still revealing

var _timer: float = 0.0
var _speed: float = GameTheme.SPEED_NORMAL
var _len  : int   = 0

func start(text_length: int, speed_tag: String = "normal") -> void:
	count  = 0
	_timer = 0.0
	_speed = resolve_speed(speed_tag)
	_len   = text_length
	active = text_length > 0

# Advance the cursor by elapsed time. Returns chars newly revealed this frame
# (so the owner can fire that many type-click SFX).
func tick(delta: float) -> int:
	if not active:
		return 0
	_timer += delta
	var added := 0
	while _timer >= _speed and count < _len:
		_timer -= _speed
		count  += 1
		added  += 1
	if count >= _len:
		active = false
	return added

func finish() -> void:
	count  = _len
	active = false

func complete() -> bool:
	return count >= _len

static func resolve_speed(speed_tag: String) -> float:
	match speed_tag:
		"fast": return GameTheme.SPEED_FAST
		"slow": return GameTheme.SPEED_SLOW
		_:      return GameTheme.SPEED_NORMAL
