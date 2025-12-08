extends Panel


@onready var main: Node = $"../../.."

@onready var center: Node2D = $Center
@onready var progress_bar: ProgressBar = $ProgressBar

var is_held_down: bool = false
var last_frame_rotation: float = 0.0
var angular_velocity: float = 0.0
var progress: float = 0.0

#should tune
@export var velocity_multiplier := 15.0     # How strong the “throw” is when letting go
@export var spin_damping := 20.0             # How fast the spin slows down
@export var max_angular_velocity := 25.0    # radians per second

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if visible:
		progress_bar.value = progress
		
		if is_held_down:
			center.look_at(get_global_mouse_position())
			
			var angle_diff: float = center.rotation - last_frame_rotation
			
			# Normalize to prevent jumps past PI / -PI
			angle_diff = wrapf(angle_diff, -PI, PI)
			
			angular_velocity = angle_diff / delta  # store current velocity
			
			# Clamp speed
			angular_velocity = clamp(angular_velocity, -max_angular_velocity, max_angular_velocity)
			
			progress += angle_diff * 0.01
			last_frame_rotation = center.rotation
			
		else:
			# Apply inertial rotation when not holding
			if abs(angular_velocity) > 0.001:
				center.rotation += angular_velocity * delta
				
				# Add progress from spinning
				progress += angular_velocity * delta * 0.01
				# Apply damping
				angular_velocity = move_toward(angular_velocity, 0.0, spin_damping * delta)
			else:
				angular_velocity = 0.0
		
		if progress > 1.0: # Completed
			main.fix_minigame(self.name)
	else:
		center.rotation = 0.0
		is_held_down = false
		last_frame_rotation = 0.0
		angular_velocity = 0.0   # <- stops spinning when minigame closes
		progress = 0.0

func _input(event):
	if not visible:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_held_down = true
				angular_velocity = 0.0   # reset velocity on grab
				last_frame_rotation = center.rotation
			else:
				is_held_down = false
				# When letting go, the stored angular_velocity continues spinning
