extends Area2D

@export var speed: float = 200.0
@export var direction: Vector2 = Vector2.DOWN

var _player: Node2D

func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

	if not get_viewport_rect().has_point(global_position):
		queue_free()
		return

	if _player and global_position.distance_to(_player.global_position) < 22.0:
		_player.take_hit()
		queue_free()
