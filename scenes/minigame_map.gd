extends Control

@export var answer: String = "WEATHER"
@export var min_distance: float = 25 # adjust based on your block size

@export var spawn_area_top: Rect2 = Rect2(199, 49, 80, 32)
@export var spawn_area_bottom: Rect2 = Rect2(199, 162, 79, 31)
@export var blank_row_area: Rect2 = Rect2(151, 89.0, 176, 80)
@export var row_center_x: float = 239.0

@export var start_index: int = 0

var placeholder_scene = preload("res://scenes/PushableAssets/PlaceholderBlock.tscn")
var indicator_scene = preload("res://scenes/PushableAssets/IndicatorBlock.tscn")

var spawned_positions: Array = []
var words: Array = []
var tile_size: int = 16
var placeholders: Array = []  # stores all placeholder blocks for win detection later

var questions: Array = []
var current_question_index: int = 0

func _ready():
	MenuMusic.stop_music()
	$PushableMusic.play()
	$AnimationPlayer.play("FadeOut")
	load_questions()
	load_current_question()

func get_valid_position(area: Rect2) -> Vector2:
	var attempts = 0
	while attempts < 50:
		var rand_x = randf_range(area.position.x, area.position.x + area.size.x)
		var rand_y = randf_range(area.position.y, area.position.y + area.size.y)
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
	
	# fallback if no valid spot found after 50 attempts
	return Vector2(area.position.x, area.position.y)

func spawn_blocks():
	for i in range(answer.length()):
		var letter = answer[i]
		if letter == " ":
			continue
		var path = "res://scenes/PushableLetters/Letter" + letter.to_upper() + "Pushable.tscn"
		var scene = load(path)
		if scene == null:
			print("Could not load: ", path)
			continue
		var block = scene.instantiate()
		var area = spawn_area_top if i % 2 == 0 else spawn_area_bottom
		block.position = get_valid_position(area)
		block.set_meta("letter", letter.to_upper())
		add_child(block)
		
		block.add_to_group("spawned")
		
func generate_rows():
	var row_layouts = []
	# now treat the whole answer as one row, spaces become gaps
	row_layouts = [
		{
			"indicator_y": blank_row_area.position.y + 24,
			"placeholder_y": blank_row_area.position.y + 40
		}
	]

	var word = answer  # use full answer including space
	var start_x = row_center_x - (word.length() * tile_size) / 2.0 + tile_size / 2.0
	var layout = row_layouts[0]

	for i in range(word.length()):
		var col_x = start_x + i * tile_size

		# skip spawning if its a space
		if word[i] == " ":
			continue

		var placeholder = placeholder_scene.instantiate()
		placeholder.set_meta("expected_letter", word[i].to_upper())
		placeholder.set_meta("word_index", 0)
		placeholder.set_meta("letter_index", i)
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
	var json = JSON.new()
	var text = file.get_as_text()
	file.close()
	var result = json.parse(text)
	if result != OK:
		print("ERROR: Could not parse JSON!")
		return
	var data = json.get_data()
	# grab only the 2 questions starting from start_index
	questions = data.slice(start_index, start_index + 2)

func load_current_question():
	if current_question_index >= questions.size():
		on_minigame_complete()
		return
	var entry = questions[current_question_index]
	answer = entry["answer"].to_upper()
	$ColorRect/QuestionLabel.text = entry["question"]
	words = answer.split(" ") if " " in answer else [answer]
	# clear previous state
	spawned_positions.clear()
	placeholders.clear()
	for child in get_children():
		if child.is_in_group("spawned"):
			child.queue_free()
	await get_tree().process_frame
	generate_rows()
	spawn_blocks()
	
	await typewriter_effect($ColorRect/QuestionLabel, entry["question"])
func on_minigame_complete():
	print("Minigame complete!")
	$AnimationPlayer.play("WaterDiscovery")
	
	await get_tree().create_timer(2.0).timeout
	for child in get_children():
		if child.is_in_group("spawned"):
			child.visible = false
	#change $samplePlayer to whichever playernode to be used
	$samplePlayer.position = Vector2(235.0, 23.0)
	$samplePlayer.set_process(false)
	$samplePlayer.set_physics_process(false)
	
	await get_tree().create_timer(2.0).timeout
	var full_text: String = "You've rediscovered water! This will surely help your grandfather's farm and the forest from the terrible drought."
	await typewriter_effect($ColorRect/QuestionLabel, full_text)
	
func check_win():
	for placeholder in placeholders:
		if not placeholder.is_filled:
			return
	# all filled correctly
	current_question_index += 1
	await get_tree().create_timer(1.0).timeout  # brief pause before next question
	load_current_question()

func typewriter_effect(label: Label, full_text: String, speed: float = 0.05):
	label.text = ""
	for i in range(full_text.length()):
		label.text += full_text[i]
		await get_tree().create_timer(speed).timeout
