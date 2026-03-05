extends Control

var enemy_max_hp = 100
var enemy_current_hp = 100
var player_damage = 35 
var current_enemy_node = null

var idle_timer = 0.0
var idle_threshold = 30.0
var is_waiting_for_answer = false
var has_triggered_mid_from_idle = false

var current_question = {}
var current_question_options = []
var filtered_options = []
var correct_answer_index = -1

var active_tween = null

var used_questions = []
var available_questions = []

func _ready():
	visible = false
	$background.visible = false
	
	$Panel/VBoxContainer/ChoiceA.pressed.connect(func(): check_answer(0))
	$Panel/VBoxContainer/ChoiceB.pressed.connect(func(): check_answer(1))
	
	if $Panel/VBoxContainer.has_node("ChoiceC"):
		$Panel/VBoxContainer/ChoiceC.pressed.connect(func(): check_answer(2))
	if $Panel/VBoxContainer.has_node("ChoiceD"):
		$Panel/VBoxContainer/ChoiceD.pressed.connect(func(): check_answer(3))
	
	event_handler.battle_started.connect(Callable(self, "init"))

func _process(delta):
	if is_waiting_for_answer and Settings.guided_mode_enabled:
		idle_timer += delta
		
		if idle_timer >= idle_threshold and Settings.current_assistance_tier == Settings.AssistanceTier.LOW and not has_triggered_mid_from_idle:
			print("30 seconds idle - triggering Mid Assistance")
			Settings.current_assistance_tier = Settings.AssistanceTier.MID
			has_triggered_mid_from_idle = true
			
			apply_mid_assistance()

func init(enemy_node, character_name, lvl):
	$"../../Battle".play()
	visible = true
	$AnimationPlayer.play("fade_in")
	get_tree().paused = true
	
	current_enemy_node = enemy_node 
	enemy_current_hp = enemy_max_hp
	$Panel/Label.text = "A wild %s lvl %s appears!" % [character_name, lvl]
	
	$Panel/VBoxContainer.visible = false
	$Panel/answer_button.visible = true
	
	Settings.reset_assistance_tier()
	
	initialize_question_pool()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_in":
		$AnimationPlayer.play("fade_out")
		$background.visible = true
		$background/Player.play("idle")
		$background/Enemy.play("idle")
		$background/Enemy.flip_h = true
		
		$Panel/answer_button.grab_focus()

func _on_answer_button_pressed():
	Audio.play_click()
	load_new_question()

func initialize_question_pool():
	used_questions.clear()
	available_questions = Questions.get_questions_for_difficulty().duplicate()
	print("Initialized question pool with %d questions (Difficulty: %s)" % [available_questions.size(), Settings.difficulty_level])

func get_next_question() -> Dictionary:
	match Settings.difficulty_level:
		"easy":
			if available_questions.size() > 0:
				return available_questions.pick_random()
			else:
				print("No questions available!")
				return {}
		
		"normal":
			if available_questions.size() > 0:
				return available_questions.pick_random()
			else:
				print("No questions available!")
				return {}
		
		"hard":
			var unused_questions = []
			for question in available_questions:
				if not question in used_questions:
					unused_questions.append(question)
			
			if unused_questions.size() > 0:
				var selected_question = unused_questions.pick_random()
				used_questions.append(selected_question)
				print("Hard mode: %d/%d questions used" % [used_questions.size(), available_questions.size()])
				return selected_question
			else:
				print("Hard mode: All questions used, resetting pool")
				used_questions.clear()
				if available_questions.size() > 0:
					var selected_question = available_questions.pick_random()
					used_questions.append(selected_question)
					return selected_question
				else:
					print("No questions available!")
					return {}
	
	return {}

func load_new_question():
	current_question = get_next_question()
	
	if current_question.is_empty():
		print("No questions available!")
		return
	
	current_question_options = current_question["options"].duplicate()
	
	idle_timer = 0.0
	is_waiting_for_answer = true
	has_triggered_mid_from_idle = false
	
	stop_visual_effects()
	
	apply_assistance_tier()
	
	$Panel/answer_button.visible = false
	$Panel/VBoxContainer.visible = true
	$Panel/VBoxContainer/ChoiceA.grab_focus()

func apply_assistance_tier():
	if not Settings.guided_mode_enabled:
		apply_no_assistance()
	else:
		match Settings.current_assistance_tier:
			Settings.AssistanceTier.LOW:
				apply_low_assistance()
			Settings.AssistanceTier.MID:
				apply_mid_assistance()
			Settings.AssistanceTier.HIGH:
				apply_high_assistance()

func shuffle_options_and_track_correct():
	var correct_answer = current_question_options[current_question["correct"]]
	
	filtered_options = current_question_options.duplicate()
	filtered_options.shuffle()
	
	correct_answer_index = filtered_options.find(correct_answer)

func apply_no_assistance():
	$Panel/Label.text = current_question["text"]
	$background.modulate = Color(1, 1, 1, 1)
	
	var num_choices = get_num_choices_for_difficulty()
	
	shuffle_options_and_track_correct()
	
	display_choices(num_choices)
	
	reset_button_colors()
	print("Guided Mode OFF: %d options" % num_choices)

func apply_low_assistance():
	$Panel/Label.text = current_question["text"]
	$background.modulate = Color(1, 1, 1, 1)
	
	var num_choices = get_num_choices_for_difficulty()
	
	shuffle_options_and_track_correct()
	
	display_choices(num_choices)
	
	reset_button_colors()
	print("LOW Assistance: %d options, no hints" % num_choices)

func apply_mid_assistance():
	var hint_text = current_question.get("hint", "Think carefully!")
	$Panel/Label.text = current_question["text"] + "\n\nHint: " + hint_text
	
	$background.modulate = Color(0.8, 0.8, 0.8, 1)
	
	var correct_answer = current_question_options[current_question["correct"]]
	var incorrect_options = []
	
	for i in range(current_question_options.size()):
		if i != current_question["correct"]:
			incorrect_options.append(current_question_options[i])
	
	var random_incorrect = incorrect_options.pick_random()
	
	filtered_options = [correct_answer, random_incorrect]
	filtered_options.shuffle()
	correct_answer_index = filtered_options.find(correct_answer)
	
	display_choices(2)
	
	reset_button_colors()
	
	add_glow_effect($Panel/VBoxContainer/ChoiceA)
	add_glow_effect($Panel/VBoxContainer/ChoiceB)
	
	print("MID Assistance: 2 options, hint shown")

func apply_high_assistance():
	$Panel/Label.text = current_question["text"] + "\n\nThe correct answer is highlighted!"
	
	$background.modulate = Color(0.5, 0.5, 0.5, 1)
	
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
	
	reset_button_colors()
	
	highlight_correct_answer($Panel/VBoxContainer/ChoiceA)
	
	print("HIGH Assistance: Correct answer highlighted")

func get_num_choices_for_difficulty() -> int:
	match Settings.difficulty_level:
		"easy":
			return 2
		"normal":
			return 4
		"hard":
			return 4
	return 4

func display_choices(num_choices: int):
	if num_choices >= 1:
		$Panel/VBoxContainer/ChoiceA.text = filtered_options[0]
		$Panel/VBoxContainer/ChoiceA.visible = true
	else:
		$Panel/VBoxContainer/ChoiceA.visible = false
	
	if num_choices >= 2:
		$Panel/VBoxContainer/ChoiceB.text = filtered_options[1]
		$Panel/VBoxContainer/ChoiceB.visible = true
	else:
		$Panel/VBoxContainer/ChoiceB.visible = false
	
	if $Panel/VBoxContainer.has_node("ChoiceC"):
		if num_choices >= 3 and filtered_options.size() > 2:
			$Panel/VBoxContainer/ChoiceC.text = filtered_options[2]
			$Panel/VBoxContainer/ChoiceC.visible = true
		else:
			$Panel/VBoxContainer/ChoiceC.visible = false
	
	if $Panel/VBoxContainer.has_node("ChoiceD"):
		if num_choices >= 4 and filtered_options.size() > 3:
			$Panel/VBoxContainer/ChoiceD.text = filtered_options[3]
			$Panel/VBoxContainer/ChoiceD.visible = true
		else:
			$Panel/VBoxContainer/ChoiceD.visible = false

func check_answer(selected_index):
	is_waiting_for_answer = false
	$Panel/VBoxContainer.visible = false
	
	if selected_index >= filtered_options.size():
		return
	
	if selected_index == correct_answer_index:
		print("Correct!")
		Settings.record_correct_answer()
		handle_player_attack()
	else:
		print("Incorrect. Wrong answers:", Settings.consecutive_incorrect_answers + 1)
		Settings.record_incorrect_answer()
		handle_enemy_attack()

func handle_player_attack():
	$Panel/Label.text = "Correct! You attack!"
	
	$background/Player.play("attack")
	await get_tree().create_timer(0.5).timeout 
	$"../../Swing".play()
	
	enemy_current_hp -= player_damage
	
	if enemy_current_hp <= 0:
		$"../../Death".pitch_scale = 0.9
		$"../../Death".play()
		$background/Enemy.play("death")
		$Panel/Label.text = "Victory!"
		await get_tree().create_timer(4.0).timeout 
		$"../../Battle".stop()
		$"../../Victory".play()
		win_battle()
	else:
		$background/Enemy.play("hurt")
		await get_tree().create_timer(0.3).timeout 
		$"../../Hurt".pitch_scale = 0.6
		$"../../Hurt".play()
		await get_tree().create_timer(0.6).timeout 
		$background/Player.play("idle")
		$background/Enemy.play("idle")
		$Panel/answer_button.visible = true
		$Panel/answer_button.grab_focus()

func handle_enemy_attack():
	$Panel/Label.text = "Incorrect! The enemy attacks!"
	await get_tree().create_timer(0.5).timeout
	
	$background/Enemy.play("attack")
	$"../../Swing".pitch_scale = 0.6
	await get_tree().create_timer(0.3).timeout 
	$"../../Swing".play()
	
	await get_tree().create_timer(0.5).timeout 
	$"../../Hurt".pitch_scale = 1.6
	$"../../Hurt".play()
	
	$background/Player.play("hurt")
	await get_tree().create_timer(0.6).timeout 
	$background/Player.play("idle")
	$background/Enemy.play("idle")
	
	await get_tree().create_timer(0.5).timeout
	
	apply_assistance_tier()
	
	$Panel/VBoxContainer.visible = true
	$Panel/VBoxContainer/ChoiceA.grab_focus()
	is_waiting_for_answer = true

func win_battle():
	$Panel/Label.text = "SUCCESS!\n\n Correct: %d                        Incorrect: %d" % [Settings.correct_answers_count, Settings.incorrect_answers_count]
	
	if current_enemy_node != null:
		current_enemy_node.queue_free()
	
	await get_tree().create_timer(5.0).timeout
	$"../../Battle".stop()
	_on_run_button_pressed()

func _on_run_button_pressed():
	get_tree().paused = false
	visible = false
	$background.visible = false
	Settings.correct_answers_count = 0
	Settings.incorrect_answers_count = 0

	used_questions.clear()
	available_questions.clear()

func stop_visual_effects():
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	active_tween = null
	
	reset_button_colors()
	$background.modulate = Color(1, 1, 1, 1)

func reset_button_colors():
	var buttons = [$Panel/VBoxContainer/ChoiceA, $Panel/VBoxContainer/ChoiceB]
	
	if $Panel/VBoxContainer.has_node("ChoiceC"):
		buttons.append($Panel/VBoxContainer/ChoiceC)
	if $Panel/VBoxContainer.has_node("ChoiceD"):
		buttons.append($Panel/VBoxContainer/ChoiceD)
	
	for button in buttons:
		button.modulate = Color(1, 1, 1, 1)

func add_glow_effect(button):
	button.modulate = Color(1.2, 1.2, 1, 1)

func highlight_correct_answer(button):
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	
	active_tween = create_tween().set_loops()
	active_tween.tween_property(button, "modulate", Color(1.5, 1.5, 0.5, 1), 0.5)
	active_tween.tween_property(button, "modulate", Color(1.2, 1.2, 0.8, 1), 0.5)

# In your gameplay script (e.g., Well.gd or wherever you handle quest completion)

func save_progress():
	var save_data = PlayerData.save_file_data
	
	# Update progress
	save_data["last_played"] = Time.get_datetime_string_from_system()
	# Update other progress data as needed
	
	PlayerData.save_game_data(save_data)
