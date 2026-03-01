extends Node2D

var button_type = null

func _on_accessibility_pressed() -> void:
	pass
	#wget_tree().change_scene_to_file("res://scenes/options/accessbility.tscn")


func _on_audio_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Options/AudioLarge.tscn")


func _on_gameplay_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Options/Gameplay.tscn")

func _on_other_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Options/Other.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options/main_menu.tscn")

func _on_text_size_item_selected(index: int) -> void:
	match index:
		0:
			get_tree().change_scene_to_file("res://scenes/Options/accessbilitySmall.tscn")
		1:
			get_tree().change_scene_to_file("res://scenes/Options/accessbility.tscn")

func _on_capitilzation_pressed() -> void:
	var checkbox = $"3 settings/Capitilzation"
	
	Settings.capitalization_enabled = checkbox.button_pressed
	
	get_tree().change_scene_to_file("res://scenes/Options/accessbilityLargeNonCapi.tscn")
