class_name BreakableProp
extends StaticBody2D

var health := 2


func setup(p_position: Vector2) -> BreakableProp:
	position = p_position
	return self


func _ready() -> void:
	add_to_group("damageables")
	collision_layer = 1
	collision_mask = 0
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 17
	collision.shape = shape
	add_child(collision)
	queue_redraw()


func take_damage(amount: int, _source: Vector2, _force: float = 0.0) -> void:
	health -= amount
	if health <= 0:
		var pickup := WorldPickup.new().setup("arrows", global_position)
		get_parent().call_deferred("add_child", pickup)
		GameBus.sfx("hit")
		queue_free()
	else:
		GameBus.sfx("block")


func _draw() -> void:
	draw_circle(Vector2(0, 5), 18, Color("6f472d"))
	draw_rect(Rect2(-17, -8, 34, 22), Color("9b633b"))
	draw_line(Vector2(-17, -2), Vector2(17, -2), Color("d0a365"), 3)
	draw_line(Vector2(-9, -8), Vector2(-9, 14), Color("5c3826"), 2)
	draw_line(Vector2(9, -8), Vector2(9, 14), Color("5c3826"), 2)
