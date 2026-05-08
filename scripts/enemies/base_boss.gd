extends CharacterBody2D

signal died
signal health_changed(current: int, max_val: int)
signal phase_changed(phase: int)

@export var max_health: int = 1000
@export var score_value: int = 5000
@export var speed: float = 60.0

var health: int = max_health
var boss_phase: int = 1
var player: Node2D = null

func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")
	_start_phase(1)

func _start_phase(phase: int) -> void:
	boss_phase = phase
	phase_changed.emit(boss_phase)

func take_damage(amount: int) -> void:
	health -= amount
	health_changed.emit(health, max_health)
	_check_phase_transition()
	if health <= 0:
		_on_death()

func _check_phase_transition() -> void:
	var pct := float(health) / float(max_health)
	if boss_phase == 1 and pct <= 0.5:
		_start_phase(2)
	elif boss_phase == 2 and pct <= 0.2:
		_start_phase(3)

func _on_death() -> void:
	died.emit()
	queue_free()
