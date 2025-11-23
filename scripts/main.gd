extends Node


const ITEM_DISPLAY = preload("res://scenes/item_display.tscn")


@onready var money_label: Label = $Control/MoneyLabel
@onready var conveyor_items_container: Node2D = $Control/ConveyorItemsContainer
@onready var conveyor_spawn_marker: Marker2D = $Control/ConveyorItemsContainer/SpawnMarker
@onready var conveyor_sold_marker: Marker2D = $Control/ConveyorItemsContainer/SoldHorizonlalMarker

@onready var minigame_states: Dictionary[String, MinigameState] = {
	"Valve": MinigameState.new(self, "Valve", -1.0),
	"Electricity": MinigameState.new(self, "Electricity", -1.0),
}

var money: int = 0

# 0 -> 1 ranges
var resource_pressure: float = 1.0
var resource_charge: float = 1.0

var conveyor_items: Array[ItemDisplay] = []


func _ready() -> void:
	show_overlay("")
	
	for minigame_state: MinigameState in minigame_states.values():
		minigame_state.fix_button.button_down.connect(
			func() -> void:
				show_overlay(minigame_state.id)
		)
		fix_minigame(minigame_state.id)
	
	($PhysicsItem as PhysicsItem).set_item(load("res://resources/items/package.tres") as Item)


func _process(delta: float) -> void:
	for minigame_state: MinigameState in minigame_states.values():
		if minigame_state.time_until_broken > 0.0:
			minigame_state.time_until_broken -= delta
			if minigame_state.time_until_broken <= 0.0:
				minigame_state.time_until_broken = 0.0
				minigame_state.fix_button.show()
	
	# Close any minigame UI
	if Input.is_action_just_pressed("leave_minigame"):
		show_overlay("")
	
	# Handle conveyoritems
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
	
	if is_broken("Electricity"):
		resource_charge -= delta * 0.1 # 10 seconds (delta = 1 second)
	else:
		resource_charge = 1.0


func show_overlay(minigame: String) -> void:
	for minigame_name in minigame_states.keys():
		var minigame_state: MinigameState = minigame_states[minigame_name]
		minigame_state.minigame_overlay.visible = (minigame == minigame_name)


func is_broken(minigame: String) -> bool:
	return minigame_states.get(minigame, null).fix_button.visible


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


func fix_minigame(id: String) -> void:
	var minigame_state: MinigameState = minigame_states.get(id, null)
	minigame_state.fix_button.hide()
	minigame_state.time_until_broken = randf_range(5.0, 10.0)
	show_overlay("")


class MinigameState:
	var id: String = ""
	var time_until_broken: float = 0.0
	var minigame_overlay: Control = null
	var fix_button: Button = null
	
	func _init(parent: Node, p_id: String, p_time_until_broken: float):
		id = p_id
		time_until_broken = p_time_until_broken
		
		minigame_overlay = parent.get_node("Control/MinigameOverlays/%s" % p_id)
		fix_button = parent.get_node("Control/FixButtons/%s" % p_id)
