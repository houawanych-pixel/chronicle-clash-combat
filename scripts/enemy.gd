class_name ArenaEnemy
extends CharacterBody2D

signal defeated(enemy: ArenaEnemy)

enum State { WANDER, CHASE, WINDUP, RECOVER, HURT }

var target: Node2D
var health := 5
var max_health := 5
var move_speed := 110.0
var state := State.WANDER
var variant := 0
var _state_time := 0.0
var _wander_direction := Vector2.ZERO
var _knockback := Vector2.ZERO
var _flash := 0.0


func setup(p_target: Node2D, p_position: Vector2, p_variant: int = 0) -> ArenaEnemy:
	target = p_target
	position = p_position
	variant = p_variant
	if variant == 1:
		health = 7
		max_health = 7
		move_speed = 86.0
	return self


func _ready() -> void:
	add_to_group("enemies")
	add_to_group("damageables")
	collision_layer = 4
	collision_mask = 1 | 2 | 4
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 18 if variant == 0 else 22
	collision.shape = shape
	add_child(collision)
	_state_time = randf_range(0.4, 1.4)
	_wander_direction = Vector2.RIGHT.rotated(randf() * TAU)
	queue_redraw()


func _physics_process(delta: float) -> void:
	_state_time -= delta
	_flash = maxf(0.0, _flash - delta)
	_knockback = _knockback.move_toward(Vector2.ZERO, 850.0 * delta)
	if not is_instance_valid(target):
		return
	var distance := global_position.distance_to(target.global_position)
	match state:
		State.WANDER:
			velocity = _wander_direction * move_speed * 0.42 + _knockback
			if distance < 290.0:
				_change_state(State.CHASE, 0.0)
			elif _state_time <= 0.0:
				_wander_direction = Vector2.RIGHT.rotated(randf() * TAU)
				_state_time = randf_range(0.7, 1.8)
		State.CHASE:
			velocity = (
				global_position.direction_to(target.global_position) * move_speed + _knockback
			)
			if distance < 50.0:
				_change_state(State.WINDUP, 0.28 if variant == 0 else 0.42)
			elif distance > 420.0:
				_change_state(State.WANDER, 1.0)
		State.WINDUP:
			velocity = _knockback
			if _state_time <= 0.0:
				_attack_target()
				_change_state(State.RECOVER, 0.55)
		State.RECOVER:
			velocity = _knockback
			if _state_time <= 0.0:
				_change_state(State.CHASE, 0.0)
		State.HURT:
			velocity = _knockback
			if _state_time <= 0.0:
				_change_state(State.CHASE, 0.0)
	move_and_slide()
	queue_redraw()


func _change_state(next: State, duration: float) -> void:
	state = next
	_state_time = duration


func _attack_target() -> void:
	if is_instance_valid(target) and global_position.distance_to(target.global_position) < 64.0:
		target.take_damage(1 if variant == 0 else 2, global_position, 285.0)


func take_damage(amount: int, source_position: Vector2, force: float = 220.0) -> void:
	if state == State.HURT and _state_time > 0.08:
		return
	health -= amount
	_flash = 0.13
	_knockback = source_position.direction_to(global_position) * force
	_change_state(State.HURT, 0.22)
	GameBus.sfx("hit")
	if health <= 0:
		_die()


func _die() -> void:
	defeated.emit(self)
	queue_free()


func _draw() -> void:
	var body_color := (
		Color.WHITE if _flash > 0.0 else (Color("9d62dd") if variant == 0 else Color("d65345"))
	)
	var radius := 18.0 if variant == 0 else 22.0
	if state == State.WINDUP:
		draw_circle(Vector2.ZERO, radius + 7, Color(1, 0.3, 0.15, 0.35))
	draw_circle(Vector2(0, 4), radius, body_color)
	draw_circle(Vector2(-7, -3), 5, Color("f6e7bc"))
	draw_circle(Vector2(7, -3), 5, Color("f6e7bc"))
	draw_circle(Vector2(-6, -2), 2, Color("251d31"))
	draw_circle(Vector2(8, -2), 2, Color("251d31"))
	draw_colored_polygon(
		PackedVector2Array([Vector2(-radius, 7), Vector2(-radius - 7, 16), Vector2(-7, 12)]),
		body_color.darkened(0.2)
	)
	draw_colored_polygon(
		PackedVector2Array([Vector2(radius, 7), Vector2(radius + 7, 16), Vector2(7, 12)]),
		body_color.darkened(0.2)
	)
	if health < max_health:
		draw_rect(Rect2(-22, -31, 44, 5), Color("251b2b"))
		draw_rect(Rect2(-21, -30, 42.0 * float(health) / max_health, 3), Color("75e68b"))
