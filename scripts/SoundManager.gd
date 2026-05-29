extends Node

var _ambient_player: AudioStreamPlayer = null

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
	player.stream = load(path)
	player.bus = "Ambient"
	player.autoplay = false
	add_child(player)
	player.play()
	_ambient_player = player

func stop_ambient() -> void:
	if _ambient_player != null and is_instance_valid(_ambient_player):
		_ambient_player.queue_free()
	_ambient_player = null
