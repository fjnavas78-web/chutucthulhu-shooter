extends Node2D

@export var cultist_scene: PackedScene
@export var count: int = 8
@export var radius: float = 80.0
@export var descend_speed: float = 45.0
@export var break_y: float = 280.0

signal all_died

var _cultists: Array = []
var _alive: int = 0
var _broken := false

func _ready() -> void:
	for i in count:
		var angle := (TAU / count) * i
		var offset := Vector2(cos(angle), sin(angle)) * radius
		var c := cultist_scene.instantiate()
		get_parent().add_child(c)
		c.global_position = global_position + offset
		c.set_formation(self, offset)
		c.died.connect(_on_cultist_died)
		_cultists.append(c)
	_alive = count

func _physics_process(delta: float) -> void:
	if _broken:
		return
	position.y += descend_speed * delta
	if position.y >= break_y:
		_break()

func _break() -> void:
	_broken = true
	for c in _cultists:
		if is_instance_valid(c):
			c.leave_formation()
	queue_free()

func _on_cultist_died(_score: int) -> void:
	_alive -= 1
	if _alive <= 0:
		all_died.emit()
