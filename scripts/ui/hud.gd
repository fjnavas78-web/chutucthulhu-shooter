extends CanvasLayer

@onready var lives_label: Label = $LivesLabel
@onready var score_label: Label = $ScoreLabel
@onready var wave_label: Label = $WaveLabel
@onready var boss_bar: ProgressBar = $BossBar
@onready var boss_label: Label = $BossLabel
@onready var left_arm_bar: ProgressBar = $LeftArmBar
@onready var right_arm_bar: ProgressBar = $RightArmBar
@onready var left_arm_label: Label = $LeftArmLabel
@onready var right_arm_label: Label = $RightArmLabel
@onready var game_over_panel: Panel = $GameOverPanel

var _left_arm_ref: Node2D = null
var _right_arm_ref: Node2D = null

func _ready() -> void:
	boss_bar.hide()
	boss_label.hide()
	left_arm_bar.hide()
	right_arm_bar.hide()
	left_arm_label.hide()
	right_arm_label.hide()
	game_over_panel.hide()
	update_lives(3)

func _process(_delta: float) -> void:
	if is_instance_valid(_left_arm_ref):
		var p := _left_arm_ref.global_position
		left_arm_bar.position = Vector2(p.x - 45.0, p.y - 60.0)
		left_arm_label.position = Vector2(p.x - 45.0, p.y - 78.0)
	if is_instance_valid(_right_arm_ref):
		var p := _right_arm_ref.global_position
		right_arm_bar.position = Vector2(p.x - 45.0, p.y - 60.0)
		right_arm_label.position = Vector2(p.x - 45.0, p.y - 78.0)

func register_boss_arms(left: Node2D, right: Node2D) -> void:
	_left_arm_ref = left
	_right_arm_ref = right
	left_arm_bar.show()
	right_arm_bar.show()
	left_arm_label.show()
	right_arm_label.show()

func update_lives(lives: int) -> void:
	lives_label.text = "♥".repeat(lives) if lives > 0 else "☠"

func update_score(score: int) -> void:
	score_label.text = "SCORE: %d" % score

func show_wave(wave: int, total: int) -> void:
	wave_label.text = "WAVE %d / %d" % [wave, total]
	await get_tree().create_timer(2.5).timeout
	if is_instance_valid(self):
		wave_label.text = ""

func show_boss_bar(label_text: String = "CTHULHU") -> void:
	boss_bar.show()
	boss_label.text = label_text
	boss_label.show()
	wave_label.text = "Ph'nglui mglw'nafh Cthulhu R'lyeh wgah'nagl fhtagn!"
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(self):
		wave_label.text = ""

func update_boss_health(current: int, max_val: int) -> void:
	boss_bar.max_value = max_val
	boss_bar.value = current

func update_left_arm(ratio: float) -> void:
	left_arm_bar.value = ratio * 100.0

func update_right_arm(ratio: float) -> void:
	right_arm_bar.value = ratio * 100.0

func set_arm_status(side: String, active: bool) -> void:
	var bar := left_arm_bar if side == "left" else right_arm_bar
	var lbl := left_arm_label if side == "left" else right_arm_label
	bar.modulate = Color.WHITE if active else Color(0.4, 0.4, 0.4)
	lbl.text = ("BRAZO IZQ" if side == "left" else "BRAZO DER") if active else "REGENER..."

func hide_boss_bar() -> void:
	boss_bar.hide()
	boss_label.hide()

func show_game_over() -> void:
	game_over_panel.show()

func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
