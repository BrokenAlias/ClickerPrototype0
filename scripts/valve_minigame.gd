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
		if is_held_down:
			center.look_at(get_global_mouse_position())
			
			var frame_angle_diff: float = center.rotation - last_frame_rotation
			
			progress += frame_angle_diff * 0.01
			
			last_frame_rotation = center.rotation
			
			progress_bar.value = progress
		
		if progress > 1.0: # Completed
			main.fix_minigame_buttons.get("Valve").hide() # Hide fix button
			hide() # Hide UI


func _on_texture_button_button_down() -> void:
	is_held_down = true


func _on_texture_button_button_up() -> void:
	is_held_down = false
