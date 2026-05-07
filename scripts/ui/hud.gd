extends CanvasLayer

@onready var lives_label: Label = $LivesLabel
@onready var score_label: Label = $ScoreLabel
@onready var wave_label: Label = $WaveLabel
@onready var boss_bar: ProgressBar = $BossBar
@onready var boss_label: Label = $BossLabel
@onready var game_over_panel: Panel = $GameOverPanel

func _ready() -> void:
	boss_bar.hide()
	boss_label.hide()
	game_over_panel.hide()
	update_lives(3)

func update_lives(lives: int) -> void:
	lives_label.text = "♥".repeat(lives) if lives > 0 else "☠"

func update_score(score: int) -> void:
	score_label.text = "SCORE: %d" % score

func show_wave(current: int, total: int) -> void:
	wave_label.text = "WAVE %d / %d" % [current, total]
	await get_tree().create_timer(2.5).timeout
	wave_label.text = ""

func show_boss_bar() -> void:
	boss_bar.show()
	boss_label.show()
	wave_label.text = "Ph'nglui mglw'nafh Cthulhu R'lyeh wgah'nagl fhtagn!"
	await get_tree().create_timer(3.0).timeout
	wave_label.text = ""

func update_boss_health(current: int, max_val: int) -> void:
	boss_bar.max_value = max_val
	boss_bar.value = current

func show_game_over() -> void:
	game_over_panel.show()

func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
