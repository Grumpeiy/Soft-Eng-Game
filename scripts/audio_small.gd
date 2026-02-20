extends Node2D

var button_type = null

func _on_accessibility_pressed() -> void:
	pass
	get_tree().change_scene_to_file("res://scenes/options/accessbilitySmall.tscn")


func _on_audio_pressed() -> void:
	pass


func _on_gameplay_pressed() -> void:
	pass

func _on_other_pressed() -> void:
	pass

func _on_back_pressed() -> void:
	pass


func _on_text_size_item_selected(index: int) -> void:
	match index:
		0:
			get_tree().change_scene_to_file("res://scenes/Options/accessbilitySmall.tscn")
		1:
			get_tree().change_scene_to_file("res://scenes/Options/accessbility.tscn")
