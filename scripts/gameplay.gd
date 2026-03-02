extends Node2D

var button_type = null

func _ready():
	Settings.narration_player = $NarrationPlayer
	
	# Safely sync difficulty from Settings (check if node exists first)
	if has_node("DifficultyOptions"):
		var difficulty_dropdown = $DifficultyOptions
		if Settings.difficulty_level == "easy":
			difficulty_dropdown.select(0)
		elif Settings.difficulty_level == "normal":
			difficulty_dropdown.select(1)
		else:
			difficulty_dropdown.select(2)
	else:
		print("⚠️ DifficultyOptions node not found in scene")
	
	# Sync adaptive assistance checkbox if it exists
	if has_node("AdaptiveCheckbox"):
		$AdaptiveCheckbox.button_pressed = Settings.adaptive_assistance_enabled

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

func _on_guided_pressed() -> void:
	Audio.play_check()

func _on_tutorial_pressed() -> void:
	Audio.play_check()

func _on_autoplay_pressed() -> void:
	Audio.play_check()

func _on_difficulty_item_selected(index: int) -> void:
	match index:
		0:
			Settings.difficulty_level = "easy"
		1:
			Settings.difficulty_level = "normal"
		2:
			Settings.difficulty_level = "hard"
	
	print("Difficulty set to: ", Settings.difficulty_level)
	
	# When manually setting difficulty, disable adaptive assistance
	Settings.adaptive_assistance_enabled = false
	if has_node("AdaptiveCheckbox"):
		$AdaptiveCheckbox.button_pressed = false
	
	print("Adaptive assistance disabled (manual difficulty selected)")

# NEW: Toggle adaptive assistance
func _on_adaptive_checkbox_toggled(button_pressed: bool) -> void:
	Settings.adaptive_assistance_enabled = button_pressed
	
	if button_pressed:
		print("✨ Adaptive Assistance ENABLED - system will auto-adjust based on performance")
	else:
		print("🔒 Adaptive Assistance DISABLED - using manual difficulty:", Settings.difficulty_level)
