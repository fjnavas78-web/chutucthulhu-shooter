extends CharacterBody2D

signal died(score_value: int)

@export var max_health: int = 30
@export var speed: float = 80.0
@export var score_value: int = 100
@export var damage: int = 10

var health: int = max_health
var player: Node2D = null

func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if player:
		velocity = (player.global_position - global_position).normalized() * speed
		move_and_slide()

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		died.emit(score_value)
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
