extends Node2D

var button_type = null

func _ready():
	Settings.narration_player = $NarrationPlayer

func _on_accessibility_pressed() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/accessbility.tscn")

func _on_audio_pressed() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/AudioLarge.tscn")

func _on_gameplay_pressed() -> void:
	pass

func _on_other_pressed() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/Other.tscn")

func _on_back_pressed() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/options/main_menu.tscn")

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

func _on_difficulty_mouse_entered() -> void:
	Settings.play_narration("DifficultyLevel")
	
func _on_guided_mouse_entered() -> void:
	Settings.play_narration("Guided")

func _on_tutorial_mouse_entered() -> void:
	Settings.play_narration("TutorialMode")

func _on_autoplay_mouse_entered() -> void:
	Settings.play_narration("Autoplay")


func _on_difficulty_pressed() -> void:
	Audio.play_check()
	pass # Replace with function body.


func _on_guided_pressed() -> void:
	Audio.play_check()
	pass # Replace with function body.


func _on_tutorial_pressed() -> void:
	Audio.play_check()
	pass # Replace with function body.


func _on_autoplay_pressed() -> void:
	Audio.play_check()
	pass # Replace with function body.
