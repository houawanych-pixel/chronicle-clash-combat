extends Node2D

const ARENA_SIZE := Vector2(1600, 1000)

var player: HeroPlayer
var hud: CombatHUD
var controls: MobileControls
var sound: SoundManager
var defeated_count := 0
var wave_size := 7
var game_over := false


func _ready() -> void:
	seed(24680)
	_ensure_input_actions()
	sound = SoundManager.new()
	add_child(sound)
	GameBus.sound = sound
	_build_arena_collision()
	hud = CombatHUD.new()
	add_child(hud)
	controls = MobileControls.new()
	add_child(controls)
	player = HeroPlayer.new()
	player.position = Vector2(800, 520)
	player.health_changed.connect(hud.update_health)
	player.inventory_changed.connect(hud.update_inventory)
	player.died.connect(_on_player_died)
	add_child(player)
	player.controls = controls
	hud.update_health(player.health, player.max_health)
	hud.update_inventory(player.inventory)
	_spawn_wave()
	for prop_position in [
		Vector2(450, 320), Vector2(1160, 350), Vector2(510, 760), Vector2(1090, 720)
	]:
		add_child(BreakableProp.new().setup(prop_position))
	queue_redraw()


func _process(_delta: float) -> void:
	if game_over and (Input.is_action_just_pressed("restart") or controls.consume_press("restart")):
		get_tree().reload_current_scene()


func _spawn_wave() -> void:
	defeated_count = 0
	var positions := [
		Vector2(270, 250),
		Vector2(810, 210),
		Vector2(1320, 250),
		Vector2(320, 650),
		Vector2(1280, 680),
		Vector2(690, 820),
		Vector2(930, 800)
	]
	for i in wave_size:
		var enemy := ArenaEnemy.new().setup(player, positions[i], 1 if i == wave_size - 1 else 0)
		enemy.defeated.connect(_on_enemy_defeated)
		add_child(enemy)
	hud.announce("WAVE READY — DRAW YOUR SWORD", 1.8)


func _on_enemy_defeated(enemy: ArenaEnemy) -> void:
	defeated_count += 1
	if defeated_count % 2 == 0 or player.health <= 3:
		var kind := "heart" if player.health < player.max_health else "arrows"
		add_child(WorldPickup.new().setup(kind, enemy.global_position))
	if defeated_count >= wave_size:
		hud.announce("AREA CLEAR!  New wave incoming…", 2.0)
		await get_tree().create_timer(2.6).timeout
		if not game_over:
			_spawn_wave()


func _on_player_died() -> void:
	game_over = true
	controls.set_dead_mode(true)
	hud.show_death()


func _build_arena_collision() -> void:
	_add_wall(Rect2(0, 0, ARENA_SIZE.x, 42))
	_add_wall(Rect2(0, ARENA_SIZE.y - 42, ARENA_SIZE.x, 42))
	_add_wall(Rect2(0, 0, 42, ARENA_SIZE.y))
	_add_wall(Rect2(ARENA_SIZE.x - 42, 0, 42, ARENA_SIZE.y))
	_add_wall(Rect2(560, 300, 120, 160))
	_add_wall(Rect2(990, 480, 150, 110))
	_add_wall(Rect2(690, 650, 205, 75))


func _add_wall(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collision.shape = shape
	collision.position = rect.position + rect.size * 0.5
	body.add_child(collision)
	add_child(body)


func _draw() -> void:
	# Layered arena floor with a restrained 16-bit-inspired palette.
	draw_rect(Rect2(Vector2.ZERO, ARENA_SIZE), Color("263c35"))
	for y in range(55, 960, 52):
		for x in range(55, 1560, 52):
			var tone := Color("36584a") if (int(x / 52) + int(y / 52)) % 2 == 0 else Color("315044")
			draw_rect(Rect2(x, y, 48, 48), tone)
			if (x * 7 + y * 3) % 11 == 0:
				draw_line(Vector2(x + 12, y + 30), Vector2(x + 17, y + 22), Color("5d8266"), 2)
	# Stone boundary.
	for rect in [
		Rect2(0, 0, 1600, 42),
		Rect2(0, 958, 1600, 42),
		Rect2(0, 0, 42, 1000),
		Rect2(1558, 0, 42, 1000)
	]:
		draw_rect(rect, Color("596268"))
		draw_rect(rect.grow(-7), Color("3d484e"))
	# Ruins/obstacles corresponding exactly to collision shapes.
	_draw_ruin(Rect2(560, 300, 120, 160))
	_draw_ruin(Rect2(990, 480, 150, 110))
	_draw_ruin(Rect2(690, 650, 205, 75))
	# Training crest and lane marks.
	draw_circle(Vector2(800, 500), 105, Color(0.16, 0.28, 0.25, 0.7))
	draw_arc(Vector2(800, 500), 92, 0, TAU, 48, Color("b99645"), 5)
	draw_line(Vector2(752, 500), Vector2(848, 500), Color("b99645"), 4)
	draw_line(Vector2(800, 452), Vector2(800, 548), Color("b99645"), 4)


func _draw_ruin(rect: Rect2) -> void:
	draw_rect(rect, Color("2d3338"))
	draw_rect(rect.grow(-8), Color("687177"))
	for x in range(int(rect.position.x + 12), int(rect.end.x - 8), 31):
		draw_line(Vector2(x, rect.position.y + 8), Vector2(x, rect.end.y - 8), Color("4c565d"), 3)
	for y in range(int(rect.position.y + 18), int(rect.end.y - 8), 30):
		draw_line(Vector2(rect.position.x + 8, y), Vector2(rect.end.x - 8, y), Color("8a9090"), 2)


func _ensure_input_actions() -> void:
	var key_map := {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"attack": [KEY_J, KEY_SPACE],
		"shield": [KEY_K],
		"item_1": [KEY_U],
		"item_2": [KEY_I],
		"swap_items": [KEY_Q, KEY_TAB],
		"restart": [KEY_R, KEY_ENTER]
	}
	for action in key_map:
		if not InputMap.has_action(action):
			InputMap.add_action(action, 0.2)
		InputMap.action_erase_events(action)
		for keycode in key_map[action]:
			var event := InputEventKey.new()
			event.physical_keycode = keycode
			InputMap.action_add_event(action, event)
	var joy_buttons := {
		"attack": JOY_BUTTON_A,
		"shield": JOY_BUTTON_B,
		"item_1": JOY_BUTTON_X,
		"item_2": JOY_BUTTON_Y,
		"swap_items": JOY_BUTTON_LEFT_SHOULDER
	}
	for action in joy_buttons:
		var joy := InputEventJoypadButton.new()
		joy.button_index = joy_buttons[action]
		InputMap.action_add_event(action, joy)
	var axes := {
		"move_left": [JOY_AXIS_LEFT_X, -1.0],
		"move_right": [JOY_AXIS_LEFT_X, 1.0],
		"move_up": [JOY_AXIS_LEFT_Y, -1.0],
		"move_down": [JOY_AXIS_LEFT_Y, 1.0]
	}
	for action in axes:
		var motion := InputEventJoypadMotion.new()
		motion.axis = axes[action][0]
		motion.axis_value = axes[action][1]
		InputMap.action_add_event(action, motion)
