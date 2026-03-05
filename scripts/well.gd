extends Node2D

func _ready():
	$fade_transition/AnimationPlayer.play("fade_out")
	MenuMusic.stop_music()
	


func _on_choice_a_pressed() -> void:
	Audio.play_click()
	pass # Replace with function body.


func _on_choice_b_pressed() -> void:
	Audio.play_click()
	pass # Replace with function body.


func _on_choice_c_pressed() -> void:
	Audio.play_click()
	pass # Replace with function body.


func _on_choice_d_pressed() -> void:
	Audio.play_click()
	pass # Replace with function body.
