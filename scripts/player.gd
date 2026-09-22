class_name HeroPlayer
extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal inventory_changed(inventory: CombatInventory)
signal died

const SPEED := 245.0
const ACCELERATION := 1800.0

var max_health := 8
var health := 8
var facing := Vector2.DOWN
var inventory := CombatInventory.new()
var weapons := WeaponController.new()
var controls: Node
var shield_held := false
var invulnerable_time := 0.0
var _knockback := Vector2.ZERO
var _flash := 0.0
var _attack_arc_time := 0.0
var _attack_arc_direction := Vector2.DOWN
var _attack_arc_combo := 1
var _dead := false


func _ready() -> void:
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1 | 4 | 32
	var collision := CollisionShape2D.new()
	var shape := CapsuleShape2D.new()
	shape.radius = 13
	shape.height = 30
	collision.shape = shape
	collision.position = Vector2(0, 4)
	add_child(collision)
	add_child(weapons)
	weapons.setup(self, inventory)
	inventory.equipment_changed.connect(_on_equipment_changed)
	var camera := Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 1600
	camera.limit_bottom = 1000
	add_child(camera)
	health_changed.emit(health, max_health)
	inventory_changed.emit(inventory)
	queue_redraw()


func _physics_process(delta: float) -> void:
	if _dead:
		velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION * delta)
		move_and_slide()
		return
	weapons.tick(delta)
	invulnerable_time = maxf(0.0, invulnerable_time - delta)
	_flash = maxf(0.0, _flash - delta)
	_attack_arc_time = maxf(0.0, _attack_arc_time - delta)
	_knockback = _knockback.move_toward(Vector2.ZERO, 1050.0 * delta)
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if is_instance_valid(controls):
		var touch_move: Vector2 = controls.move_vector
		if touch_move.length() > input_vector.length():
			input_vector = touch_move
	shield_held = (
		Input.is_action_pressed("shield")
		or (is_instance_valid(controls) and controls.is_held("shield"))
	)
	if input_vector.length() > 0.12:
		facing = input_vector.normalized()
	var desired := input_vector.normalized() * SPEED * (0.48 if shield_held else 1.0)
	velocity = velocity.move_toward(desired, ACCELERATION * delta) + _knockback
	move_and_slide()
	_handle_actions()
	queue_redraw()


func _handle_actions() -> void:
	if _action_just_pressed("attack"):
		weapons.sword_attack(facing)
	if _action_just_pressed("item_1"):
		if weapons.use_item(1, facing):
			inventory_changed.emit(inventory)
	if _action_just_pressed("item_2"):
		if weapons.use_item(2, facing):
			inventory_changed.emit(inventory)
	if _action_just_pressed("swap_items"):
		inventory.cycle_loadout()
		GameBus.sfx("pickup")


func _action_just_pressed(action: String) -> bool:
	return (
		Input.is_action_just_pressed(action)
		or (is_instance_valid(controls) and controls.consume_press(action))
	)


func show_attack_arc(direction: Vector2, combo: int) -> void:
	_attack_arc_direction = direction
	_attack_arc_combo = combo
	_attack_arc_time = 0.13
	queue_redraw()


func take_damage(amount: int, source_position: Vector2, force: float = 260.0) -> void:
	if _dead or invulnerable_time > 0.0:
		return
	var toward_source := global_position.direction_to(source_position)
	if shield_held and facing.dot(toward_source) > 0.15:
		_knockback = source_position.direction_to(global_position) * force * 0.32
		invulnerable_time = 0.18
		GameBus.sfx("block")
		return
	health = maxi(health - amount, 0)
	invulnerable_time = 0.72
	_flash = 0.14
	_knockback = source_position.direction_to(global_position) * force
	GameBus.sfx("hurt")
	health_changed.emit(health, max_health)
	if health <= 0:
		_dead = true
		GameBus.sfx("death")
		died.emit()


func collect_pickup(kind: String, amount: int) -> void:
	if kind == "heart":
		health = mini(max_health, health + amount)
		health_changed.emit(health, max_health)
	else:
		inventory.add_arrows(amount + 1)
		inventory_changed.emit(inventory)
	GameBus.sfx("pickup")


func _on_equipment_changed(_one: String, _two: String) -> void:
	inventory_changed.emit(inventory)


func _draw() -> void:
	var body := Color.WHITE if _flash > 0.0 else Color("3e8ed0")
	if invulnerable_time > 0.0 and int(invulnerable_time * 18.0) % 2 == 0:
		body.a = 0.45
	draw_circle(Vector2(0, 3), 18, Color("16222c"))
	draw_circle(Vector2(0, 0), 17, body)
	draw_circle(Vector2(0, -13), 12, Color("efc89f"))
	draw_colored_polygon(
		PackedVector2Array(
			[Vector2(-13, -12), Vector2(0, -26), Vector2(13, -12), Vector2(8, -7), Vector2(-9, -7)]
		),
		Color("e8c24f")
	)
	var eye_side := facing.x * 3.0
	draw_circle(Vector2(-4 + eye_side, -13), 1.7, Color("1c2530"))
	draw_circle(Vector2(4 + eye_side, -13), 1.7, Color("1c2530"))
	if shield_held:
		var shield_pos := facing * 25.0
		draw_circle(shield_pos, 13, Color("d8b34b"))
		draw_arc(shield_pos, 10, 0, TAU, 20, Color("eef5f7"), 3)
	if _attack_arc_time > 0.0:
		var angle := _attack_arc_direction.angle()
		draw_arc(
			_attack_arc_direction * 17.0,
			38,
			angle - 0.9,
			angle + 0.9,
			20,
			Color("fff0ab"),
			8 if _attack_arc_combo == 2 else 6
		)
		draw_arc(
			_attack_arc_direction * 17.0, 43, angle - 0.9, angle + 0.9, 20, Color(1, 1, 1, 0.55), 3
		)
