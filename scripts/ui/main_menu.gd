extends Control

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/rlyleh/level_01.tscn")

func _on_store_pressed() -> void:
	pass  # TODO: store scene

func _on_about_pressed() -> void:
	pass  # TODO: about screen
