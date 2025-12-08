extends Panel

@onready var main: Main = owner
@onready var bar: ProgressBar = $Control/PipePressure
@onready var pipe_area: ColorRect = $Control/PipeArea

@export var leak_scene: PackedScene
@export var spawn_interval = 1

var spawn_timer = 0.0
var can_spawn = true
var existing_leaks: Array = []

signal leak_fixed

func _ready():
	bar.value = 0
	connect("leak_fixed", Callable(self, "_on_leak_fixed"))


func _process(delta: float) -> void:
	can_spawn = main.is_broken("Pipes")
	
	spawn_timer += delta
	if spawn_timer >= 1 and can_spawn == true and existing_leaks.size() <= 10:
		spawn_timer = 0
		spawn_leak()


func spawn_leak():
	var leak = leak_scene.instantiate()
	add_child(leak)
	existing_leaks.append(leak)
	
	var rect_pos = pipe_area.global_position
	var rect_size = pipe_area.size
	
	leak.global_position = Vector2(
		randf_range(rect_pos.x, rect_pos.x + rect_size.x),
		randf_range(rect_pos.y, rect_pos.y + rect_size.y)
		)

func _on_leak_fixed():
	bar.value += 10
	if bar.value >= 100:
		bar.value = 0
		
		for leak in existing_leaks:
			if is_instance_valid(leak):
				leak.queue_free()
				
		existing_leaks.clear()
		main.fix_minigame(self.name)
