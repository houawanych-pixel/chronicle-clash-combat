class_name CombatProjectile
extends Area2D

enum Kind { ARROW, BOOMERANG }

var kind := Kind.ARROW
var direction := Vector2.RIGHT
var speed := 620.0
var damage := 2
var owner_player: Node2D
var _age := 0.0
var _returning := false
var _hit_ids: Dictionary = {}


func setup(p_kind: Kind, p_direction: Vector2, p_owner: Node2D) -> CombatProjectile:
	kind = p_kind
	direction = p_direction.normalized()
	owner_player = p_owner
	global_position = p_owner.global_position + direction * 30.0
	rotation = direction.angle()
	if kind == Kind.BOOMERANG:
		speed = 430.0
		damage = 1
	return self


func _ready() -> void:
	collision_layer = 8
	collision_mask = 1 | 4
	var collision := CollisionShape2D.new()
	if kind == Kind.ARROW:
		var shape := RectangleShape2D.new()
		shape.size = Vector2(30, 8)
		collision.shape = shape
	else:
		var shape := CircleShape2D.new()
		shape.radius = 14
		collision.shape = shape
	add_child(collision)
	body_entered.connect(_on_body_entered)
	queue_redraw()


func _physics_process(delta: float) -> void:
	_age += delta
	if kind == Kind.ARROW:
		position += direction * speed * delta
		if _age > 1.25:
			queue_free()
	else:
		rotation += delta * 15.0
		if _age > 0.42:
			_returning = true
		if _returning and is_instance_valid(owner_player):
			direction = global_position.direction_to(owner_player.global_position)
		position += direction * speed * delta
		if (
			_returning
			and is_instance_valid(owner_player)
			and global_position.distance_to(owner_player.global_position) < 28.0
		):
			queue_free()
		elif _age > 2.0:
			queue_free()


func _draw() -> void:
	if kind == Kind.ARROW:
		draw_line(Vector2(-15, 0), Vector2(13, 0), Color("f4dfaa"), 4)
		draw_colored_polygon(
			PackedVector2Array([Vector2(14, 0), Vector2(6, -7), Vector2(6, 7)]), Color("c9d5db")
		)
		draw_line(Vector2(-13, 0), Vector2(-18, -6), Color("73b9e6"), 3)
		draw_line(Vector2(-13, 0), Vector2(-18, 6), Color("73b9e6"), 3)
	else:
		draw_arc(Vector2.ZERO, 12, -2.5, 0.7, 18, Color("f5c34f"), 6)
		draw_circle(Vector2(10, 6), 4, Color("fff0ad"))


func _on_body_entered(body: Node) -> void:
	if body == owner_player:
		return
	if body.has_method("take_damage"):
		var id := body.get_instance_id()
		if not _hit_ids.has(id):
			_hit_ids[id] = true
			body.take_damage(damage, global_position, 210.0)
			GameBus.sfx("hit")
		if kind == Kind.ARROW:
			queue_free()
	elif kind == Kind.ARROW:
		queue_free()
	else:
		_returning = true
