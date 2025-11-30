extends Node2D

@export var max_size: float = 150.0
@export var min_size: float = 10.0
@export var shrink_amount: float = 25.0
@export var regrow_speed: float = 25.0

var current_size: float
var hits: int = 0

@onready var rect = $SpriteRect

func _ready() -> void:
	current_size = max_size
	# size is a Vector2
	rect.size = Vector2(current_size, current_size)
	# ensure the ColorRect accepts mouse input (you can also set this in the editor)
	rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
func _process(delta: float) -> void:
	# Slowly regrow if smaller
	if current_size < max_size:
		current_size += regrow_speed * delta
		current_size = min(current_size, max_size)
		rect.size = Vector2(current_size, current_size)
		
func _on_sprite_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		shrink()
		
func shrink():
	hits += 1 
	current_size = max(min_size, current_size - shrink_amount)
	rect.size = Vector2(current_size, current_size)
	
	if hits >= 3:
		queue_free()
		get_parent().emit_signal("leak_fixed")
