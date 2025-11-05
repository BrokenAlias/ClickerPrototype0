extends Node


const ITEM_DISPLAY = preload("res://resources/items/package.tres")


@onready var money_label: Label = $Control/MoneyLabel
@onready var conveyor_items_container: Node2D = $Control/ConveyorItemsContainer
@onready var conveyor_spawn_marker: Marker2D = $Control/ConveyorItemsContainer/SpawnMarker
@onready var conveyor_sold_marker: Marker2D = $Control/ConveyorItemsContainer/SoldHorizonlalMarker


var money: int = 0
var conveyor_items: Array[ItemDisplay] = []


func _ready() -> void:
	#show_overlay("Fuse")
	pass
	
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


func _on_fuse_m_inigame_pressed() -> void:
	show_overlay("Fuse")


func _on_pipes_fix_b_utton_pressed() -> void:
	show_overlay("Pipes")


func _on_valve_fix_minigame_pressed() -> void:
	show_overlay("Valve")


func _request_product_click() -> void:
	var item_display := ITEM_DISPLAY.instantiate() as ItemDisplay
	conveyor_items_container.add_child(item_display)
	conveyor_items.push_back(item_display)
	
	item_display.global_position = conveyor_spawn_marker.global_position
	item_display.set_item(load("res://resources/items/package.tres") as Item)


func sell_conveyor_item(item_display: ItemDisplay) -> void:
	conveyor_items.erase(item_display)
	item_display.queue_free()
	money += 10
