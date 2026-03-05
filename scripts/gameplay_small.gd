extends Node2D

var button_type = null

func _ready():
	Settings.narration_player = $NarrationPlayer
	Settings.sync_gameplay(self)

func _on_accessibility_pressed() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/accessbilitySmall.tscn")

func _on_audio_pressed() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/AudioSmall.tscn")

func _on_gameplay_pressed() -> void:
	pass

func _on_other_pressed() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/OtherSmall.tscn")

func _on_back_pressed() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/main_menuSmall.tscn")

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
	
func _on_guided_mouse_entered() -> void:
	Settings.play_narration("Guided")

func _on_tutorial_mouse_entered() -> void:
	Settings.play_narration("TutorialMode")

func _on_autoplay_mouse_entered() -> void:
	Settings.play_narration("Autoplay")

func _on_difficulty_options_item_selected(index: int) -> void:
	Audio.play_click()
	match index:
		0:
			Settings.difficulty_level = "easy"
		1:
			Settings.difficulty_level = "normal"
		2:
			Settings.difficulty_level = "hard"
		
	print("Difficulty set to: ", Settings.difficulty_level)


func _on_difficulty_options_mouse_entered() -> void:
	Settings.play_narration("DifficultyLevel")

func _on_difficulty_options_pressed() -> void:
	Audio.play_check()
	pass # Replace with function body.


func _on_guided_pressed() -> void:
	Audio.play_check()
	
	var checkbox = $gameplay/guided
	Settings.guided_mode_enabled = checkbox.button_pressed
	
	if Settings.guided_mode_enabled:
		print("Guided Mode ENABLED - Adaptive assistance will help students")
	else:
		print("Guided Mode DISABLED - No adaptive assistance")

func _on_tutorial_pressed() -> void:
	Audio.play_check()
	
	var checkbox = $gameplay/tutorial
	Settings.tutorial_mode_enabled = checkbox.button_pressed
	
	if Settings.tutorial_mode_enabled:
		print("Tutorial Mode ENABLED - Tutorial will show on next game start")
		Settings.has_seen_tutorial = false
	else:
		print("Tutorial Mode DISABLED")


func _on_autoplay_pressed() -> void:
	Audio.play_check()
	pass # Replace with function body.
