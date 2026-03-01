extends Node2D

var button_type = null

func _ready():
	Settings.narration_player = $NarrationPlayer
	Settings.sync_accessibility(self)
	
	Settings.narration_player = $NarrationPlayer
	
	var cap_checkbox = $"3 settings/Capitilzation"
	cap_checkbox.button_pressed = Settings.capitalization_enabled
	
	var narration_checkbox = $"3 settings/MenuNarration"
	narration_checkbox.button_pressed = Settings.menu_narration_enabled
	
	var gender_option = $"VoiceNarration"
	
	if Settings.narration_gender == "male":
		gender_option.select(0)
	else:
		gender_option.select(1)

func _on_accessibility_pressed() -> void:
	pass
	#wget_tree().change_scene_to_file("res://scenes/options/accessbility.tscn")

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

func _on_text_size_item_selected(index: int) -> void:
	match index:
		0:
			get_tree().change_scene_to_file("res://scenes/Options/accessbilitySmall.tscn")
		1:
			get_tree().change_scene_to_file("res://scenes/Options/accessbility.tscn")

func _on_capitilzation_pressed() -> void:
	Audio.play_check()
	var checkbox = $"3 settings/Capitilzation"
	Settings.capitalization_enabled = checkbox.button_pressed
	
	get_tree().change_scene_to_file("res://scenes/Options/accessbilitySmall.tscn")
	
func _on_voice_narration_item_selected(index: int):
	match index:
		0:
			Settings.narration_gender = "male"
		1:
			Settings.narration_gender = "female"
			
func _on_menu_narration_pressed() -> void:
	Audio.play_check()
	var checkbox = $"3 settings/MenuNarration"
	Settings.menu_narration_enabled = checkbox.button_pressed
	
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

func _on_capitilzation_mouse_entered() -> void:
	Settings.play_narration("TextCapitalization")

func _on_menu_narration_mouse_entered() -> void:
	Settings.play_narration("Menu Narration")
	
func _on_voice_narration_mouse_entered() -> void:
	Settings.play_narration("Gender")

func _on_sound_cues_mouse_entered() -> void:
	Settings.play_narration("SoundCue")

func _on_motion_effects_mouse_entered() -> void:
	Settings.play_narration("Motion")

func _on_check_box_mouse_entered() -> void:
	Settings.play_narration("DisableFlashingLights")

func _on_color_theme_mouse_entered() -> void:
	Settings.play_narration("Color")

func _on_text_size_mouse_entered() -> void:
	Settings.play_narration("TextSize")

func _on_sound_cues_pressed() -> void:
	Audio.play_check()
	var checkbox = $"Sensory Settings/SoundCues"
	Settings.sound_cues_enabled = checkbox.button_pressed
	
	Settings.apply_sound_cues()


func _on_motion_effects_pressed() -> void:
	Audio.play_check()
	pass # Replace with function body.


func _on_check_box_pressed() -> void:
	Audio.play_check()
	pass # Replace with function body.
