extends Node2D

var button_type = null

func _ready():
	Settings.narration_player = $NarrationPlayer

func _on_accessibility_pressed() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/accessbilityLargeNonCapi.tscn")


func _on_audio_pressed() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/AudioLargeNonCapi.tscn")


func _on_gameplay_pressed() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/GameplayLargeNonCapi.tscn")

func _on_other_pressed() -> void:
	Audio.play_click()
	pass
	
func _on_back_pressed() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/MainMenuNonCapiLarge.tscn")
	
func _on_accessibility_mouse_entered() -> void:
	Settings.play_narration("Accessibility")

func _on_audio_mouse_entered() -> void:
	Settings.play_narration("Audio")

func _on_gameplay_mouse_entered() -> void:
	Settings.play_narration("Gameplay")

func _on_other_mouse_entered() -> void:
	Settings.play_narration("Other")

func _on_resync_mouse_entered() -> void:
	Settings.play_narration("Resync")

func _on_back_mouse_entered() -> void:
	Settings.play_narration("Back")

func _on_language_mouse_entered() -> void:
	Settings.play_narration("Language")


func _on_resync_pressed() -> void:
	Audio.play_check()
	pass # Replace with function body.
