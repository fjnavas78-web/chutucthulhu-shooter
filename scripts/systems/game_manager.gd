extends Node

signal phase_completed(phase_id: int)
signal game_over
signal score_changed(new_score: int)

const SAVE_FILE = "user://save.dat"

var score: int = 0
var lives: int = 3
var current_phase: int = 1
var unlocked_phases: Array[int] = [1]
var selected_plane: String = "plane_01"
var ads_removed: bool = false

func _ready() -> void:
	load_game()

func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)

func complete_phase(phase_id: int) -> void:
	if phase_id + 1 not in unlocked_phases:
		unlocked_phases.append(phase_id + 1)
	save_game()
	phase_completed.emit(phase_id)

func lose_life() -> void:
	lives -= 1
	if lives <= 0:
		game_over.emit()

func is_phase_unlocked(phase_id: int) -> bool:
	return phase_id in unlocked_phases

func save_game() -> void:
	var data = {
		"unlocked_phases": unlocked_phases,
		"selected_plane": selected_plane,
		"ads_removed": ads_removed,
	}
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	file.store_var(data)

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_FILE):
		return
	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	var data = file.get_var()
	unlocked_phases = data.get("unlocked_phases", [1])
	selected_plane = data.get("selected_plane", "plane_01")
	ads_removed = data.get("ads_removed", false)
