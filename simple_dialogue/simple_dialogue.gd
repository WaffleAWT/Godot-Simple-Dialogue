@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("Dialogue", "Label", preload("res://addons/simple_dialogue/simple_dialogue.gd"), preload("res://addons/simple_dialogue/Assets/Dialogue.png"))

func _exit_tree() -> void:
	remove_custom_type("Dialogue")
