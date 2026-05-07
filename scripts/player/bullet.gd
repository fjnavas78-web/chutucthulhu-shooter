extends Area2D

@export var speed: float = 600.0
@export var damage: int = 10
@export var direction: Vector2 = Vector2.UP

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	if not get_viewport_rect().has_point(global_position):
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
