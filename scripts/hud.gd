class_name CombatHUD
extends CanvasLayer

var health_label: Label
var arrow_label: Label
var slot_one: Label
var slot_two: Label
var message: Label
var death_panel: ColorRect
var help_panel: PanelContainer


func _ready() -> void:
	layer = 10
	_build_hud()


func _label(text: String, size: int = 22) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color("fff3c4"))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	return label


func _build_hud() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	health_label = _label("HEARTS", 25)
	health_label.position = Vector2(28, 22)
	root.add_child(health_label)
	arrow_label = _label("ARROWS 12", 19)
	arrow_label.position = Vector2(31, 58)
	root.add_child(arrow_label)
	var objective := _label("TRAINING GROUNDS  •  Defeat the raiders", 18)
	objective.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	objective.set_anchors_preset(Control.PRESET_TOP_WIDE)
	objective.offset_top = 18
	objective.offset_bottom = 50
	root.add_child(objective)
	slot_one = _label("ITEM 1  BOW", 17)
	slot_one.position = Vector2(28, 97)
	root.add_child(slot_one)
	slot_two = _label("ITEM 2  BOOMERANG", 17)
	slot_two.position = Vector2(28, 124)
	root.add_child(slot_two)
	message = _label("", 22)
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.set_anchors_preset(Control.PRESET_CENTER_TOP)
	message.position = Vector2(-220, 64)
	message.size = Vector2(440, 40)
	root.add_child(message)
	help_panel = PanelContainer.new()
	help_panel.position = Vector2(360, 530)
	help_panel.size = Vector2(560, 118)
	var help_text := "MOVE: WASD / arrows     SWORD: J / Space     SHIELD: K\n"
	help_text += "ITEMS: U / I     SWAP LOADOUT: Q / Tab\n"
	help_text += "Touch controls are ready on phones and tablets."
	var help := _label(help_text, 17)
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	help_panel.add_child(help)
	root.add_child(help_panel)
	var tween := create_tween()
	tween.tween_interval(5.0)
	tween.tween_property(help_panel, "modulate:a", 0.0, 1.0)
	tween.tween_callback(help_panel.hide)
	death_panel = ColorRect.new()
	death_panel.color = Color(0.04, 0.02, 0.04, 0.78)
	death_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	death_panel.hide()
	root.add_child(death_panel)
	var dead_text := _label("FALLEN IN BATTLE\n\nTap anywhere or press R to restart", 36)
	dead_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dead_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	dead_text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	death_panel.add_child(dead_text)


func update_health(current: int, maximum: int) -> void:
	var full := "♥".repeat(current)
	var empty := "♡".repeat(maximum - current)
	health_label.text = full + empty


func update_inventory(inventory: CombatInventory) -> void:
	arrow_label.text = "ARROWS  %02d" % inventory.arrows
	slot_one.text = "ITEM 1  " + inventory.slot_one.to_upper()
	slot_two.text = "ITEM 2  " + inventory.slot_two.to_upper()


func announce(text: String, duration := 1.4) -> void:
	message.text = text
	message.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_interval(duration)
	tween.tween_property(message, "modulate:a", 0.0, 0.35)


func show_death() -> void:
	death_panel.show()
