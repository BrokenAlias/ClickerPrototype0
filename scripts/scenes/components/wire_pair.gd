class_name MinigameElectiricity_WirePair
extends Node2D


var color: Color = Color.MAGENTA
var holding_wire: bool = false
var is_connected: bool = false # NOTE(vanya): Used by the minigame root script to check if this pair is connected
var wire_end_pos: Vector2 = Vector2.ZERO

@onready var connection_line: Line2D = $ConnectionLine
# NOTE(vanya): Better abstract the wire pair node into a scene with helpers
@onready var node_l: Node2D = $NodeL
@onready var node_r: Node2D = $NodeR
@onready var color_rect_l: ColorRect = $NodeL/ColorRect
@onready var color_rect_r: ColorRect = $NodeR/ColorRect


func _ready() -> void:
	var parent_control := get_parent() as Control
	assert(parent_control != null, "Could not get parent control node! (Node tree changed?)")
	
	var window_center: Vector2 = parent_control.get_global_rect().get_center()
	var window_size: Vector2 = parent_control.get_global_rect().size
	node_l.position.x = window_center.x - window_size.x * 0.25
	node_r.position.x = window_center.x + window_size.x * 0.25


func _input(e: InputEvent) -> void:
	if e is InputEventMouseButton:
		var mouse_event := e as InputEventMouseButton
		
		var within_end_of_wire: bool = mouse_event.position.distance_to(wire_end_pos) < 50.0
		var within_right_node: bool = mouse_event.position.distance_to(node_r.global_position) < 50.0
		
		if e.pressed and within_end_of_wire:
			holding_wire = true
		
		if holding_wire and not e.pressed:
			holding_wire = false
			
			if within_right_node:
				# Released on right node
				is_connected = true
				set_wire_end(node_r.global_position)
			else:
				# Released someplace else
				is_connected = false
				set_wire_end(node_l.global_position) # Retract into left node


func _process(_delta: float) -> void:
	if holding_wire:
		set_wire_end(connection_line.get_global_mouse_position())
	else:
		if is_connected:
			set_wire_end(node_r.global_position)
		else:
			set_wire_end(node_l.global_position)


func set_node_y_left(val: float) -> void:
	node_l.position.y = val


func set_node_y_right(val: float) -> void:
	node_r.position.y = val


func set_color(p_color: Color) -> void:
	color = p_color
	
	color_rect_l.color = color
	color_rect_r.color = color
	connection_line.default_color = color


func set_wire_end(target: Vector2) -> void:
	wire_end_pos = target
	
	# Update line to use new end
	connection_line.points = PackedVector2Array([
			node_l.global_position,
			wire_end_pos,
	])
