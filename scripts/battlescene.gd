extends Control

# ── Config ────────────────────────────────────────────────────────────────────
const BASE_URL           = "http://localhost/gamified_learning/"
const SAVE_PERF_URL      = BASE_URL + "save_performance.php"
const COMPLETE_QUEST_URL = BASE_URL + "complete_quest.php"

# ── Enemy / battle state ──────────────────────────────────────────────────────
var enemy_max_hp       = 100
var enemy_current_hp   = 100
var player_damage      = 35
var current_enemy_node = null

# ── Quest / player context ────────────────────────────────────────────────────
var current_quest_id  : int    = -1
var current_lrn       : String = ""
# enemy_number: 1 = Skeleton 1 (easy questions)
#               2 = Skeleton 2 (normal questions)
#               3 = Skeleton 3 (hard questions)
# Choices shown are controlled by Settings.difficulty_level, NOT enemy_number.
var enemy_number      : int    = 1

# ── Idle / assistance ─────────────────────────────────────────────────────────
var idle_timer                  = 0.0
var idle_threshold              = 30.0
var is_waiting_for_answer       = false
var has_triggered_mid_from_idle = false

# ── Question state ────────────────────────────────────────────────────────────
var current_question         = {}
var current_question_options = []
var filtered_options         = []
var correct_answer_index     = -1

# ── Local question pool ───────────────────────────────────────────────────────
var available_questions = []
var used_questions      = []

# ── Performance tracking ──────────────────────────────────────────────────────
var battle_start_time        : float = 0.0
var question_start_time      : float = 0.0
var total_time_on_task       : int   = 0
var total_score              : int   = 0
var correct_first_try        : int   = 0
var assisted_answers         : int   = 0
var _current_q_was_assisted  : bool  = false

var active_tween = null

# ─────────────────────────────────────────────────────────────────────────────
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
		if idle_timer >= idle_threshold \
		   and Settings.current_assistance_tier == Settings.AssistanceTier.LOW \
		   and not has_triggered_mid_from_idle:
			print("30s idle -> escalating to Mid Assistance")
			Settings.current_assistance_tier = Settings.AssistanceTier.MID
			has_triggered_mid_from_idle = true
			_current_q_was_assisted = true
			apply_mid_assistance()

# ─────────────────────────────────────────────────────────────────────────────
# INIT
# ─────────────────────────────────────────────────────────────────────────────
func init(enemy_node, character_name, lvl, quest_id: int = -1, lrn: String = "", enemy_num: int = 1):
	$"../../Battle".play()
	visible = true
	$AnimationPlayer.play("fade_in")
	get_tree().paused = true

	current_enemy_node = enemy_node
	enemy_current_hp   = enemy_max_hp
	current_quest_id   = quest_id if quest_id != -1 else PlayerData.character_data.get("active_quest_id", -1)
	current_lrn        = lrn     if lrn != ""      else PlayerData.lrn
	enemy_number       = enemy_num

	$Panel/Label.text = "A wild %s lvl %s appears!" % [character_name, lvl]
	$Panel/VBoxContainer.visible = false
	$Panel/answer_button.visible = true

	Settings.reset_assistance_tier()

	battle_start_time       = Time.get_unix_time_from_system()
	total_time_on_task      = 0
	total_score             = 0
	correct_first_try       = 0
	assisted_answers        = 0
	_current_q_was_assisted = false
	used_questions.clear()

	# Questions chosen by enemy number (1=easy, 2=normal, 3=hard)
	# Choices shown are chosen by Settings.difficulty_level
	var difficulty_map  = {1: "easy", 2: "normal", 3: "hard"}
	var question_pool   = difficulty_map.get(enemy_number, "normal")
	available_questions = Questions.questions[question_pool].duplicate()

	print("=== BATTLE INIT ===")
	print("  enemy        : ", character_name, " lv", lvl, " (enemy #", enemy_number, ")")
	print("  question pool: ", question_pool, " (", available_questions.size(), " questions)")
	print("  choices shown: ", get_num_choices_for_difficulty(), " (difficulty setting: ", Settings.difficulty_level, ")")
	print("  quest_id     : ", current_quest_id)
	print("  lrn          : ", current_lrn)

# ─────────────────────────────────────────────────────────────────────────────
# ANIMATION
# ─────────────────────────────────────────────────────────────────────────────
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

# ─────────────────────────────────────────────────────────────────────────────
# QUESTION POOL
# ─────────────────────────────────────────────────────────────────────────────
func get_next_question() -> Dictionary:
	if available_questions.is_empty():
		return {}
	if enemy_number == 3:
		var unused = available_questions.filter(func(q): return q not in used_questions)
		if unused.is_empty():
			used_questions.clear()
			unused = available_questions
		var selected = unused.pick_random()
		used_questions.append(selected)
		return selected
	return available_questions.pick_random()

func load_new_question():
	current_question = get_next_question()
	if current_question.is_empty():
		return

	current_question_options    = current_question["options"].duplicate()
	idle_timer                  = 0.0
	is_waiting_for_answer       = true
	has_triggered_mid_from_idle = false
	_current_q_was_assisted     = false
	question_start_time         = Time.get_unix_time_from_system()

	stop_visual_effects()
	apply_assistance_tier()

	$Panel/answer_button.visible = false
	$Panel/VBoxContainer.visible = true
	$Panel/VBoxContainer/ChoiceA.grab_focus()

# ─────────────────────────────────────────────────────────────────────────────
# HOW MANY CHOICES — driven by Settings.difficulty_level
# Easy = 2 choices  |  Normal = 3 choices  |  Hard = 4 choices
# This is independent of which skeleton the player is fighting.
# ─────────────────────────────────────────────────────────────────────────────
func get_num_choices_for_difficulty() -> int:
	match Settings.difficulty_level:
		"easy":   return 2
		"normal": return 3
		"hard":   return 4
	return 4

# ─────────────────────────────────────────────────────────────────────────────
# ASSISTANCE TIERS
# ─────────────────────────────────────────────────────────────────────────────
func apply_assistance_tier():
	if not Settings.guided_mode_enabled:
		apply_no_assistance()
	else:
		match Settings.current_assistance_tier:
			Settings.AssistanceTier.LOW:  apply_low_assistance()
			Settings.AssistanceTier.MID:  apply_mid_assistance()
			Settings.AssistanceTier.HIGH: apply_high_assistance()
			
func shuffle_options_and_track_correct():
	var correct_answer = current_question_options[current_question["correct"]]
	var incorrect_options = []

	for i in range(current_question_options.size()):
		if i != current_question["correct"]:
			incorrect_options.append(current_question_options[i])
			
	var num_choices = get_num_choices_for_difficulty()
	filtered_options = [correct_answer]
			
	incorrect_options.shuffle()
	for i in range(min(num_choices - 1, incorrect_options.size())):
		filtered_options.append(incorrect_options[i])
		filtered_options.shuffle()
		correct_answer_index = filtered_options.find(correct_answer)

func apply_no_assistance():
	$Panel/Label.text = current_question["text"]
	$background.modulate = Color(1, 1, 1, 1)
	shuffle_options_and_track_correct()
	display_choices(get_num_choices_for_difficulty())
	reset_button_colors()

func apply_low_assistance():
	apply_no_assistance()

func apply_mid_assistance():
	_current_q_was_assisted = true
	var hint_text = current_question.get("hint", "Think carefully!")
	$Panel/Label.text = current_question["text"] + "\n\nHint: " + hint_text
	$background.modulate = Color(0.8, 0.8, 0.8, 1)

	var correct_answer = current_question_options[current_question["correct"]]
	var incorrect_options = []
	for i in range(current_question_options.size()):
		if i != current_question["correct"]:
			incorrect_options.append(current_question_options[i])
			
		if incorrect_options.is_empty():
			filtered_options = [correct_answer]
		else:
			filtered_options = [correct_answer, incorrect_options.pick_random()]

	filtered_options.shuffle()
	correct_answer_index = filtered_options.find(correct_answer)

	display_choices(filtered_options.size())  # Use actual number of options
	reset_button_colors()
	add_glow_effect($Panel/VBoxContainer/ChoiceA)
	add_glow_effect($Panel/VBoxContainer/ChoiceB)

func apply_high_assistance():
	_current_q_was_assisted = true
	$Panel/Label.text = current_question["text"] + "\n\nThe correct answer is highlighted!"
	$background.modulate = Color(0.5, 0.5, 0.5, 1)

	var correct_answer   = current_question_options[current_question["correct"]]
	filtered_options     = [correct_answer]
	correct_answer_index = 0

	$Panel/VBoxContainer/ChoiceA.text    = correct_answer
	$Panel/VBoxContainer/ChoiceA.visible = true
	$Panel/VBoxContainer/ChoiceB.visible = false
	if $Panel/VBoxContainer.has_node("ChoiceC"):
		$Panel/VBoxContainer/ChoiceC.visible = false
	if $Panel/VBoxContainer.has_node("ChoiceD"):
		$Panel/VBoxContainer/ChoiceD.visible = false

	reset_button_colors()
	highlight_correct_answer($Panel/VBoxContainer/ChoiceA)

func display_choices(num_choices: int):
	var names = ["ChoiceA", "ChoiceB", "ChoiceC", "ChoiceD"]
	for i in range(names.size()):
		if not $Panel/VBoxContainer.has_node(names[i]):
			continue
		var btn = $Panel/VBoxContainer.get_node(names[i])
		if i < num_choices and i < filtered_options.size():
			btn.text    = filtered_options[i]
			btn.visible = true
		else:
			btn.visible = false

# ─────────────────────────────────────────────────────────────────────────────
# ANSWER CHECKING
# ─────────────────────────────────────────────────────────────────────────────
func check_answer(selected_index):
	is_waiting_for_answer = false
	$Panel/VBoxContainer.visible = false

	if selected_index >= filtered_options.size():
		return
	
	var chosen_text  = filtered_options[selected_index]
	var correct_text = current_question_options[current_question["correct"]]
	var is_correct   = (chosen_text == correct_text)  # <- compare text, not index
	var score_earned = current_question.get("reward_points", 0) if is_correct else 0

	if is_correct:
		total_score += score_earned
		if _current_q_was_assisted:
			assisted_answers += 1
		else:
			correct_first_try += 1
		Settings.record_correct_answer()
		handle_player_attack()
	else:
		_current_q_was_assisted = true
		Settings.record_incorrect_answer()
		handle_enemy_attack()

# ─────────────────────────────────────────────────────────────────────────────
# COMBAT
# ─────────────────────────────────────────────────────────────────────────────
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

# ─────────────────────────────────────────────────────────────────────────────
# WIN
# ─────────────────────────────────────────────────────────────────────────────
func win_battle():
	$Panel/Label.text = "Victory!\n\nScore: %d pts\nFirst Try: %d  |  Assisted: %d" % [
		total_score, correct_first_try, assisted_answers
	]
 
	if current_enemy_node != null:
		current_enemy_node.queue_free()
 
	# Mark this skeleton as defeated so it won't respawn
	PlayerData.mark_enemy_defeated("skeleton_%d" % enemy_number)  # <- ADD THIS
 
	if current_lrn != "" and current_quest_id != -1:
		_complete_battle_on_server()
 
	await get_tree().create_timer(5.0).timeout
	$"../../Battle".stop()
	_on_run_button_pressed()

# ─────────────────────────────────────────────────────────────────────────────
# HTTP
# ─────────────────────────────────────────────────────────────────────────────
func _complete_battle_on_server():
	var q_elapsed = int(Time.get_unix_time_from_system() - battle_start_time)

	var payload = JSON.stringify({
		"lrn"               : current_lrn,
		"quest_id"          : current_quest_id,
		"enemy_number"      : enemy_number,
		"score"             : total_score,
		"correct_first_try" : correct_first_try,
		"assisted_answers"  : assisted_answers,
		"time_on_task_sec"  : q_elapsed,
	})

	print("Sending to complete_quest.php: ", payload)

	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(res, code, h, body):
		var response_text = body.get_string_from_utf8()
		print("complete_quest response (", code, "): ", response_text)
		if code == 200:
			var json = JSON.new()
			if json.parse(response_text) == OK:
				var data = json.get_data()
				if data.get("success", false):
					print("Skeleton %d saved | score:%d | all_beaten:%s" % [
						enemy_number, total_score, str(data.get("all_beaten"))
					])
					if data.get("badge_awarded") != null:
						_show_badge_popup(data["badge_awarded"])
				else:
					push_error("complete_quest error: " + str(data.get("error", "")))
		http.queue_free()
	)
	var err = http.request(COMPLETE_QUEST_URL, ["Content-Type: application/json"], HTTPClient.METHOD_POST, payload)
	if err != OK:
		print("HTTPRequest error: ", err)

func _show_badge_popup(badge: Dictionary):
	var popup = AcceptDialog.new()
	popup.title = "Badge Earned!"
	popup.dialog_text = "%s\n\n%s" % [
		badge.get("name", ""),
		badge.get("description", "")
	]
	add_child(popup)
	popup.popup_centered()

# ─────────────────────────────────────────────────────────────────────────────
# EXIT
# ─────────────────────────────────────────────────────────────────────────────
func _on_run_button_pressed():
	get_tree().paused = false
	visible = false
	$background.visible = false

	Settings.correct_answers_count   = 0
	Settings.incorrect_answers_count = 0

	used_questions.clear()
	available_questions.clear()
	total_score        = 0
	correct_first_try  = 0
	assisted_answers   = 0
	total_time_on_task = 0

# ─────────────────────────────────────────────────────────────────────────────
# VISUAL EFFECTS
# ─────────────────────────────────────────────────────────────────────────────
func stop_visual_effects():
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	active_tween = null
	reset_button_colors()
	$background.modulate = Color(1, 1, 1, 1)

func reset_button_colors():
	for n in ["ChoiceA", "ChoiceB", "ChoiceC", "ChoiceD"]:
		if $Panel/VBoxContainer.has_node(n):
			$Panel/VBoxContainer.get_node(n).modulate = Color(1, 1, 1, 1)

func add_glow_effect(button):
	button.modulate = Color(1.2, 1.2, 1, 1)

func highlight_correct_answer(button):
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	active_tween = create_tween().set_loops()
	active_tween.tween_property(button, "modulate", Color(1.5, 1.5, 0.5, 1), 0.5)
	active_tween.tween_property(button, "modulate", Color(1.2, 1.2, 0.8, 1), 0.5)
