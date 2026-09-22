class_name MobileControls
extends CanvasLayer

var surface: TouchSurface
var move_vector: Vector2:
	get:
		return surface.move_vector if is_instance_valid(surface) else Vector2.ZERO


func _ready() -> void:
	layer = 20
	surface = TouchSurface.new()
	add_child(surface)
	surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func consume_press(action: String) -> bool:
	return surface.consume_press(action)


func is_held(action: String) -> bool:
	return surface.is_held(action)


func set_dead_mode(enabled: bool) -> void:
	surface.dead_mode = enabled
