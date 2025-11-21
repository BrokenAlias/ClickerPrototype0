extends Panel


@onready var main: Node = $"../../.."

@onready var center: Node2D = $Center
@onready var progress_bar: ProgressBar = $ProgressBar

var is_held_down: bool = false
var last_frame_rotation: float = 0.0
var progress: float = 0.0


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if visible:
		progress_bar.value = progress
		
		if is_held_down:
			center.look_at(get_global_mouse_position())
			
			var frame_angle_diff: float = center.rotation - last_frame_rotation
			
			progress += frame_angle_diff * 0.01
			
			last_frame_rotation = center.rotation
		
		if progress > 1.0: # Completed
			main.fix_minigame(self.name)
	else:
		center.rotation = 0.0
		is_held_down = false
		last_frame_rotation = 0.0
		progress = 0.0


func _on_texture_button_button_down() -> void:
	is_held_down = true


func _on_texture_button_button_up() -> void:
	is_held_down = false
