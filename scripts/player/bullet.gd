extends Area2D

@export var speed: float = 600.0
@export var damage: int = 10
@export var direction: Vector2 = Vector2.UP
@export var hit_radius: float = 22.0

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	if not get_viewport_rect().has_point(global_position):
		queue_free()
		return
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy) and \
				global_position.distance_to(enemy.global_position) < hit_radius:
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage)
			queue_free()
			return
