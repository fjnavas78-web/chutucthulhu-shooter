extends CharacterBody2D

signal health_changed(current: int, max_val: int)
signal died

@export var speed: float = 300.0
@export var max_health: int = 100
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.2  # seconds between shots

var health: int = max_health
var can_shoot: bool = true
var is_top_down: bool = true  # false = side scroller

func _ready() -> void:
	health = max_health

func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO

	if is_top_down:
		direction.x = Input.get_axis("move_left", "move_right")
		direction.y = Input.get_axis("move_up", "move_down")
	else:
		direction.x = Input.get_axis("move_left", "move_right")
		direction.y = Input.get_axis("move_up", "move_down")

	velocity = direction.normalized() * speed
	move_and_slide()
	_clamp_to_screen()

	if Input.is_action_pressed("shoot") and can_shoot:
		_shoot()

func _clamp_to_screen() -> void:
	var screen := get_viewport_rect().size
	position.x = clamp(position.x, 0, screen.x)
	position.y = clamp(position.y, 0, screen.y)

func _shoot() -> void:
	if bullet_scene == null:
		return
	can_shoot = false
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	get_tree().current_scene.add_child(bullet)
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func take_damage(amount: int) -> void:
	health -= amount
	health_changed.emit(health, max_health)
	if health <= 0:
		died.emit()
		queue_free()
