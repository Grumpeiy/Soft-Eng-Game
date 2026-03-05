extends Control 

func _ready():
	hide()

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	hide()

func pause():
	show()
	get_tree().paused = true
	$AnimationPlayer.play("blur")

func testEsc():
	if Input.is_action_just_pressed("esc"):
		if get_tree().paused:
			resume()
		else:
			pause()

func _on_resume_pressed() -> void:
	Audio.play_click()
	resume()
	
#func _on_resume_pressed():
	#Audio.play_click()
	#get_tree().paused = false
	#queue_free()  # Remove the pause menu

func _process(delta: float) -> void:
	testEsc()


func _on_quit_pressed() -> void:
	Audio.play_click()
	get_tree().paused = false
	
	get_tree().change_scene_to_file(Settings.current_main_menu_scene)

func _on_option_pressed() -> void:
	pass

func _on_progress_pressed() -> void:
	pass # Replace with function body.

func _on_badges_2_pressed() -> void:
	pass # Replace with function body.
