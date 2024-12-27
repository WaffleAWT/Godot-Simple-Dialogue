extends Control

func _ready() -> void:
	$AutomaticDialogue.play()

func _on_automatic_dialogue_dialogue_finished() -> void:
	$AutomaticDialogue.queue_free()
	$PlayerInputDialogue.play()

func _on_player_input_dialogue_dialogue_finished() -> void:
	get_tree().quit()
