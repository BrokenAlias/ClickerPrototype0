class_name MinigameElectricity
extends Panel


const NODE_PAIR_COUNT: int = 3
const WIRE_PAIR = preload("uid://xxtcwl4dtb0y")

var wire_pairs: Array[MinigameElectiricity_WirePair] = []

@onready var main: Main = owner


func _ready() -> void:
	pass


func was_broken() -> void:
	var random_y_indices_for_right_column: Array = range(NODE_PAIR_COUNT)
	random_y_indices_for_right_column.shuffle() # Randomize the end postions for the right column
	for i: int in range(NODE_PAIR_COUNT):
		var wp := WIRE_PAIR.instantiate() as MinigameElectiricity_WirePair
		wire_pairs.push_back(wp)
		add_child(wp)
		
		wp.global_position = Vector2.ZERO
		wp.set_color(Color(
			randf_range(0.0, 1.0),
			randf_range(0.0, 1.0),
			randf_range(0.0, 1.0),
		))
		
		var window_rect: Rect2 = get_global_rect()
		var y_increment: float = window_rect.size.y / (NODE_PAIR_COUNT + 1)
		
		wp.set_node_y_left(window_rect.position.y + y_increment * (i + 1)) # i increments linearly
		wp.set_node_y_right(window_rect.position.y + y_increment * (random_y_indices_for_right_column[i] + 1))


func _process(_delta: float) -> void:
	if main.is_broken("Electricity"):
		var all_wires_connected: bool = wire_pairs.all(
				func(wp: MinigameElectiricity_WirePair) -> bool:
					return wp.is_connected
		)
		
		if all_wires_connected:
			for wp in wire_pairs:
				wp.queue_free()
			wire_pairs.clear()
			
			main.fix_minigame("Electricity")
