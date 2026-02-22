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
	resume()

func _process(delta: float) -> void:
	testEsc()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_option_pressed() -> void:
	resume()
	get_tree().change_scene_to_file("res://scenes/Options/options.tscn")


func _on_progress_pressed() -> void:
	pass # Replace with function body.


func _on_badges_2_pressed() -> void:
	pass # Replace with function body.
