extends Node

signal wave_started(wave_num: int)
signal all_waves_completed

@export var enemy_scene: PackedScene
@export var waves: int = 5
@export var enemies_per_wave: int = 8
@export var wave_interval: float = 3.0
@export var spawn_interval: float = 0.5

var current_wave: int = 0
var enemies_alive: int = 0

func start() -> void:
	_run_waves()

func _run_waves() -> void:
	for w in waves:
		current_wave = w + 1
		wave_started.emit(current_wave)
		await _run_single_wave()
		await get_tree().create_timer(wave_interval).timeout
	all_waves_completed.emit()

func _run_single_wave() -> void:
	enemies_alive = 0
	for _i in enemies_per_wave:
		await get_tree().create_timer(spawn_interval).timeout
		_spawn_enemy()
	while enemies_alive > 0:
		await get_tree().create_timer(0.5).timeout

func _spawn_enemy() -> void:
	if enemy_scene == null:
		push_error("WaveSpawner: enemy_scene no asignada")
		return
	var points: Array = []
	for child in get_children():
		if child is Marker2D:
			points.append(child)
	if points.is_empty():
		push_error("WaveSpawner: sin spawn points")
		return
	var point: Marker2D = points.pick_random()
	var enemy := enemy_scene.instantiate()
	enemy.died.connect(_on_enemy_died)
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = point.global_position
	enemies_alive += 1

func _on_enemy_died(score_value: int) -> void:
	enemies_alive = max(0, enemies_alive - 1)
	GameManager.add_score(score_value)
