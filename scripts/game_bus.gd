class_name GameBus
extends Node

static var sound: SoundManager


static func sfx(kind: String) -> void:
	if is_instance_valid(sound):
		sound.play_sfx(kind)
