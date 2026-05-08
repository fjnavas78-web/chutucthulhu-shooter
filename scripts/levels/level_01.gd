extends Node2D

@onready var hud: CanvasLayer = $HUD
@onready var player: CharacterBody2D = $Player
@onready var boss_container: Node2D = $BossContainer

@export var cultist_scene: PackedScene
@export var cultist_formation_scene: PackedScene
@export var vault_scene: PackedScene
@export var building_scene: PackedScene
@export var seed_scene: PackedScene
@export var cthulhu_scene: PackedScene

var _alive: int = 0
const SCREEN_W := 480.0
const SCREEN_H := 854.0

const SPAWN_POINTS := [
	Vector2(60, 30), Vector2(160, 30), Vector2(240, 30),
	Vector2(320, 30), Vector2(420, 30),
	Vector2(20, 180), Vector2(460, 180)
]

func _ready() -> void:
	GameManager.score = 0
	player.life_lost.connect(hud.update_lives)
	player.died.connect(hud.show_game_over)
	GameManager.score_changed.connect(hud.update_score)
	hud.update_lives(player.MAX_LIVES)
	hud.update_score(0)
	_run_level()

func _run_level() -> void:
	await _wave(1, 6, [], [])
	await get_tree().create_timer(3.0).timeout
	await _wave(2, 6, [0, 1], [])
	await get_tree().create_timer(3.0).timeout
	await _wave_3_seed()
	await get_tree().create_timer(4.0).timeout
	await _wave(4, 7, [0, 2], [1])
	await get_tree().create_timer(3.0).timeout
	await _wave(5, 8, [0, 1, 2], [0, 2])
	await get_tree().create_timer(3.0).timeout
	await _wave_formation(6)
	await get_tree().create_timer(3.0).timeout
	await _wave(7, 10, [0, 1, 2, 3], [0, 1, 2])
	await get_tree().create_timer(4.0).timeout
	_spawn_cthulhu()

# wave: N free cultists + vault_idxs (spawn point indices) + building_idxs
func _wave(num: int, cultists: int, vault_idxs: Array, building_idxs: Array) -> void:
	hud.show_wave(num, 7)
	_alive = 0
	for i in cultists:
		_spawn_cultist(SPAWN_POINTS.pick_random())
		await get_tree().create_timer(0.5).timeout
	for idx in vault_idxs:
		_spawn_vault(SPAWN_POINTS[idx % SPAWN_POINTS.size()])
	for idx in building_idxs:
		_spawn_building(randf_range(40.0, SCREEN_W - 40.0))
	while _alive > 0:
		await get_tree().create_timer(0.5).timeout

func _wave_3_seed() -> void:
	hud.show_wave(3, 7)
	hud.show_boss_bar("SEMILLA DE CTHULHU")
	_alive = 0
	# 3 cultists first
	for i in 3:
		_spawn_cultist(SPAWN_POINTS.pick_random())
		await get_tree().create_timer(0.6).timeout
	# Then seed
	var seed := seed_scene.instantiate()
	seed.died.connect(_on_enemy_died)
	seed.health_changed.connect(hud.update_boss_health)
	boss_container.add_child(seed)
	seed.global_position = Vector2(SCREEN_W / 2.0, 140.0)
	_alive += 1
	while _alive > 0:
		await get_tree().create_timer(0.5).timeout
	boss_container.visible = true  # reset
	# hide boss bar
	hud.boss_bar.hide()
	hud.boss_label.hide()

func _wave_formation(num: int) -> void:
	hud.show_wave(num, 7)
	_alive = 0
	if cultist_formation_scene == null:
		await _wave(num, 8, [0, 2], [1])
		return
	var formation := cultist_formation_scene.instantiate()
	formation.cultist_scene = cultist_scene
	formation.count = 8
	formation.break_y = 280.0
	formation.all_died.connect(func(): _alive -= 8)
	add_child(formation)
	formation.global_position = Vector2(SCREEN_W / 2.0, -60.0)
	_alive += 8
	# also 2 vaults
	_spawn_vault(SPAWN_POINTS[0])
	_spawn_vault(SPAWN_POINTS[4])
	while _alive > 0:
		await get_tree().create_timer(0.5).timeout

func _spawn_cultist(pos: Vector2) -> void:
	if cultist_scene == null:
		return
	var c := cultist_scene.instantiate()
	c.died.connect(_on_enemy_died)
	add_child(c)
	c.global_position = pos
	c._start_free_entry()
	_alive += 1

func _spawn_vault(pos: Vector2) -> void:
	if vault_scene == null:
		return
	var v := vault_scene.instantiate()
	v.died.connect(_on_enemy_died)
	add_child(v)
	v.global_position = pos
	_alive += 1

func _spawn_building(x: float) -> void:
	if building_scene == null:
		return
	var b := building_scene.instantiate()
	b.died.connect(_on_enemy_died)
	add_child(b)
	b.global_position = Vector2(x, SCREEN_H + 80.0)
	_alive += 1

func _on_enemy_died(_score: int) -> void:
	_alive = max(0, _alive - 1)
	GameManager.add_score(_score)

func _spawn_cthulhu() -> void:
	if cthulhu_scene == null:
		return
	hud.show_boss_bar("CTHULHU")
	var boss := cthulhu_scene.instantiate()
	boss.died.connect(_on_boss_died)
	boss.health_changed.connect(hud.update_boss_health)
	boss.left_arm_health.connect(hud.update_left_arm)
	boss.right_arm_health.connect(hud.update_right_arm)
	boss.left_arm_status.connect(func(a): hud.set_arm_status("left", a))
	boss.right_arm_status.connect(func(a): hud.set_arm_status("right", a))
	boss_container.add_child(boss)
	boss.global_position = Vector2(SCREEN_W / 2.0, 150.0)
	hud.register_boss_arms(boss.get_left_arm(), boss.get_right_arm())

func _on_boss_died() -> void:
	GameManager.add_score(5000)
	GameManager.complete_phase(1)
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
