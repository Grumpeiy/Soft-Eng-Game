extends Node2D

var button_type = null
@onready var transition_fx = preload("res://Sounds/music/MenuMusic.mp3")
@onready var student_text = $Student

func _ready():
	MenuMusic.play_music_level()
	Settings.narration_player = $NarrationPlayer
	Settings.current_main_menu_scene = scene_file_path
	
	if not PlayerData.is_logged_in:
		call_deferred("redirect_to_login")
		return
	
	print("Welcome, %s!" % PlayerData.get_display_name())

	student_text.text = PlayerData.get_display_name()

	if has_node("WelcomeLabel"):
		$WelcomeLabel.text = "Welcome, %s" % PlayerData.get_display_name()

func redirect_to_login():
	get_tree().change_scene_to_file("res://scenes/login_menu.tscn")

func _on_start_pressed():
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/Start.tscn")
	"""if Settings.tutorial_mode_enabled and not Settings.has_seen_tutorial:
		get_tree().change_scene_to_file("res://scenes/tutorial.tscn")
	else:
		button_type = "start"
		$fade_transition.show()
		$fade_transition/fade_timer.start()
		$fade_transition/AnimationPlayer.play("fade_in")"""

func _on_option_pressed():
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/options.tscn")


func _on_progress_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Options/Progress.tscn")
	Audio.play_click()

func _on_badges_button_pressed() -> void:
	Audio.play_click()

func _on_quit_pressed():
	PlayerData.logout()
	get_tree().quit()
	#get_tree().change_scene_to_file("res://scenes/login_menu.tscn")

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

func _on_badges_button_mouse_entered() -> void:
	Settings.play_narration("Badges")

func _on_quit_mouse_entered():
	Settings.play_narration("Exit")
