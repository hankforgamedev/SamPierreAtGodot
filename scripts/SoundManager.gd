extends Node

var _ambient_player: AudioStreamPlayer = null
var _score_player: AudioStreamPlayer = null

# Typewriter SFX — pre-created players to avoid per-character allocation.
# Three key variants at staggered pitches rotate in sequence for natural variation.
var _type_clicks: Array[AudioStreamPlayer] = []
var _click_index: int = 0
var _type_ding: AudioStreamPlayer = null
var _ding_cooldown: float = 0.0  # blocks clicks briefly after ding

const _CLICK_PITCHES    := [1.0, 1.02, 0.98]  # slight pitch variation for interest
const _CLICK_PATTERN    := [0, 1, 2, 0, 2, 1]  # rhythm
const _CLICK_JITTER     := 0.03
const _DING_MUTE_DURATION := 0.8

func _ready() -> void:
	var fnames := ["typewriter-single-key-type-1", "typewriter-single-key-type-2", "typewriter-single-key-type-3"]
	for i in fnames.size():
		var p := _make_sfx_player("res://audio/sfx/%s.wav" % fnames[i], -6.0)
		p.pitch_scale = _CLICK_PITCHES[i]
		_type_clicks.append(p)
	_type_ding = _make_sfx_player("res://audio/sfx/typewriter-return-bell.wav", 0.0)

func _process(delta: float) -> void:
	if _ding_cooldown > 0.0:
		_ding_cooldown -= delta

func _make_sfx_player(path: String, volume_db: float) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	if ResourceLoader.exists(path):
		p.stream = load(path)
	p.bus = "SFX"
	p.volume_db = volume_db
	add_child(p)
	return p

func play_type_click() -> void:
	if _type_clicks.is_empty() or _ding_cooldown > 0.0:
		return
	var player := _type_clicks[_CLICK_PATTERN[_click_index]]
	player.pitch_scale = _CLICK_PITCHES[_CLICK_PATTERN[_click_index]] + randf_range(-_CLICK_JITTER, _CLICK_JITTER)
	player.play()
	_click_index = (_click_index + 1) % _CLICK_PATTERN.size()

func play_type_ding() -> void:
	_type_ding.play()
	_ding_cooldown = _DING_MUTE_DURATION

func play_sfx(sfx_name: String) -> void:
	var path := ""
	for ext: String in ["wav", "mp3"]:
		var try_path := "res://audio/sfx/%s.%s" % [sfx_name, ext]
		if ResourceLoader.exists(try_path):
			path = try_path
			break
	if path == "":
		return
	var player := AudioStreamPlayer.new()
	player.stream = load(path)
	player.bus = "SFX"
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func play_ambient(track_name: String) -> void:
	if track_name == "":
		stop_ambient()
		return
	stop_ambient()
	var path := "res://audio/ambient/%s.ogg" % track_name
	if not ResourceLoader.exists(path):
		return
	var player := AudioStreamPlayer.new()
	var stream := load(path) as AudioStreamOggVorbis
	stream.loop = true
	player.stream = stream
	player.bus = "Ambient"
	player.autoplay = false
	add_child(player)
	player.play()
	_ambient_player = player

func stop_ambient() -> void:
	if _ambient_player != null and is_instance_valid(_ambient_player):
		_ambient_player.queue_free()
	_ambient_player = null

func play_score(track_name: String) -> void:
	if track_name == "":
		stop_score()
		return
	stop_score()
	var path := "res://audio/score/%s.mp3" % track_name
	if not ResourceLoader.exists(path):
		return
	var player := AudioStreamPlayer.new()
	var stream := load(path) as AudioStreamMP3
	stream.loop = true
	player.stream = stream
	player.bus = "Master"
	player.autoplay = false
	add_child(player)
	player.play()
	_score_player = player

func stop_score() -> void:
	if _score_player != null and is_instance_valid(_score_player):
		_score_player.queue_free()
	_score_player = null
