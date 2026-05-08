extends CharacterBody2D

signal died(score_value: int)

const SCORE_VALUE := 200
const RISE_SPEED := 90.0
const WARNING_TIME := 1.5

var _rising := false
var _warning_sprite: Node2D

func _ready() -> void:
	add_to_group("enemies")
	var screen := get_viewport_rect().size
	global_position.y = screen.y + 80.0
	_spawn_warning()

func _spawn_warning() -> void:
	_warning_sprite = Node2D.new()
	get_tree().current_scene.add_child(_warning_sprite)
	_warning_sprite.global_position = Vector2(global_position.x, get_viewport_rect().size.y - 30.0)
	_flash_warning()

func _flash_warning() -> void:
	for _i in 6:
		if not is_instance_valid(_warning_sprite):
			return
		_warning_sprite.modulate.a = 0.0
		await get_tree().create_timer(WARNING_TIME / 12.0).timeout
		if not is_instance_valid(_warning_sprite):
			return
		_warning_sprite.modulate.a = 1.0
		await get_tree().create_timer(WARNING_TIME / 12.0).timeout
	if is_instance_valid(_warning_sprite):
		_warning_sprite.queue_free()
	_rising = true

func _physics_process(delta: float) -> void:
	if not _rising:
		return
	velocity = Vector2(0.0, -RISE_SPEED)
	move_and_slide()

	for i in get_slide_collision_count():
		var body := get_slide_collision(i).get_collider()
		if body and body.is_in_group("player") and body.has_method("take_hit"):
			body.take_hit()
			died.emit(SCORE_VALUE)
			queue_free()
			return

	if global_position.y < -100.0:
		died.emit(0)
		queue_free()
