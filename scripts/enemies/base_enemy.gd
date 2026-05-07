extends CharacterBody2D

signal died(score_value: int)

@export var max_health: int = 30
@export var speed: float = 80.0
@export var score_value: int = 100
@export var contact_cooldown: float = 1.0

var health: int = max_health
var player: Node2D = null
var _contact_timer: float = 0.0

func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	_contact_timer -= delta
	if player:
		velocity = (player.global_position - global_position).normalized() * speed
		move_and_slide()
		if _contact_timer <= 0.0:
			for i in get_slide_collision_count():
				var col = get_slide_collision(i)
				var body = col.get_collider()
				if body and body.is_in_group("player") and body.has_method("take_hit"):
					body.take_hit()
					_contact_timer = contact_cooldown
					break

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		died.emit(score_value)
		queue_free()
