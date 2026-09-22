class_name WorldPickup
extends Area2D

var kind := "heart"
var amount := 2
var _time := 0.0


func setup(p_kind: String, p_position: Vector2) -> WorldPickup:
	kind = p_kind
	position = p_position
	return self


func _ready() -> void:
	collision_layer = 32
	collision_mask = 2
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 14.0
	shape.shape = circle
	add_child(shape)
	body_entered.connect(_on_body_entered)
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var bob := sin(_time * 5.0) * 3.0
	if kind == "heart":
		draw_circle(Vector2(-6, bob - 2), 7, Color("ff5a67"))
		draw_circle(Vector2(6, bob - 2), 7, Color("ff5a67"))
		var points := PackedVector2Array(
			[Vector2(-12, bob), Vector2(12, bob), Vector2(0, bob + 15)]
		)
		draw_colored_polygon(points, Color("ff5a67"))
	else:
		draw_colored_polygon(
			PackedVector2Array([Vector2(-4, bob - 13), Vector2(5, bob), Vector2(-4, bob + 13)]),
			Color("f6e4a5")
		)
		draw_line(Vector2(-7, bob - 14), Vector2(-7, bob + 14), Color("7d4d2d"), 3)


func _on_body_entered(body: Node) -> void:
	if body.has_method("collect_pickup"):
		body.collect_pickup(kind, amount)
		queue_free()
