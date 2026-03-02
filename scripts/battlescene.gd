extends Control

var enemy_max_hp = 100
var enemy_current_hp = 100
var player_damage = 35 
var current_enemy_node = null

# Idle timer for Mid Assistance trigger
var idle_timer = 0.0
var idle_threshold = 30.0  # 30 seconds
var is_waiting_for_answer = false
var has_triggered_mid_from_idle = false  # Prevent multiple triggers

var questions = [
	{
		"text": "How many seasons does the Philippines have?",
		"options": ["Two (Wet & Dry)", "Four (Spring, Summer, Fall, Winter)", "Three", "One"],
		"correct": 0
	},
	{
		"text": "Which season usually brings heavy rains?",
		"options": ["Dry Season", "Wet Season", "Cold Season", "Hot Season"],
		"correct": 1
	},
	{
		"text": "Which month is typically the hottest in the Philippines?",
		"options": ["May", "December", "January", "September"],
		"correct": 0
	}
]

var current_question = {}
var current_question_options = []
var filtered_options = []
var correct_answer_index = -1  # Track correct answer position in filtered options

func _ready():
	visible = false
	$background.visible = false
	
	# Connect all 4 choice buttons
	$Panel/VBoxContainer/ChoiceA.pressed.connect(func(): check_answer(0))
	$Panel/VBoxContainer/ChoiceB.pressed.connect(func(): check_answer(1))
	
	# Add ChoiceC and ChoiceD if they exist in your scene
	if $Panel/VBoxContainer.has_node("ChoiceC"):
		$Panel/VBoxContainer/ChoiceC.pressed.connect(func(): check_answer(2))
	if $Panel/VBoxContainer.has_node("ChoiceD"):
		$Panel/VBoxContainer/ChoiceD.pressed.connect(func(): check_answer(3))
	
	event_handler.battle_started.connect(Callable(self, "init"))

func _process(delta):
	# Track idle time when waiting for answer
	if is_waiting_for_answer:
		idle_timer += delta
		
		# Trigger Mid Assistance after 30 seconds of inactivity (only if currently LOW tier)
		if idle_timer >= idle_threshold and Settings.current_assistance_tier == Settings.AssistanceTier.LOW and not has_triggered_mid_from_idle:
			print("⏰ 30 seconds idle - triggering Mid Assistance")
			Settings.current_assistance_tier = Settings.AssistanceTier.MID
			has_triggered_mid_from_idle = true
			
			# Reload question with Mid Assistance
			apply_mid_assistance()

func init(enemy_node, character_name, lvl):
	visible = true
	$AnimationPlayer.play("fade_in")
	get_tree().paused = true
	
	current_enemy_node = enemy_node 
	
	enemy_current_hp = enemy_max_hp
	$Panel/Label.text = "A wild %s lvl %s appears!" % [character_name, lvl]
	
	$Panel/VBoxContainer.visible = false
	$Panel/answer_button.visible = true
	
	# Reset assistance tier for new battle
	Settings.reset_assistance_tier()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_in":
		$AnimationPlayer.play("fade_out")
		$background.visible = true
		$background/Player.play("idle")
		$background/Enemy.play("idle")
		$background/Enemy.flip_h = true
		
		$Panel/answer_button.grab_focus()

func _on_answer_button_pressed():
	load_new_question()

func load_new_question():
	current_question = questions.pick_random()
	current_question_options = current_question["options"].duplicate()
	
	# Reset idle timer and flag
	idle_timer = 0.0
	is_waiting_for_answer = true
	has_triggered_mid_from_idle = false
	
	# Apply assistance tier
	apply_assistance_tier()
	
	$Panel/answer_button.visible = false
	$Panel/VBoxContainer.visible = true
	$Panel/VBoxContainer/ChoiceA.grab_focus()

func apply_assistance_tier():
	# Check if adaptive assistance is enabled
	if not Settings.adaptive_assistance_enabled:
		# Use manual difficulty setting
		apply_difficulty_based_assistance()
		return
	
	# Use adaptive assistance based on performance
	match Settings.current_assistance_tier:
		Settings.AssistanceTier.LOW:
			apply_low_assistance()
		Settings.AssistanceTier.MID:
			apply_mid_assistance()
		Settings.AssistanceTier.HIGH:
			apply_high_assistance()

func apply_difficulty_based_assistance():
	# Manual difficulty override (when adaptive is disabled)
	match Settings.difficulty_level:
		"easy":
			apply_mid_assistance()  # Always give hints
		"normal":
			apply_low_assistance()  # Standard
		"hard":
			apply_low_assistance()  # No help

# LOW ASSISTANCE: Show all 4 options, no hints
func apply_low_assistance():
	$Panel/Label.text = current_question["text"]
	
	# Reset background dimming
	$background.modulate = Color(1, 1, 1, 1)
	
	# Show all 4 choices
	filtered_options = current_question_options.duplicate()
	correct_answer_index = current_question["correct"]
	
	$Panel/VBoxContainer/ChoiceA.text = filtered_options[0]
	$Panel/VBoxContainer/ChoiceB.text = filtered_options[1]
	
	# Check if ChoiceC and ChoiceD exist
	if $Panel/VBoxContainer.has_node("ChoiceC"):
		$Panel/VBoxContainer/ChoiceC.text = filtered_options[2]
		$Panel/VBoxContainer/ChoiceC.visible = true
	
	if $Panel/VBoxContainer.has_node("ChoiceD"):
		$Panel/VBoxContainer/ChoiceD.text = filtered_options[3]
		$Panel/VBoxContainer/ChoiceD.visible = true
	
	$Panel/VBoxContainer/ChoiceA.visible = true
	$Panel/VBoxContainer/ChoiceB.visible = true
	
	# Remove any highlights
	reset_button_highlights()
	
	print("📘 LOW Assistance: 4 options, no hints")

# MID ASSISTANCE: Dim background 20%, remove 2 incorrect choices, show hint
func apply_mid_assistance():
	$Panel/Label.text = current_question["text"] + "\n\nHint: Think carefully about what you learned!"
	
	# Dim background by 20%
	$background.modulate = Color(0.8, 0.8, 0.8, 1)
	
	# Get correct answer
	var correct_answer = current_question_options[current_question["correct"]]
	
	# Get all incorrect options
	var incorrect_options = []
	for i in range(current_question_options.size()):
		if i != current_question["correct"]:
			incorrect_options.append(current_question_options[i])
	
	# Pick 1 random incorrect option
	var random_incorrect = incorrect_options.pick_random()
	
	# Create filtered list with 2 options
	filtered_options = [correct_answer, random_incorrect]
	filtered_options.shuffle()
	
	# Find where correct answer ended up
	correct_answer_index = filtered_options.find(correct_answer)
	
	# Display only 2 options
	$Panel/VBoxContainer/ChoiceA.text = filtered_options[0]
	$Panel/VBoxContainer/ChoiceB.text = filtered_options[1]
	$Panel/VBoxContainer/ChoiceA.visible = true
	$Panel/VBoxContainer/ChoiceB.visible = true
	
	# Hide ChoiceC and ChoiceD
	if $Panel/VBoxContainer.has_node("ChoiceC"):
		$Panel/VBoxContainer/ChoiceC.visible = false
	if $Panel/VBoxContainer.has_node("ChoiceD"):
		$Panel/VBoxContainer/ChoiceD.visible = false
	
	# Add subtle glow to buttons
	add_glow_effect($Panel/VBoxContainer/ChoiceA)
	add_glow_effect($Panel/VBoxContainer/ChoiceB)
	
	print("MID Assistance: 2 options, hint shown, background dimmed 20%")

# HIGH ASSISTANCE: Highlight correct answer, show guidance
func apply_high_assistance():
	$Panel/Label.text = current_question["text"] + "\n\nThe correct answer is highlighted below!"
	
	# Darken background significantly
	$background.modulate = Color(0.5, 0.5, 0.5, 1)
	
	# Show only the correct answer
	var correct_answer = current_question_options[current_question["correct"]]
	
	filtered_options = [correct_answer]
	correct_answer_index = 0
	
	$Panel/VBoxContainer/ChoiceA.text = correct_answer
	$Panel/VBoxContainer/ChoiceA.visible = true
	$Panel/VBoxContainer/ChoiceB.visible = false
	
	if $Panel/VBoxContainer.has_node("ChoiceC"):
		$Panel/VBoxContainer/ChoiceC.visible = false
	if $Panel/VBoxContainer.has_node("ChoiceD"):
		$Panel/VBoxContainer/ChoiceD.visible = false
	
	# Highlight the correct answer with pulsing effect
	highlight_correct_answer($Panel/VBoxContainer/ChoiceA)
	
	print("HIGH Assistance: Correct answer highlighted, background darkened")

func check_answer(selected_index):
	is_waiting_for_answer = false  # Stop idle timer
	$Panel/VBoxContainer.visible = false
	
	# Ensure index is valid
	if selected_index >= filtered_options.size():
		print("Invalid selection index")
		return
	
	# Check if selected answer matches correct answer
	if selected_index == correct_answer_index:
		print("Correct answer!")
		Settings.record_correct_answer()
		handle_player_attack()
	else:
		print("Incorrect answer. Consecutive wrong: ", Settings.consecutive_incorrect_answers + 1)
		Settings.record_incorrect_answer()
		handle_enemy_attack()

func handle_player_attack():
	$Panel/Label.text = "Correct! You attack!"
	
	$background/Player.play("attack")
	await get_tree().create_timer(0.5).timeout 
	
	enemy_current_hp -= player_damage
	
	if enemy_current_hp <= 0:
		$background/Enemy.play("death")
		$Panel/Label.text = "Victory! The enemy fainted!"
		
		await get_tree().create_timer(1.0).timeout 
		win_battle()
	else:
		$background/Enemy.play("hurt")
		
		await get_tree().create_timer(0.6).timeout 
		
		$background/Player.play("idle")
		$background/Enemy.play("idle")
		
		$Panel/answer_button.visible = true
		$Panel/answer_button.grab_focus()

func handle_enemy_attack():
	$Panel/Label.text = "Incorrect! The enemy attacks!"
	
	$background/Enemy.play("attack")
	await get_tree().create_timer(0.5).timeout 
	
	$background/Player.play("hurt")
	await get_tree().create_timer(0.6).timeout 
	
	$background/Player.play("idle")
	$background/Enemy.play("idle")
	
	# Show current assistance tier (for debugging)
	print("Current tier: ", Settings.current_assistance_tier)
	
	# Load next question with updated assistance tier
	await get_tree().create_timer(0.5).timeout
	load_new_question()

func win_battle():
	# Show success screen (not numerical score)
	$Panel/Label.text = "SUCCESS! You defeated the enemy!"
	
	# Display performance summary
	var summary = "\n\nCorrect: %d\nIncorrect: %d" % [Settings.correct_answers_count, Settings.incorrect_answers_count]
	$Panel/Label.text += summary
	
	if current_enemy_node != null:
		current_enemy_node.queue_free()
	
	# TODO: Save progress to PHP backend here
	# save_progress_to_backend()
	
	await get_tree().create_timer(3.0).timeout
	_on_run_button_pressed()

func _on_run_button_pressed():
	get_tree().paused = false
	visible = false
	$background.visible = false
	
	# Reset performance tracking for next battle
	Settings.correct_answers_count = 0
	Settings.incorrect_answers_count = 0

# Visual effect helpers
func reset_button_highlights():
	for button in [$Panel/VBoxContainer/ChoiceA, $Panel/VBoxContainer/ChoiceB]:
		button.modulate = Color(1, 1, 1, 1)
		# Stop any existing tweens
		var tweens = button.get_tree().get_processed_tweens()
		for tween in tweens:
			if tween.is_valid():
				tween.kill()

func add_glow_effect(button):
	button.modulate = Color(1.2, 1.2, 1, 1)  # Slight brightness increase

func highlight_correct_answer(button):
	# Create pulsing highlight effect
	var tween = create_tween().set_loops()
	tween.tween_property(button, "modulate", Color(1.5, 1.5, 0.5, 1), 0.5)
	tween.tween_property(button, "modulate", Color(1.2, 1.2, 0.8, 1), 0.5)
