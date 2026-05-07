extends CharacterBody2D

signal life_lost(lives_remaining: int)
signal died

@export var speed: float = 300.0
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.2

const MAX_LIVES := 3
const INVINCIBILITY_TIME := 2.0

var lives: int = MAX_LIVES
var can_shoot: bool = true
var invincible: bool = false
var is_top_down: bool = true

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	var direction := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	velocity = direction.normalized() * speed
	move_and_slide()
	_clamp_to_screen()

	if Input.is_action_pressed("shoot") and can_shoot:
		_shoot()

func _clamp_to_screen() -> void:
	var screen := get_viewport_rect().size
	position.x = clamp(position.x, 0.0, screen.x)
	position.y = clamp(position.y, 0.0, screen.y)

func _shoot() -> void:
	if bullet_scene == null:
		return
	can_shoot = false
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	get_tree().current_scene.add_child(bullet)
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func take_hit() -> void:
	if invincible:
		return
	lives -= 1
	life_lost.emit(lives)
	if lives <= 0:
		died.emit()
		queue_free()
		return
	_start_invincibility()

func _start_invincibility() -> void:
	invincible = true
	var tween := create_tween().set_loops(int(INVINCIBILITY_TIME / 0.2))
	tween.tween_property(self, "modulate:a", 0.2, 0.1)
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	await get_tree().create_timer(INVINCIBILITY_TIME).timeout
	modulate.a = 1.0
	invincible = false
