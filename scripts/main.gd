extends Node


func _ready() -> void:
	show_overlay("Fuse")


func show_overlay(overlay_name: String) -> void:
	for child in $Control/MinigameOverlays.get_children():
		child.visible = (child.name == overlay_name)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("leave_minigame"):
		show_overlay("")


func _on_fuse_m_inigame_pressed() -> void:
	show_overlay("Fuse")


func _on_pipes_fix_b_utton_pressed() -> void:
	show_overlay("Pipes")


func _on_valve_fix_minigame_pressed() -> void:
	show_overlay("Valve")
