extends Node


const ITEM_DISPLAY = preload("res://scenes/item_display.tscn")


@onready var money_label: Label = $Control/MoneyLabel
@onready var conveyor_items_container: Node2D = $Control/ConveyorItemsContainer
@onready var conveyor_spawn_marker: Marker2D = $Control/ConveyorItemsContainer/SpawnMarker
@onready var conveyor_sold_marker: Marker2D = $Control/ConveyorItemsContainer/SoldHorizonlalMarker

@onready var break_timers: Array[Timer] = [
	$Control/ValveFixMinigame/BreakTimer,
]

@onready var fix_minigame_buttons: Dictionary[String, Button] = {
	"Valve": $Control/ValveFixMinigame,
}

var money: int = 0

# 0 -> 1 ranges
var resource_pressure: float = 1.0
var resource_charge: float = 1.0

var conveyor_items: Array[ItemDisplay] = []


func _ready() -> void:
	show_overlay("")
	
	for fix_minigame_button: Button in fix_minigame_buttons.values():
		fix_minigame_button.hide()
	
	for break_timer: Timer in break_timers:
		break_timer.wait_time = randf_range(5.0, 10.0)
		break_timer.start()
	
	# give random break times


func show_overlay(overlay_name: String) -> void:
	for child in $Control/MinigameOverlays.get_children():
		child.visible = (child.name == overlay_name)


func _process(delta: float) -> void:
	# Close any minigame UI
	if Input.is_action_just_pressed("leave_minigame"):
		show_overlay("")
	
	for conveyor_item in conveyor_items:
		conveyor_item.position.x += 400.0 * delta
		
		if conveyor_item.global_position.x > conveyor_sold_marker.global_position.x:
			sell_conveyor_item(conveyor_item)
	
	money_label.text = "Money: %d" % money
	$Control/Control/Pressure.value = resource_pressure
	$Control/Control/Charge.value = resource_charge
	
	# Resources lowering
	if is_broken("Valve"):
		resource_pressure -= delta * 0.1 # 10 seconds (delta = 1 second)
	else:
		resource_pressure = 1.0


func is_broken(minigame: String) -> bool:
	return fix_minigame_buttons.get(minigame, null).visible


func _on_fuse_m_inigame_pressed() -> void:
	show_overlay("Fuse")


func _on_pipes_fix_b_utton_pressed() -> void:
	show_overlay("Pipes")


func _on_valve_fix_minigame_pressed() -> void:
	show_overlay("Valve")


func _request_product_click() -> void:
	var enough_resources: bool = (
		resource_pressure > 0.1
		and resource_charge > 0.025
	)
	
	if enough_resources:
		# Subtract resources
		resource_pressure -= 0.1
		resource_charge -= 0.025
		
		# Spawn
		var item_display := ITEM_DISPLAY.instantiate() as ItemDisplay
		conveyor_items_container.add_child(item_display)
		conveyor_items.push_back(item_display)
		
		item_display.global_position = conveyor_spawn_marker.global_position
		item_display.set_item(load("res://resources/items/package.tres") as Item)


func sell_conveyor_item(item_display: ItemDisplay) -> void:
	conveyor_items.erase(item_display)
	item_display.queue_free()
	money += 10


func _on_valve_break_timer_timeout() -> void:
	fix_minigame_buttons.get("Valve").show()
