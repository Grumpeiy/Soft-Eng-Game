extends Node2D

var button_type = null

func _on_accessibility_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Options/accessbilitySmallNonCapi.tscn")


func _on_audio_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Options/AudioSmallNonCapi.tscn")

func _on_gameplay_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Options/GameplaySmallNonCapi.tscn")

func _on_other_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Options/OtherSmallNonCapi.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Options/MainMenuNonCapiSmall.tscn")
