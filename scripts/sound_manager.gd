class_name SoundManager
extends Node

var _players: Array[AudioStreamPlayer] = []
var _cursor := 0


func _ready() -> void:
	for i in 8:
		var player := AudioStreamPlayer.new()
		player.volume_db = -8.0
		add_child(player)
		_players.append(player)


func play_sfx(kind: String) -> void:
	var settings := (
		{
			"sword": [390.0, 0.075, 0],
			"hit": [120.0, 0.09, 2],
			"block": [740.0, 0.08, 1],
			"bow": [520.0, 0.07, 1],
			"boom": [260.0, 0.12, 1],
			"pickup": [880.0, 0.10, 0],
			"hurt": [92.0, 0.14, 2],
			"death": [70.0, 0.32, 2]
		}
		. get(kind, [300.0, 0.08, 0])
	)
	var player := _players[_cursor]
	_cursor = (_cursor + 1) % _players.size()
	player.stream = _make_tone(settings[0], settings[1], settings[2])
	player.pitch_scale = randf_range(0.96, 1.04)
	player.play()


func _make_tone(frequency: float, duration: float, waveform: int) -> AudioStreamWAV:
	var rate := 22050
	var count := int(duration * rate)
	var bytes := PackedByteArray()
	bytes.resize(count * 2)
	for i in count:
		var t := float(i) / rate
		var phase := TAU * frequency * t
		var wave := sin(phase)
		if waveform == 1:
			wave = 1.0 if wave >= 0.0 else -1.0
		elif waveform == 2:
			wave = randf_range(-1.0, 1.0) * 0.65 + wave * 0.35
		var envelope := pow(1.0 - float(i) / count, 1.7)
		var sample := int(clampf(wave * envelope * 15000.0, -32768.0, 32767.0))
		bytes[i * 2] = sample & 0xff
		bytes[i * 2 + 1] = (sample >> 8) & 0xff
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.stereo = false
	wav.data = bytes
	return wav
