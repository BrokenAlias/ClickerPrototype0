extends Control

@onready var main: Node = $"../../.."
@onready var pipes: Panel = $".."
@onready var pipe_area: ColorRect = $PipeArea
@onready var bar = $PipePressure

@export var leak_scene: PackedScene
@export var spawn_interval = 1

var spawn_timer = 0.0

signal leak_fixed

func _ready():
	bar.value = 0
	connect("leak_fixed", Callable(self, "_on_leak_fixed"))

	
func _process(delta: float) -> void:
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0
		spawn_leak()
		

func spawn_leak():
	var leak = leak_scene.instantiate()
	add_child(leak)
	
	
	# random posiston inside PipeArea
	var rect_size = pipe_area.size

	leak.position = Vector2(
		randf_range(0, rect_size.x),
		randf_range(0, rect_size.y)
	)

func _on_leak_fixed():
	bar.value += 10
	if bar.value >= 100:
		pipes.hide()
