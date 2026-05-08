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

const SPAWN_TOP := [
	Vector2(50, 30), Vector2(130, 30), Vector2(210, 30),
	Vector2(290, 30), Vector2(370, 30), Vector2(440, 30)
]
const SPAWN_SIDES := [Vector2(20, 160), Vector2(460, 160)]

func _ready() -> void:
	GameManager.score = 0
	player.life_lost.connect(hud.update_lives)
	player.died.connect(hud.show_game_over)
	GameManager.score_changed.connect(hud.update_score)
	hud.update_lives(player.MAX_LIVES)
	hud.update_score(0)
	_run_level()

func _run_level() -> void:
	# Wave 1 — cultistas libres
	await _wave(1, 6, 0, 0)
	await get_tree().create_timer(3.0).timeout

	# Wave 2 — cultistas + 2 bóvedas
	await _wave(2, 6, 2, 0)
	await get_tree().create_timer(3.0).timeout

	# Wave 3 — más densidad: cultistas + 4 bóvedas + 1 edificio
	await _wave(3, 6, 4, 1)
	await get_tree().create_timer(3.0).timeout

	# Wave 4 — SEMILLA DE CTHULHU (especial)
	await _wave_seed()
	await get_tree().create_timer(4.0).timeout

	# Wave 5 — cultistas + 5 bóvedas + 3 edificios
	await _wave(5, 7, 5, 3)
	await get_tree().create_timer(3.0).timeout

	# Wave 6 — formación círculo + 4 bóvedas + 2 edificios
	await _wave_formation()
	await get_tree().create_timer(3.0).timeout

	# Wave 7 — todo a la vez
	await _wave(7, 8, 6, 4)
	await get_tree().create_timer(4.0).timeout

	_spawn_cthulhu()

# Generic wave: cultists + N vaults scattered + M buildings
func _wave(num: int, cultists: int, vaults: int, buildings: int) -> void:
	hud.show_wave(num, 7)
	_alive = 0
	for _i in cultists:
		_spawn_cultist(SPAWN_TOP.pick_random())
		await get_tree().create_timer(0.45).timeout
	for _i in vaults:
		var pos := SPAWN_TOP.pick_random()
		_spawn_vault(pos + Vector2(randf_range(-20, 20), 0))
	for _i in buildings:
		_spawn_building(randf_range(40.0, SCREEN_W - 40.0))
	while _alive > 0:
		await get_tree().create_timer(0.5).timeout

func _wave_seed() -> void:
	hud.show_wave(4, 7)
	hud.show_boss_bar("SEMILLA DE CTHULHU")
	_alive = 0

	# 2 cultistas + 2 bóvedas de escolta
	for _i in 2:
		_spawn_cultist(SPAWN_TOP.pick_random())
		await get_tree().create_timer(0.5).timeout
	_spawn_vault(Vector2(80.0, 40.0))
	_spawn_vault(Vector2(400.0, 40.0))

	# Semilla
	var seed_node := seed_scene.instantiate()
	# base_boss.died emite sin parámetros → lambda
	seed_node.died.connect(func(): _on_enemy_died(500))
	seed_node.health_changed.connect(hud.update_boss_health)
	boss_container.add_child(seed_node)
	seed_node.global_position = Vector2(SCREEN_W / 2.0, 140.0)
	_alive += 1

	while _alive > 0:
		await get_tree().create_timer(0.5).timeout

	hud.hide_boss_bar()

func _wave_formation() -> void:
	hud.show_wave(6, 7)
	_alive = 0

	# Círculo de cultistas
	if cultist_formation_scene != null:
		var f := cultist_formation_scene.instantiate()
		f.cultist_scene = cultist_scene
		f.count = 8
		f.break_y = 260.0
		# Cuando la formación rompe y todos mueren, descuenta los 8 de _alive
		f.all_died.connect(func(): _alive = max(0, _alive - 8))
		add_child(f)
		f.global_position = Vector2(SCREEN_W / 2.0, -60.0)
		_alive += 8
	else:
		for _i in 8:
			_spawn_cultist(SPAWN_TOP.pick_random())
			await get_tree().create_timer(0.3).timeout

	# 4 bóvedas + 2 edificios acompañando
	for pos in [Vector2(60,30), Vector2(180,30), Vector2(300,30), Vector2(420,30)]:
		_spawn_vault(pos)
	_spawn_building(randf_range(60.0, 200.0))
	_spawn_building(randf_range(280.0, 420.0))

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

func _on_enemy_died(score: int) -> void:
	_alive = max(0, _alive - 1)
	GameManager.add_score(score)

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
