extends Panel

@onready var main: Node = $"../../.."

var startPoint = null
var startPointLine: Line2D = null
@onready var line: Line2D = $Line2D
var drawing = false
var completed_wires := {}

func _ready() -> void:
	for cp in get_tree().get_nodes_in_group("connection_points"):
		completed_wires[cp.color] = false


func _input(event):
	if visible:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					var pos = event.position
					var cp = get_connection_point_at_pos(pos)
					if cp:
						startPoint = cp
						startPointLine = cp.get_node("Line2D")
						drawing = true
						startPointLine.global_position = Vector2.ZERO
						startPointLine.clear_points()
						startPointLine.add_point(startPoint.get_global_rect().get_center())
						startPointLine.add_point(pos)
				else:
					if drawing:
						var pos = event.global_position
						var cp = get_connection_point_at_pos(pos)
						if cp and cp != startPoint and cp.color == startPoint.color:
							# Correct connection made, snap line endpoint
							startPointLine.set_point_position(1, cp.get_global_rect().get_center())
							if cp and cp != startPoint and cp.color == startPoint.color:
								# Correct connection made, snap line endpoint
								startPointLine.set_point_position(1, cp.get_global_rect().get_center())
								completed_wires[startPoint.color] = true
								print("Connection correct!")
								
								_check_if_game_complete()
						else:
							 # Cancel connection if incorrect
							startPointLine.clear_points()
						drawing = false
						startPoint = null

		elif event is InputEventMouseMotion and drawing:
			startPointLine.set_point_position(1, event.position)

# Helper to find ColorRect at mouse pos
func get_connection_point_at_pos(pos):
	for cp in get_tree().get_nodes_in_group("connection_points"):
		if cp.get_global_rect().has_point(pos):
			return cp
	return null
	
func _check_if_game_complete():
	for color in completed_wires.keys():
		if completed_wires[color] == false:
			return # Not done yet
		main.fix_minigame(self.name)
	
