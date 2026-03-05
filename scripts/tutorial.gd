extends Control

var current_step = 0
var tutorial_steps = [
	"Welcome! Press NEXT to learn the controls.",
	"Use Arrow Keys (← → ↑ ↓) to move.",
	"Press [C] to interact with NPCs.",
	"Press [SPACE] to skip dialogue.",
	"Press [ESC] to pause.",
	"You're ready! Press START GAME!"
]

@onready var label = $Label
@onready var next_btn = $HBoxContainer/NextButton 
@onready var back_btn = $HBoxContainer/BackButton
@onready var skip_btn = $HBoxContainer/SkipButton

func _ready():
	next_btn.focus_mode = Control.FOCUS_NONE
	back_btn.focus_mode = Control.FOCUS_NONE
	skip_btn.focus_mode = Control.FOCUS_NONE
	
	modulate.a = 0
	
	#Fade in
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	
	show_step(current_step)

func show_step(step_index: int):
	label.text = tutorial_steps[step_index]
	
	back_btn.visible = (step_index > 0)
	skip_btn.visible = (step_index < 5)
	
	if step_index < tutorial_steps.size() - 1:
		next_btn.text = "Next"
	else:
		next_btn.text = "Start Game!"

func _on_next_button_pressed():
	Audio.play_click()
	current_step += 1
	
	if current_step >= tutorial_steps.size():
		fade_out_and_start_game()
	else:
		show_step(current_step)

func _on_back_button_pressed():
	Audio.play_click()
	if current_step > 0:
		current_step -= 1
		show_step(current_step)

func _on_skip_button_pressed():
	Audio.play_click()
	fade_out_and_start_game()

func fade_out_and_start_game():
	Settings.has_seen_tutorial = true
	
	next_btn.disabled = true
	back_btn.disabled = true
	skip_btn.disabled = true
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/Well.tscn")
	)
