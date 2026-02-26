extends Node
## AudioManager — SFX and music playback.

var _sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX := 4


func _ready() -> void:
	for i in MAX_SFX:
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_sfx_players.append(player)


func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	for player in _sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
			player.play()
			return
	# Fallback: use first player
	_sfx_players[0].stream = stream
	_sfx_players[0].volume_db = volume_db
	_sfx_players[0].play()


func stop_sfx(stream: AudioStream) -> void:
	for player in _sfx_players:
		if player.playing and player.stream == stream:
			player.stop()
