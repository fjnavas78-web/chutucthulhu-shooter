extends Node2D

signal health_changed(ratio: float)
signal arm_destroyed
signal arm_regenerated

const MAX_HEALTH := 300
const REGEN_TIME := 5.0

@export var base_offset: Vector2 = Vector2(-90.0, 0.0)
@export var amp: Vector2 = Vector2(22.0, 38.0)
@export var osc_speed: float = 1.4
@export var phase: float = 0.0
@export var bullet_scene: PackedScene
@export var shoot_interval: float = 3.5

var health := MAX_HEALTH
var active := true
var shoot_timer := 0.0
var player: Node2D

func _ready() -> void:
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")
	shoot_timer = randf_range(1.0, shoot_interval)

func _process(delta: float) -> void:
	if not active:
		return
	var t := Time.get_ticks_msec() * 0.001
	position = base_offset + Vector2(
		sin(t * osc_speed + phase) * amp.x,
		cos(t * osc_speed * 0.75 + phase) * amp.y
	)
	shoot_timer -= delta
	if shoot_timer <= 0.0 and is_instance_valid(player):
		_shoot()
		shoot_timer = shoot_interval + randf_range(-0.6, 0.6)

func _shoot() -> void:
	if bullet_scene == null:
		return
	var bullet := bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = (player.global_position - global_position).normalized()
	get_tree().current_scene.add_child(bullet)

func take_damage(amount: int) -> void:
	if not active:
		return
	health -= amount
	health_changed.emit(float(health) / MAX_HEALTH)
	if health <= 0:
		_destroy()

func get_health_ratio() -> float:
	return float(max(health, 0)) / MAX_HEALTH

func _destroy() -> void:
	active = false
	$Sprite.hide()
	arm_destroyed.emit()
	await get_tree().create_timer(REGEN_TIME).timeout
	if not is_instance_valid(self):
		return
	health = MAX_HEALTH
	active = true
	$Sprite.show()
	health_changed.emit(1.0)
	arm_regenerated.emit()
