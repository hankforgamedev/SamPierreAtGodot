extends Node

var _ambient_player: AudioStreamPlayer = null

# Typewriter SFX — pre-created players to avoid per-character allocation.
# Three key variants rotate in sequence for natural variation.
var _type_clicks: Array[AudioStreamPlayer] = []
var _click_index: int = 0
var _type_ding: AudioStreamPlayer = null

func _ready() -> void:
	for fname in ["typewriter-single-key-type-1", "typewriter-single-key-type-2", "typewriter-single-key-type-3"]:
		_type_clicks.append(_make_sfx_player("res://audio/sfx/%s.wav" % fname, -6.0))
	_type_ding = _make_sfx_player("res://audio/sfx/typewriter-return-bell.wav", 0.0)

func _make_sfx_player(path: String, volume_db: float) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	if ResourceLoader.exists(path):
		p.stream = load(path)
	p.bus = "SFX"
	p.volume_db = volume_db
	add_child(p)
	return p

func play_type_click() -> void:
	if _type_clicks.is_empty():
		return
	_type_clicks[_click_index].play()
	_click_index = (_click_index + 1) % _type_clicks.size()

func play_type_ding() -> void:
	_type_ding.play()

func play_sfx(sfx_name: String) -> void:
	var path := "res://audio/sfx/%s.wav" % sfx_name
	if not ResourceLoader.exists(path):
		return
	var player := AudioStreamPlayer.new()
	player.stream = load(path)
	player.bus = "SFX"
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func play_ambient(track_name: String) -> void:
	if track_name == "":
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
