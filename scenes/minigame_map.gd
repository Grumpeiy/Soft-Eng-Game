extends Control

@export var answer: String = "WEATHER"
@export var min_distance: float = 25

@export var spawn_area_top: Rect2 = Rect2(199, 49, 80, 32)
@export var spawn_area_bottom: Rect2 = Rect2(199, 162, 79, 31)
@export var blank_row_area: Rect2 = Rect2(151, 89.0, 176, 80)
@export var row_center_x: float = 239.0

@export var start_index: int = 0

@onready var water_pool = $WaterPool
var sfx_congrats: AudioStreamPlayer

var placeholder_scene = preload("res://scenes/PushableAssets/PlaceholderBlock.tscn")
var indicator_scene   = preload("res://scenes/PushableAssets/IndicatorBlock.tscn")

var spawned_positions: Array = []
var words:             Array = []
var tile_size:         int   = 16
var placeholders:      Array = []

var questions:              Array = []
var current_question_index: int   = 0

# ── Quest tracking ────────────────────────────────────────────────────────────
const QUEST_ID           = 1
const COMPLETE_QUEST_URL = "http://localhost/gamified_learning/complete_quest.php" 
const SAVE_KEY           = "quest_1_completed"

var puzzle_start_time : float = 0.0

# ── Scoring thresholds ────────────────────────────────────────────────────────
# Under 3 min  → 100 (perfect)
# Under 4 min  → 80
# Under 5 min  → 70
# Under 10 min → 50
# 10 min+      → 50 (same floor)

# ─────────────────────────────────────────────────────────────────────────────
func _ready():
	$WaterPool.visible = false

	sfx_congrats        = AudioStreamPlayer.new()
	sfx_congrats.stream = load("res://Sounds/music/gloryTrumpet.mp3")
	sfx_congrats.volume_db = 0.0
	add_child(sfx_congrats)

	MenuMusic.stop_music()
	$PushableMusic.play()

	puzzle_start_time = Time.get_unix_time_from_system()

	load_questions()
	load_current_question()

# ─────────────────────────────────────────────────────────────────────────────
func _calculate_score(elapsed_sec: int) -> int:
	var elapsed_min = elapsed_sec / 60.0
	if elapsed_min < 3.0:
		return 100   # perfect
	elif elapsed_min < 4.0:
		return 80
	elif elapsed_min < 5.0:
		return 70
	else:
		return 50    # anything 5 min and above

# ─────────────────────────────────────────────────────────────────────────────
func get_valid_position(area: Rect2) -> Vector2:
	var attempts = 0
	while attempts < 50:
		var rand_x    = randf_range(area.position.x, area.position.x + area.size.x)
		var rand_y    = randf_range(area.position.y, area.position.y + area.size.y)
		var candidate = Vector2(rand_x, rand_y)
		var too_close = false
		for pos in spawned_positions:
			if candidate.distance_to(pos) < min_distance:
				too_close = true
				break
		if not too_close:
			spawned_positions.append(candidate)
			return candidate
		attempts += 1
	return Vector2(area.position.x, area.position.y)

func spawn_blocks():
	for i in range(answer.length()):
		var letter = answer[i]
		if letter == " ":
			continue
		var path  = "res://scenes/PushableLetters/Letter" + letter.to_upper() + "Pushable.tscn"
		var scene = load(path)
		if scene == null:
			print("Could not load: ", path)
			continue
		var block = scene.instantiate()
		var area  = spawn_area_top if i % 2 == 0 else spawn_area_bottom
		block.position = get_valid_position(area)
		block.set_meta("letter", letter.to_upper())
		add_child(block)
		block.add_to_group("spawned")

func generate_rows():
	var row_layouts = [{
		"indicator_y":   blank_row_area.position.y + 24,
		"placeholder_y": blank_row_area.position.y + 40
	}]
	var word    = answer
	var start_x = row_center_x - (word.length() * tile_size) / 2.0 + tile_size / 2.0
	var layout  = row_layouts[0]

	for i in range(word.length()):
		var col_x = start_x + i * tile_size
		if word[i] == " ":
			continue

		var placeholder = placeholder_scene.instantiate()
		placeholder.set_meta("expected_letter", word[i].to_upper())
		placeholder.set_meta("word_index",      0)
		placeholder.set_meta("letter_index",    i)
		placeholder.position = Vector2(col_x, layout.placeholder_y)
		add_child(placeholder)
		placeholders.append(placeholder)

		var indicator = indicator_scene.instantiate()
		indicator.position = Vector2(col_x, layout.indicator_y)
		indicator.play("idle")
		add_child(indicator)

		placeholder.set_meta("indicator", indicator)
		placeholder.add_to_group("spawned")
		indicator.add_to_group("spawned")

func load_questions():
	var file = FileAccess.open("res://dialogue/PushableMinigame/QuestionDataset.json", FileAccess.READ)
	if file == null:
		print("ERROR: Could not open dataset!")
		return
	var json   = JSON.new()
	var text   = file.get_as_text()
	file.close()
	if json.parse(text) != OK:
		print("ERROR: Could not parse JSON!")
		return
	questions = json.get_data().slice(start_index, start_index + 2)

func load_current_question():
	if current_question_index >= questions.size():
		on_minigame_complete()
		return
	var entry = questions[current_question_index]
	answer    = entry["answer"].to_upper()
	$ColorRect/QuestionLabel.text = entry["question"]
	words     = answer.split(" ") if " " in answer else [answer]

	spawned_positions.clear()
	placeholders.clear()
	for child in get_children():
		if child.is_in_group("spawned"):
			child.queue_free()
	await get_tree().process_frame
	generate_rows()
	spawn_blocks()
	await typewriter_effect($ColorRect/QuestionLabel, entry["question"])

# ─────────────────────────────────────────────────────────────────────────────
func on_minigame_complete():
	print("Minigame complete!")

	# ── Calculate score from elapsed time ─────────────────────────────────────
	var elapsed_sec = int(Time.get_unix_time_from_system() - puzzle_start_time)
	var score       = _calculate_score(elapsed_sec)
	var elapsed_min = elapsed_sec / 60.0

	print("Time: %dm %ds (%.1f min) → Score: %d/100" % [
		elapsed_sec / 60, elapsed_sec % 60, elapsed_min, score
	])

	# ── Score label shown to player ───────────────────────────────────────────
	var score_suffix = ""
	if score == 100:
		score_suffix = " — Perfect! 🌟"
	elif score == 80:
		score_suffix = " — Great job!"
	elif score == 70:
		score_suffix = " — Good work!"
	else:
		score_suffix = " — Keep practicing!"

	# Confetti + SFX
	$Confetti.emitting = true
	$Confetti.z_index  = 10
	sfx_congrats.play()
	await get_tree().create_timer(3.0).timeout
	$Confetti.emitting = false

	# Hide spawned nodes
	for child in get_children():
		if child.is_in_group("spawned"):
			child.visible = false

	$samplePlayer.position = Vector2(235.0, 23.0)
	$samplePlayer.set_process(false)
	$samplePlayer.set_physics_process(false)

	$AnimationPlayer.play("FadeInAndOut")
	await $AnimationPlayer.animation_finished

	water_pool.visible = true
	water_pool.play("spawning")

	# Show completion text with score
	var full_text = "You've rediscovered water! This will surely help your grandfather's farm and the forest from the terrible drought.\n\nScore: %d/100%s" % [score, score_suffix]
	await typewriter_effect($ColorRect/QuestionLabel, full_text)

	await get_tree().create_timer(5.0).timeout
	water_pool.stop()

	# Wait for player to press confirm OR timeout after 20s
	var timer = get_tree().create_timer(20.0)
	while timer.time_left > 0:
		if Input.is_action_just_pressed("ui_accept"):
			break
		await get_tree().process_frame

	$AnimationPlayer.play("FadeOut")
	await $AnimationPlayer.animation_finished
	PlayerData.set_save_value(SAVE_KEY, true)
	await _save_quest_to_server_safe(score, elapsed_sec)
	get_tree().change_scene_to_file("res://scenes/Well.tscn")
		
# New helper function
func _save_quest_to_server_safe(score: int, time_on_task: int) -> void:
	var lrn = PlayerData.lrn
	if lrn == "":
		push_error("minigame_map: LRN is empty, cannot save to server")
		return

	var payload = JSON.stringify({
		"lrn"             : lrn,
		"quest_id"        : QUEST_ID,
		"score"           : score,
		"time_on_task_sec": time_on_task,
		"date_started"    : PlayerData.get_save_value("active_quest_start", ""),
	})

	var http = HTTPRequest.new()
	add_child(http)  # node must be in the scene tree

	var err = http.request(COMPLETE_QUEST_URL, ["Content-Type: application/json"], HTTPClient.METHOD_POST, payload)
	if err != OK:
		push_error("HTTPRequest failed to start: %d" % err)
		http.queue_free()
		return

	# Wait for completion
	await http.request_completed
	http.queue_free()
	print("Quest 1 server save complete | score: %d" % score)

# ─────────────────────────────────────────────────────────────────────────────
func check_win():
	for placeholder in placeholders:
		if not placeholder.is_filled:
			return
	current_question_index += 1
	await get_tree().create_timer(1.0).timeout
	load_current_question()

func typewriter_effect(label: Label, full_text: String, speed: float = 0.05):
	label.text = ""
	for i in range(full_text.length()):
		label.text += full_text[i]
		await get_tree().create_timer(speed).timeout
