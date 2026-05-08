extends "res://scripts/enemies/base_boss.gd"

@export var enemy_bullet_scene: PackedScene

var shoot_timer: Timer
var move_timer: Timer
var target_position: Vector2
var _contact_cd: float = 0.0

func _ready() -> void:
	max_health = 400
	health = max_health
	speed = 85.0
	super()
	target_position = global_position

	shoot_timer = Timer.new()
	shoot_timer.timeout.connect(_shoot_pattern)
	add_child(shoot_timer)

	move_timer = Timer.new()
	move_timer.timeout.connect(_pick_target)
	add_child(move_timer)

	shoot_timer.start(1.8)
	move_timer.start(2.0)

func _physics_process(delta: float) -> void:
	_contact_cd -= delta
	var dir := target_position - global_position
	velocity = dir.normalized() * speed if dir.length() > 10.0 else Vector2.ZERO
	move_and_slide()
	if _contact_cd <= 0.0:
		for i in get_slide_collision_count():
			var body := get_slide_collision(i).get_collider()
			if body and body.is_in_group("player") and body.has_method("take_hit"):
				body.take_hit()
				_contact_cd = 1.5
				break

func _pick_target() -> void:
	var s := get_viewport_rect().size
	target_position = Vector2(randf_range(60.0, s.x - 60.0), randf_range(60.0, s.y * 0.4))

func _shoot_pattern() -> void:
	if enemy_bullet_scene == null:
		return
	var count := [5, 8, 12][boss_phase - 1]
	var step := TAU / count
	for i in count:
		var b := enemy_bullet_scene.instantiate()
		b.global_position = global_position
		b.direction = Vector2.RIGHT.rotated(step * i)
		get_tree().current_scene.add_child(b)
