extends "res://scripts/enemies/base_boss.gd"

@export var enemy_bullet_scene: PackedScene

var shoot_timer: Timer
var move_timer: Timer
var target_position: Vector2

func _ready() -> void:
	max_health = 1000
	health = max_health
	speed = 60.0
	super()
	target_position = global_position

	shoot_timer = Timer.new()
	shoot_timer.timeout.connect(_shoot_pattern)
	add_child(shoot_timer)

	move_timer = Timer.new()
	move_timer.timeout.connect(_pick_new_target)
	add_child(move_timer)

	shoot_timer.start(2.0)
	move_timer.start(3.0)

func _physics_process(delta: float) -> void:
	var dir := target_position - global_position
	if dir.length() > 10.0:
		velocity = dir.normalized() * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()

func _pick_new_target() -> void:
	var screen := get_viewport_rect().size
	target_position = Vector2(
		randf_range(80.0, screen.x - 80.0),
		randf_range(80.0, screen.y * 0.35)
	)

func _shoot_pattern() -> void:
	match boss_phase:
		1: _spread_shot(6)
		2: _spread_shot(10)
		3:
			_spread_shot(16)
			shoot_timer.wait_time = 1.0

func _spread_shot(count: int) -> void:
	if enemy_bullet_scene == null:
		return
	var angle_step := TAU / count
	for i in count:
		var bullet := enemy_bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.direction = Vector2.RIGHT.rotated(angle_step * i)
		get_tree().current_scene.add_child(bullet)
