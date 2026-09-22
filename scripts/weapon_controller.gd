class_name WeaponController
extends Node

signal cooldown_changed(attack_ready: bool, item_ready: bool)

var actor: CharacterBody2D
var inventory: CombatInventory
var attack_cooldown := 0.0
var item_cooldown := 0.0
var combo_step := 0
var combo_window := 0.0


func setup(p_actor: CharacterBody2D, p_inventory: CombatInventory) -> void:
	actor = p_actor
	inventory = p_inventory


func tick(delta: float) -> void:
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	item_cooldown = maxf(0.0, item_cooldown - delta)
	combo_window = maxf(0.0, combo_window - delta)
	if combo_window <= 0.0:
		combo_step = 0


func sword_attack(direction: Vector2) -> bool:
	if attack_cooldown > 0.0:
		return false
	combo_step = (combo_step % 2) + 1 if combo_window > 0.0 else 1
	combo_window = 0.44
	attack_cooldown = 0.24 if combo_step == 1 else 0.31
	GameBus.sfx("sword")
	actor.show_attack_arc(direction, combo_step)
	var hit_any := false
	for enemy in actor.get_tree().get_nodes_in_group("damageables"):
		if not is_instance_valid(enemy):
			continue
		var offset: Vector2 = enemy.global_position - actor.global_position
		if offset.length() <= 64.0 and direction.dot(offset.normalized()) > 0.25:
			enemy.take_damage(
				2 if combo_step == 1 else 3,
				actor.global_position,
				250.0 if combo_step == 1 else 340.0
			)
			hit_any = true
	return true


func use_item(slot: int, direction: Vector2) -> bool:
	if item_cooldown > 0.0:
		return false
	var item := inventory.item_for_slot(slot)
	if item == "boomerang" and actor.get_tree().get_nodes_in_group("boomerangs").size() > 0:
		return false
	if not inventory.consume(item):
		GameBus.sfx("block")
		return false
	var kind := CombatProjectile.Kind.ARROW if item == "bow" else CombatProjectile.Kind.BOOMERANG
	var projectile := CombatProjectile.new().setup(kind, direction, actor)
	actor.get_parent().add_child(projectile)
	if item == "boomerang":
		projectile.add_to_group("boomerangs")
		GameBus.sfx("boom")
		item_cooldown = 0.55
	else:
		GameBus.sfx("bow")
		item_cooldown = 0.25
	return true
