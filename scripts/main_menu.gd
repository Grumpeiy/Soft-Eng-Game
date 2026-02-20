extends Node2D

var button_type = null
@onready var transition_fx = preload("res://sfx/music/Menu.mp3")

func _ready():
	MenuMusic.play_music_level()


func _on_start_pressed():
	button_type = "start"
	$fade_transition.show()
	$fade_transition/fade_timer.start()
	$fade_transition/AnimationPlayer.play("fade_in")


func _on_option_pressed():
	get_tree().change_scene_to_file("res://scenes/Options/options.tscn")


func _on_quit_pressed():
	get_tree().quit()


func transition():
	MenuMusic.play_FX(transition_fx, -12)


func _on_fade_timer_timeout():
	if button_type == "start":
		get_tree().change_scene_to_file("res://scenes/Well.tscn")
