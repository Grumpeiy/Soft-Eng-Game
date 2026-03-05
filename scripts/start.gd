extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_back_pressed() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/main_menu.tscn")

func _on_create_pressed() -> void:
	Audio.play_click()
	pass # Replace with function body.

func _on_erase_pressed() -> void:
	Audio.play_click()
	
	"""if Settings.tutorial_mode_enabled and not Settings.has_seen_tutorial:
		$fade_transition.show()
		$fade_transition/fade_timer.start()
		$fade_transition/AnimationPlayer.play("fade_in")
		get_tree().change_scene_to_file("res://scenes/tutorial.tscn")
	else:
		button_type = "Load"
		$fade_transition.show()
		$fade_transition/fade_timer.start()
		$fade_transition/AnimationPlayer.play("fade_in")"""

func _on_load_pressed() -> void:
	Audio.play_click()
	pass # Replace with function body.

func _on_back_mouse_entered() -> void:
	pass # Replace with function body.

func _on_create_mouse_entered() -> void:
	pass # Replace with function body.

func _on_erase_mouse_entered() -> void:
	pass # Replace with function body.

func _on_erase_2_mouse_entered() -> void:
	pass # Replace with function body.

func _on_load_mouse_entered() -> void:
	pass # Replace with function body.
