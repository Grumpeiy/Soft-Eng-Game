extends Node2D

var button_type = null

func _on_accessibility_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Options/accessbility.tscn")


func _on_audio_pressed() -> void:
	pass
	#get_tree().change_scene_to_file("res://scenes/Options/Audio.tscn")


func _on_gameplay_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Options/Gameplay.tscn")

func _on_other_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Options/Other.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options/main_menu.tscn")
