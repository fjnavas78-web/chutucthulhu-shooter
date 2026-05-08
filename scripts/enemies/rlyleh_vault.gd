extends CharacterBody2D

signal died(score_value: int)

const SCORE_VALUE := 150
const MAX_HEALTH := 2
const DESCEND_SPEED := 35.0

@export var bullet_scene: PackedScene
@export var shoot_interval: float = 2.8

var health := MAX_HEALTH
var shoot_timer := 0.0
var player: Node2D
var _hit_flash := 0.0

func _ready() -> void:
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")
	shoot_timer = randf_range(0.8, shoot_interval)

func _physics_process(delta: float) -> void:
	velocity = Vector2(0.0, DESCEND_SPEED)
	move_and_slide()

	if global_position.y > get_viewport_rect().size.y + 60.0:
		queue_free()
		return

	shoot_timer -= delta
	if shoot_timer <= 0.0:
		_shoot()
		shoot_timer = shoot_interval + randf_range(-0.4, 0.4)

	if _hit_flash > 0.0:
		_hit_flash -= delta
		modulate = Color(2.0, 2.0, 2.0) if fmod(_hit_flash * 10, 1.0) > 0.5 else Color.WHITE
	else:
		modulate = Color.WHITE

func _shoot() -> void:
	if bullet_scene == null or player == null:
		return
	var bullet := bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = (player.global_position - global_position).normalized()
	get_tree().current_scene.add_child(bullet)

func take_damage(amount: int) -> void:
	health -= amount
	_hit_flash = 0.3
	if health <= 0:
		died.emit(SCORE_VALUE)
		queue_free()
