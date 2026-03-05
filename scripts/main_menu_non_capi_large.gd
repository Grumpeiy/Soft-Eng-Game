extends Node2D

var button_type = null
@onready var transition_fx = preload("res://Sounds/music/MenuMusic.mp3")

func _ready():
	MenuMusic.play_music_level()
	Settings.narration_player = $NarrationPlayer
	Settings.current_main_menu_scene = "res://scenes/Options/MainMenuNonCapiLarge.tscn"

func _on_start_pressed():
	Audio.play_click()
	
	if Settings.tutorial_mode_enabled and not Settings.has_seen_tutorial:
		$fade_transition.show()
		$fade_transition/fade_timer.start()
		$fade_transition/AnimationPlayer.play("fade_in")
		get_tree().change_scene_to_file("res://scenes/tutorial.tscn")
	else:
		button_type = "start"
		$fade_transition.show()
		$fade_transition/fade_timer.start()
		$fade_transition/AnimationPlayer.play("fade_in")

func _on_option_pressed():
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/optionsNonCapi.tscn")


func _on_quit_pressed():
	get_tree().quit()


func transition():
	MenuMusic.play_FX(transition_fx, -12)


func _on_fade_timer_timeout():
	if button_type == "start":
		get_tree().change_scene_to_file("res://scenes/Well.tscn")

func _on_start_mouse_entered():
	Settings.play_narration("Start")

func _on_option_mouse_entered():
	Settings.play_narration("Options")

func _on_progress_mouse_entered():
	Settings.play_narration("Progress")

func _on_texture_button_mouse_entered():
	Settings.play_narration("Badges")

func _on_quit_mouse_entered():
	Settings.play_narration("Exit")


func _on_progress_pressed() -> void:
	Audio.play_click()
	pass # Replace with function body.


func _on_texture_button_pressed() -> void:
	Audio.play_click()
	pass # Replace with function body.
