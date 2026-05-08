extends "res://scripts/enemies/base_enemy.gd"

func _ready() -> void:
	max_health = 30
	speed = 80.0
	score_value = 100
	contact_cooldown = 1.0
	super()
