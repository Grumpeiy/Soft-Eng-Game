extends Node2D

var button_type = null

func _on_accessibility_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Options/accessbilityLargeNonCapi.tscn")


func _on_audio_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Options/AudioLargeNonCapi.tscn")


func _on_gameplay_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Options/GameplayLargeNonCapi.tscn")

func _on_other_pressed() -> void:
	pass
	
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Options/MainMenuNonCapiLarge.tscn")
