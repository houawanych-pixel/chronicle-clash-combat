class_name TouchSurface
extends Control

var move_vector := Vector2.ZERO
var dead_mode := false
var _move_touch := -1
var _move_origin := Vector2.ZERO
var _touches: Dictionary = {}
var _held: Dictionary = {"shield": false}
var _pressed: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process_input(true)
	queue_redraw()


func consume_press(action: String) -> bool:
	if _pressed.get(action, false):
		_pressed[action] = false
		return true
	return false


func is_held(action: String) -> bool:
	return _held.get(action, false)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_touches[event.index] = event.position
			_press_at(event.index, event.position)
		else:
			_release_touch(event.index)
	elif event is InputEventScreenDrag:
		if event.index == _move_touch:
			_touches[event.index] = event.position
			_update_move(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_press_at(999, event.position)
		else:
			_release_touch(999)
	elif (
		event is InputEventMouseMotion
		and _move_touch == 999
		and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	):
		_update_move(event.position)


func _press_at(index: int, point: Vector2) -> void:
	if dead_mode:
		_pressed["restart"] = true
		return
	var s := size
	if point.x < s.x * 0.43 and point.y > s.y * 0.48 and _move_touch < 0:
		_move_touch = index
		_move_origin = point
		_update_move(point)
		queue_redraw()
		return
	var action := _button_at(point)
	if action != "":
		_pressed[action] = true
		if action == "shield":
			_held["shield"] = true
		_touches[index] = action
		queue_redraw()


func _release_touch(index: int) -> void:
	if index == _move_touch:
		_move_touch = -1
		move_vector = Vector2.ZERO
	elif _touches.has(index) and _touches[index] is String and _touches[index] == "shield":
		_held["shield"] = false
	_touches.erase(index)
	queue_redraw()


func _update_move(point: Vector2) -> void:
	var offset := point - _move_origin
	move_vector = offset.limit_length(82.0) / 82.0
	if move_vector.length() < 0.12:
		move_vector = Vector2.ZERO
	queue_redraw()


func _button_positions() -> Dictionary:
	var s := size
	return {
		"attack": Vector2(s.x - 105, s.y - 142),
		"shield": Vector2(s.x - 230, s.y - 92),
		"item_1": Vector2(s.x - 255, s.y - 222),
		"item_2": Vector2(s.x - 126, s.y - 270),
		"swap_items": Vector2(s.x - 355, s.y - 155)
	}


func _button_at(point: Vector2) -> String:
	for action in _button_positions():
		var radius := 48.0 if action == "attack" else (31.0 if action == "swap_items" else 40.0)
		if point.distance_to(_button_positions()[action]) <= radius:
			return action
	return ""


func _draw() -> void:
	var alpha := 0.72
	var joy_center := _move_origin if _move_touch >= 0 else Vector2(135, size.y - 145)
	draw_circle(joy_center, 84, Color(0.04, 0.08, 0.12, 0.36))
	draw_arc(joy_center, 84, 0, TAU, 40, Color(0.7, 0.9, 1.0, 0.4), 3)
	draw_circle(joy_center + move_vector * 58.0, 34, Color(0.55, 0.82, 0.95, 0.65))
	var names := {
		"attack": "SWORD",
		"shield": "SHIELD",
		"item_1": "ITEM 1",
		"item_2": "ITEM 2",
		"swap_items": "SWAP"
	}
	for action in _button_positions():
		var pos: Vector2 = _button_positions()[action]
		var radius := 48.0 if action == "attack" else (31.0 if action == "swap_items" else 40.0)
		var active := _held.get(action, false)
		var color := Color("d9ad45") if action == "attack" else Color("558fb0")
		if action.begins_with("item"):
			color = Color("7363b5")
		if active:
			color = color.lightened(0.28)
		draw_circle(pos, radius, Color(color, alpha))
		draw_arc(pos, radius, 0, TAU, 32, Color(1, 1, 1, 0.62), 3)
		var label: String = names[action]
		var font_size := 15 if action != "swap_items" else 11
		var text_size := ThemeDB.fallback_font.get_string_size(
			label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size
		)
		draw_string(
			ThemeDB.fallback_font,
			pos - Vector2(text_size.x * 0.5, -font_size * 0.35),
			label,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			font_size,
			Color.WHITE
		)
