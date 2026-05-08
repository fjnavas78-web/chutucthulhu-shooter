extends CharacterBody2D

signal died(score_value: int)

@export var max_health: int = 30
@export var score_value: int = 100

var health: int
var player: Node2D

func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		died.emit(score_value)
		queue_free()
