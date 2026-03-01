extends Node2D

var button_type = null

func _ready():
	Settings.narration_player = $NarrationPlayer

func _on_accessibility_pressed() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/accessbilitySmallNonCapi.tscn")

func _on_audio_pressed() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/AudioSmallNonCapi.tscn")

func _on_gameplay_pressed() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/GameplaySmallNonCapi.tscn")

func _on_other_pressed() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/OtherSmallNonCapi.tscn")

func _on_back_pressed() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/MainMenuNonCapiSmall.tscn")

func _on_accessibility_mouse_entered() -> void:
	Settings.play_narration("Accessibility")

func _on_audio_mouse_entered() -> void:
	Settings.play_narration("Audio")

func _on_gameplay_mouse_entered() -> void:
	Settings.play_narration("Gameplay")

func _on_other_mouse_entered() -> void:
	Settings.play_narration("Other")

func _on_back_mouse_entered() -> void:
	Settings.play_narration("Back")
