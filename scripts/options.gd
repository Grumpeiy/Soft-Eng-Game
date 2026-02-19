extends Node2D

var button_type = null

func _on_accessibility_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/accessbility.tscn")


func _on_audio_pressed() -> void:
	pass # Replace with function body.


func _on_gameplay_pressed() -> void:
	pass # Replace with function body.


func _on_other_pressed() -> void:
	pass # Replace with function body.


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
