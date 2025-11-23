class_name PhysicsItem
extends RigidBody2D


var item: Item = null:
	get:
		return item_display.item

var mouse_hovered: bool = false
var dragging: bool = false

@onready var item_display: ItemDisplay = $ItemDisplay


func _process(delta: float) -> void:
	if dragging:
		global_position = lerp(global_position, get_global_mouse_position(), 10.0 * delta)
	
	item_display.rotation = lerp(item_display.rotation, linear_velocity.x * -0.0002, 10.0 * delta)
	item_display.global_scale = lerp(item_display.global_scale,
		(
			Vector2.ONE
			+ Vector2(
				abs(linear_velocity.x) - abs(linear_velocity.y) * 0.2,
				abs(linear_velocity.y) - abs(linear_velocity.x) * 0.8
			)* Vector2.ONE.rotated(rotation) * 0.0001
		),
		10.0 * delta
	)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var click_event := event as InputEventMouseButton
		
		if mouse_hovered and click_event.pressed:
			# Take
			freeze = true
			dragging = true
		
		if dragging and not click_event.pressed:
			# Release
			dragging = false
			freeze = false
			
			# Apply release velocity
			var remaining_dist: Vector2 = (get_global_mouse_position() - global_position)
			apply_central_impulse(remaining_dist * 10.0)


func clear_item() -> void:
	item_display.clear_item()


func set_item(new_item: Item) -> void:
	item_display.set_item(new_item)


func _on_click_hitbox_mouse_entered() -> void:
	mouse_hovered = true


func _on_click_hitbox_mouse_exited() -> void:
	mouse_hovered = false
