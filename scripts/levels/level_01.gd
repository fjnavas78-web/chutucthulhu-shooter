extends Node2D

@onready var wave_spawner: Node = $WaveSpawner
@onready var hud: CanvasLayer = $HUD
@onready var player: CharacterBody2D = $Player
@onready var boss_container: Node2D = $BossContainer

@export var boss_scene: PackedScene

func _ready() -> void:
	wave_spawner.wave_started.connect(func(n): hud.show_wave(n, wave_spawner.waves))
	wave_spawner.all_waves_completed.connect(_spawn_boss)
	player.life_lost.connect(hud.update_lives)
	player.died.connect(hud.show_game_over)
	GameManager.score_changed.connect(hud.update_score)
	GameManager.score = 0
	hud.update_lives(player.MAX_LIVES)
	hud.update_score(0)
	wave_spawner.start()

func _spawn_boss() -> void:
	if boss_scene == null:
		return
	hud.show_boss_bar()
	var boss := boss_scene.instantiate()
	boss.died.connect(_on_boss_died)
	boss.health_changed.connect(hud.update_boss_health)
	boss_container.add_child(boss)
	boss.global_position = Vector2(get_viewport_rect().size.x / 2.0, 150.0)

func _on_boss_died() -> void:
	GameManager.add_score(5000)
	GameManager.complete_phase(1)
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
