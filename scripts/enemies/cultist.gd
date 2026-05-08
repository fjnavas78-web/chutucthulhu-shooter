extends CharacterBody2D

signal died(score_value: int)

enum State { ENTERING, FORMATION, DIVING, IN_FORMATION }

const SCORE_VALUE := 100

@export var bullet_scene: PackedScene
@export var shoot_interval: float = 2.2
@export var dive_speed: float = 260.0

var player: Node2D
var state := State.ENTERING
var formation_pos := Vector2.ZERO
var shoot_timer := 0.0
var _dead := false

# Bezier entry
var _entry_a := Vector2.ZERO
var _entry_ctrl := Vector2.ZERO

# Formation mode
var _formation_center: Node2D = null
var _formation_offset := Vector2.ZERO

func _ready() -> void:
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")

func _start_free_entry() -> void:
	var screen := get_viewport_rect().size
	formation_pos = Vector2(
		randf_range(50.0, screen.x - 50.0),
		randf_range(60.0, screen.y * 0.26)
	)
	_entry_a = global_position
	var mid := (_entry_a + formation_pos) * 0.5
	_entry_ctrl = mid + Vector2(randf_range(-130.0, 130.0), randf_range(-90.0, -20.0))
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_method(_bezier_move, 0.0, 1.0, 1.2)
	tween.tween_callback(func():
		state = State.FORMATION
		shoot_timer = randf_range(0.4, shoot_interval)
	)

# Called by CultistFormation
func set_formation(center: Node2D, offset: Vector2) -> void:
	_formation_center = center
	_formation_offset = offset
	state = State.IN_FORMATION
	shoot_timer = randf_range(shoot_interval * 0.5, shoot_interval)

# Called by CultistFormation when it breaks
func leave_formation() -> void:
	_formation_center = null
	state = State.ENTERING
	_entry_a = global_position
	var screen := get_viewport_rect().size
	formation_pos = Vector2(randf_range(50.0, screen.x - 50.0), randf_range(60.0, screen.y * 0.26))
	var mid := (_entry_a + formation_pos) * 0.5
	_entry_ctrl = mid + Vector2(randf_range(-100.0, 100.0), randf_range(-80.0, -10.0))
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_method(_bezier_move, 0.0, 1.0, 0.9)
	tween.tween_callback(func():
		state = State.FORMATION
		shoot_timer = randf_range(0.4, shoot_interval)
	)

func _bezier_move(t: float) -> void:
	global_position = (1.0 - t) * (1.0 - t) * _entry_a \
		+ 2.0 * (1.0 - t) * t * _entry_ctrl \
		+ t * t * formation_pos

func _physics_process(delta: float) -> void:
	if _dead:
		return
	match state:
		State.ENTERING:
			pass  # tween handles position

		State.IN_FORMATION:
			if is_instance_valid(_formation_center):
				global_position = _formation_center.global_position + _formation_offset
			if player and global_position.distance_to(player.global_position) < 28.0:
				_hit_player(); return
			shoot_timer -= delta
			if shoot_timer <= 0.0:
				_shoot()
				shoot_timer = shoot_interval + randf_range(-0.3, 0.3)

		State.FORMATION:
			global_position.y = formation_pos.y + sin(Time.get_ticks_msec() * 0.0015) * 5.0
			if player and global_position.distance_to(player.global_position) < 28.0:
				_hit_player(); return
			shoot_timer -= delta
			if shoot_timer <= 0.0:
				_shoot()
				shoot_timer = shoot_interval + randf_range(-0.3, 0.3)
				if randf() < 0.28:
					state = State.DIVING

		State.DIVING:
			if player:
				velocity = (player.global_position - global_position).normalized() * dive_speed
			else:
				velocity = Vector2(0.0, dive_speed)
			move_and_slide()
			for i in get_slide_collision_count():
				var body := get_slide_collision(i).get_collider()
				if body and body.is_in_group("player") and body.has_method("take_hit"):
					_hit_player(); return
			if not get_viewport_rect().grow(70.0).has_point(global_position):
				_die()

func _shoot() -> void:
	if bullet_scene == null or player == null:
		return
	var bullet := bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = (player.global_position - global_position).normalized()
	get_tree().current_scene.add_child(bullet)

func _hit_player() -> void:
	if player and player.has_method("take_hit"):
		player.take_hit()
	_die()

func take_damage(_amount: int) -> void:
	if not _dead:
		_die()

func _die() -> void:
	if _dead:
		return
	_dead = true
	died.emit(SCORE_VALUE)
	queue_free()
