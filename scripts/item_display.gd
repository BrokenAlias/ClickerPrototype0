class_name ItemDisplay
extends Node2D


var item: Item

@onready var icon: Sprite2D = $Icon


func set_item(new_item: Item) -> void:
	item = new_item
	
	icon.texture = item.icon
