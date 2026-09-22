class_name CombatInventory
extends RefCounted

signal equipment_changed(slot_one: String, slot_two: String)

var arrows: int = 12
var slot_one := "bow"
var slot_two := "boomerang"


func item_for_slot(slot: int) -> String:
	return slot_one if slot == 1 else slot_two


func cycle_loadout() -> void:
	var old := slot_one
	slot_one = slot_two
	slot_two = old
	equipment_changed.emit(slot_one, slot_two)


func can_use(item: String) -> bool:
	return item != "bow" or arrows > 0


func consume(item: String) -> bool:
	if not can_use(item):
		return false
	if item == "bow":
		arrows -= 1
	return true


func add_arrows(amount: int) -> void:
	arrows = mini(arrows + amount, 30)
	equipment_changed.emit(slot_one, slot_two)
