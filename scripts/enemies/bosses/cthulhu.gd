extends "res://scripts/enemies/base_boss.gd"

signal left_arm_health(ratio: float)
signal right_arm_health(ratio: float)
signal left_arm_status(active: bool)
signal right_arm_status(active: bool)

@export var enemy_bullet_scene: PackedScene

@onready var left_arm: Node2D = $LeftArm
@onready var right_arm: Node2D = $RightArm

var shoot_timer: Timer
var move_timer: Timer
var target_position: Vector2
var _contact_cd: float = 0.0

func _ready() -> void:
	max_health = 1000
	health = max_health
	speed = 55.0
	super()
	target_position = global_position

	left_arm.bullet_scene = enemy_bullet_scene
	right_arm.bullet_scene = enemy_bullet_scene

	left_arm.health_changed.connect(func(r): left_arm_health.emit(r))
	left_arm.arm_destroyed.connect(func(): left_arm_status.emit(false))
	left_arm.arm_regenerated.connect(func(): left_arm_status.emit(true); left_arm_health.emit(1.0))

	right_arm.health_changed.connect(func(r): right_arm_health.emit(r))
	right_arm.arm_destroyed.connect(func(): right_arm_status.emit(false))
	right_arm.arm_regenerated.connect(func(): right_arm_status.emit(true); right_arm_health.emit(1.0))

	shoot_timer = Timer.new()
	shoot_timer.timeout.connect(_shoot_body)
	add_child(shoot_timer)

	move_timer = Timer.new()
	move_timer.timeout.connect(_pick_target)
	add_child(move_timer)

	shoot_timer.start(2.5)
	move_timer.start(3.0)

func get_left_arm() -> Node2D:
	return left_arm

func get_right_arm() -> Node2D:
	return right_arm

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
	target_position = Vector2(randf_range(80.0, s.x - 80.0), randf_range(80.0, s.y * 0.38))

func _shoot_body() -> void:
	var count: int = ([6, 10, 16] as Array[int])[boss_phase - 1]
	if boss_phase == 3:
		shoot_timer.wait_time = 1.0
	_spread_shot(count)

func _spread_shot(count: int) -> void:
	if enemy_bullet_scene == null:
		return
	var step := TAU / count
	for i in count:
		var b := enemy_bullet_scene.instantiate()
		b.global_position = global_position
		b.direction = Vector2.RIGHT.rotated(step * i)
		get_tree().current_scene.add_child(b)
