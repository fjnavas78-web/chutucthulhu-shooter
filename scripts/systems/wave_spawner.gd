extends Node

signal wave_started(wave_num: int)
signal all_waves_completed

@export var enemy_scene: PackedScene
@export var waves: int = 5
@export var enemies_per_wave: int = 8
@export var wave_interval: float = 3.0
@export var spawn_interval: float = 0.4

var current_wave: int = 0
var enemies_alive: int = 0
var spawn_points: Array[Marker2D] = []

func _ready() -> void:
	for child in get_children():
		if child is Marker2D:
			spawn_points.append(child)

func start() -> void:
	_next_wave()

func _next_wave() -> void:
	current_wave += 1
	if current_wave > waves:
		all_waves_completed.emit()
		return
	wave_started.emit(current_wave)
	_spawn_wave()

func _spawn_wave() -> void:
	_spawn_sequence()

func _spawn_sequence() -> void:
	var spawned := 0
	var timer := get_tree().create_timer(0.0)
	for i in enemies_per_wave:
		await get_tree().create_timer(spawn_interval * i).timeout
		_spawn_enemy()
	await _wait_for_wave_clear()
	await get_tree().create_timer(wave_interval).timeout
	_next_wave()

func _wait_for_wave_clear() -> void:
	while enemies_alive > 0:
		await get_tree().create_timer(0.5).timeout

func _spawn_enemy() -> void:
	if enemy_scene == null or spawn_points.is_empty():
		return
	var point: Marker2D = spawn_points.pick_random()
	var enemy := enemy_scene.instantiate()
	enemy.died.connect(_on_enemy_died)
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = point.global_position
	enemies_alive += 1

func _on_enemy_died(score_value: int) -> void:
	enemies_alive -= 1
	GameManager.add_score(score_value)
