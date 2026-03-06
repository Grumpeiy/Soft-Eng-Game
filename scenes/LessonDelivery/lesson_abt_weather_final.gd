extends Control

@export var dialogue_file: String = "res://dialogue/LessonDelivery/WeatherPatterns.json"

@onready var teacher_sprite = $wizardTeacher
@onready var emoticon = $wizardTeacher/emoticons
@onready var visual_cues = $visualCues
@onready var yes_button = $YesBtn
@onready var no_button = $NoBtn

@onready var img_sunny = $SunnyAnimated
@onready var img_rainy = $RainyAnimated
@onready var img_cloudy = $CloudyAnimated

var thought_bubble_scene = preload("res://scenes/LessonDelivery/thoughtBubble.tscn")
var dialogue: Array = []
var current_id: int = -1
var dActive: bool = false
var type_speed: float = 0.05
var waiting_for_yor_n: bool = false
var waiting_for_image_choice: bool = false
var current_correct_answer: String = ""
var current_tween: Tween

var correct_count: int = 0
var wrong_count: int = 0

@onready var thought_bubble = $MarginContainer
@onready var anim_player = $AnimationPlayer

const IMAGE_POSITIONS = [
	Vector2(98.0, 95.0),
	Vector2(241.0, 95.0),
	Vector2(384.0, 95.0)
]

func _ready():
	yes_button.visible = false
	no_button.visible = false
	yes_button.disabled = true
	no_button.disabled = true
	
	$wizardTeacher/emoticons.visible = false
	visual_cues.visible = false
	$wizardTeacher.play("idle")
	
	for node in get_children():
		if node is Panel:
			node.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Hide and disable Y/N buttons at start

	hide_image_choices()

	if not yes_button.pressed.is_connected(_on_yes_btn_pressed):
		yes_button.pressed.connect(_on_yes_btn_pressed)
	if not no_button.pressed.is_connected(_on_no_btn_pressed):
		no_button.pressed.connect(_on_no_btn_pressed)

	load_dialogue()
	next_line()

func load_dialogue():
	if not FileAccess.file_exists(dialogue_file):
		print("ERROR: File not found: ", dialogue_file)
		return
	var file = FileAccess.open(dialogue_file, FileAccess.READ)
	var content = JSON.parse_string(file.get_as_text())
	if content == null:
		print("ERROR: Could not parse JSON!")
		return
	dialogue = content

func next_line():
	current_id += 1
	if current_id >= dialogue.size():
		on_dialogue_finished()
		return

	dActive = true
	var entry = dialogue[current_id]
	var text = entry["Text"]
	var action = entry.get("action", "")
	var trigger = entry.get("trigger", "")
	var gameplay = entry.get("gameplay", "")
	var correct = entry.get("correct", "")

	match text:
		"Welcome to the Workshop!":
			anim_player.play("lesson workshop enter")
		"My name's Gandalf":
			await play_then_continue("lesson workshop exit")
		"Look at these images carefully...":
		# Show all 3 images and shuffle their positions
			var positions = IMAGE_POSITIONS.duplicate()
			positions.shuffle()
			img_sunny.position = positions[0]
			img_rainy.position = positions[1]
			img_cloudy.position = positions[2]
			img_sunny.visible = true
			img_rainy.visible = true
			img_cloudy.visible = true
		"Great job! You are ready for today's lesson.":
			hide_image_choices()
		"Our first word... WEATHER!":
			anim_player.play("weather1")
		"Our second word... CLIMATE!":
			anim_player.play("weather2")
		"For example, the Philippines usually has a hot and rainy climate.":
			anim_player.play("climate1")
		"Another interesting fact is about Canada's climate. Canada is known for having very cold weather, especially during winter!":
			anim_player.play("climate2")
		"Do you think Hawaii's climate is cold and freezing?":
			visual_cues.visible = false
			anim_player.play("climateQuestion")
		"Hmm, that answer seems a little strange! Hawaii is famous for its beautiful beaches. Do you really think it is cold there?":
			visual_cues.visible = false
		"Great job! You're correct! Hawaii has a tropical climate, which means the weather there is warm and sunny.":
			visual_cues.visible = false
		"Our third word... SEASON!":
			anim_player.play("season1")	
		"The Philippines has two seasons — the Wet Season and the Dry Season!":
			anim_player.play("season2")	
		"Our fourth word... MONSOON!":
			anim_player.play("monsoon1")
		"Our fifth word... AIR MASS!":
			anim_player.play("airmass1")	
		"And our sixth word... FRONT!":
			anim_player.play("front1")	
		"Now let us do a quick recap of all six words!":
			anim_player.play("recap")	
		_:
			pass

	# Universal YorN handler — works for any JSON line with "trigger": "YorN"
	if trigger == "YorN":
		visual_cues.visible = true
		visual_cues.play("YorN")
		waiting_for_yor_n = true
		yes_button.visible = true
		no_button.visible = true
		yes_button.disabled = false
		no_button.disabled = false
		
		

	if gameplay == "image_choice":
		show_image_choices(correct)
		waiting_for_image_choice = true
	else:
		hide_image_choices()

	show_emoticon(action, trigger)

	var label = thought_bubble.get_node("NinePatchRect/content")
	label.text = ""

	if current_tween:
		current_tween.kill()

	current_tween = create_tween()
	current_tween.tween_method(
		func(val): label.text = text.substr(0, val),
		0, text.length(), text.length() * type_speed
	)

func show_image_choices(correct_answer: String):
	current_correct_answer = correct_answer

	var positions = IMAGE_POSITIONS.duplicate()
	positions.shuffle()

	img_sunny.position = positions[0]
	img_rainy.position = positions[1]
	img_cloudy.position = positions[2]

	img_sunny.visible = true
	img_rainy.visible = true
	img_cloudy.visible = true

func hide_image_choices():
	img_sunny.visible = false
	img_rainy.visible = false
	img_cloudy.visible = false
	waiting_for_image_choice = false
	

func requestion():
	current_id -= 3  # image_choice -> correct feedback -> wrong feedback = 3 lines back
	next_line()

func play_then_continue(anim_name: String):
	anim_player.play(anim_name)
	await anim_player.animation_finished
	anim_player.play("lesson workshop min")

func _hide_yor_n_buttons():
	yes_button.visible = false
	no_button.visible = false
	yes_button.disabled = true
	no_button.disabled = true
	visual_cues.visible = false
	waiting_for_yor_n = false

func show_emoticon(action: String, trigger: String = ""):
	match action:
		"approve1":
			emoticon.visible = true
			emoticon.play("approve1")
		"book":
			emoticon.visible = true
			emoticon.play("book")
		"idea":
			emoticon.visible = true
			emoticon.play("idea")
		"talk":
			emoticon.visible = true
			emoticon.play("talk")
		"wait":
			emoticon.visible = true
			emoticon.play("wait")
		"appreciate":
			emoticon.visible = true
			emoticon.play("appreciate")
		"excited":
			emoticon.visible = true
			emoticon.play("excited")
		"sorry":
			emoticon.visible = true
			emoticon.play("sorry")
		"happy":
			emoticon.visible = true
			emoticon.play("happy")
		"afk":
			emoticon.visible = false
		"idle":
			emoticon.visible = true
			emoticon.play("idle1")
		"idle2":
			emoticon.visible = true
			emoticon.play("idle2")
		"weather":
			emoticon.visible = true
			emoticon.play("weather")
		"attention":
			emoticon.visible = true
			emoticon.play("attention")
		"cold":
			emoticon.visible = true
			emoticon.play("cold")
		"menacing":
			emoticon.visible = true
			emoticon.play("menacing")
		"question":
			emoticon.visible = true
			emoticon.play("question")
		"music":
			emoticon.visible = true
			emoticon.play("music")
		"monsoon":
			emoticon.visible = true
			emoticon.play("monsoon")
	if action != "afk":
		var frames = emoticon.sprite_frames
		if frames and not frames.get_animation_loop(action):
			emoticon.animation_finished.connect(func():
				emoticon.visible = false
			, CONNECT_ONE_SHOT)

func _input(event):
	if not dActive:
		return
	if waiting_for_yor_n:
		return

	if waiting_for_image_choice:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var click_pos = event.position
			for img in [img_sunny, img_rainy, img_cloudy]:
				if img.visible and _is_click_on_sprite(click_pos, img):
					var answer = ""
					if img == img_sunny:
						answer = "sunny"
					elif img == img_rainy:
						answer = "rainy"
					elif img == img_cloudy:
						answer = "cloudy"
					_handle_image_answer(answer)
					break
		return

	if event.is_action_pressed("ui_accept"):
		if current_tween and current_tween.is_running():
			current_tween.kill()
			var text = dialogue[current_id]["Text"]
			thought_bubble.get_node("NinePatchRect/content").text = text
			return

		var current_text = dialogue[current_id]["Text"]
		var current_trigger = dialogue[current_id].get("trigger", "")
		
		if current_text == "Hmm, that answer seems a little strange! Hawaii is famous for its beautiful beaches. Do you really think it is cold there?":
			current_id -= 1  # step back to question
			next_line()
			return
		
		if current_trigger == "wrong":
			# ✅ Wrong feedback done — re-ask same question, reshuffle
			requestion()
			return
		elif current_trigger == "correct":
			# ✅ Correct feedback done — skip wrong line, continue
			current_id += 1  # skip the wrong feedback line
			next_line()
			return

		next_line()

func _is_click_on_sprite(click_pos: Vector2, sprite: AnimatedSprite2D) -> bool:
	var sprite_rect = Rect2(
		sprite.global_position - sprite.offset,
		Vector2(
			sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame).get_width() * sprite.scale.x,
			sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame).get_height() * sprite.scale.y
		)
	)
	return sprite_rect.has_point(click_pos)

func _handle_image_answer(answer: String):
	waiting_for_image_choice = false

	if answer == current_correct_answer:
		correct_count += 1
		print("Score — Correct: ", correct_count, " Wrong: ", wrong_count)
		# ✅ Skip the wrong feedback line, only play correct
		# current_id is on the image_choice line
		# next line = correct feedback, line after = wrong feedback (skip it)
		current_id += 1  # jump to correct feedback line
		_play_feedback_then_continue()
	else:
		wrong_count += 1
		print("Score — Correct: ", correct_count, " Wrong: ", wrong_count)
		# ✅ Skip the correct feedback line, only play wrong
		current_id += 2  # jump over correct feedback to wrong feedback line
		_play_feedback_then_continue()
		
func _play_feedback_then_continue():
	dActive = true
	var entry = dialogue[current_id]
	var text = entry["Text"]
	var action = entry.get("action", "")
	var trigger = entry.get("trigger", "")

	show_emoticon(action, trigger)

	var label = thought_bubble.get_node("NinePatchRect/content")
	label.text = ""

	if current_tween:
		current_tween.kill()

	current_tween = create_tween()
	current_tween.tween_method(
		func(val): label.text = text.substr(0, val),
		0, text.length(), text.length() * type_speed
	)

func on_dialogue_finished():
	dActive = false
	thought_bubble.visible = false
	visual_cues.visible = false
	hide_image_choices()
	_hide_yor_n_buttons()
	print("Lesson finished! Correct: ", correct_count, " Wrong: ", wrong_count)
	
	# ✅ Play fade in animation
	anim_player.play("fadein")
	await anim_player.animation_finished
	get_tree().change_scene_to_file("res://scenes/Well.tscn")

func _on_yes_btn_pressed() -> void:
	print("YES BUTTON PRESSED")
	if not waiting_for_yor_n:
		return
	_hide_yor_n_buttons()
	
	var current_text = dialogue[current_id]["Text"]
	match current_text:
		"Do you think Hawaii's climate is cold and freezing?":
			# Yes is WRONG — advance to wrong feedback
			next_line()
		"Hmm, that answer seems a little strange! Hawaii is famous for its beautiful beaches. Do you really think it is cold there?":
			current_id -= 1
			next_line()
		_:
			# Default Yes behaviour — advance normally
			next_line()

func _on_no_btn_pressed() -> void:
	print("NO BUTTON PRESSED")
	if not waiting_for_yor_n:
		return
	_hide_yor_n_buttons()
		
	var current_text = dialogue[current_id]["Text"]
	match current_text:
		"Are you ready?", "We will learn six important words today. Are you ready?":
			# Step forward to the "not ready" response instead of back
			next_line()
		"Do you think Hawaii's climate is cold and freezing?":
			# No is CORRECT — advance to correct feedback
			current_id += 2
			next_line()
		"Hmm, that answer seems a little strange! Hawaii is famous for its beautiful beaches. Do you really think it is cold there?":
			current_id += 1
			next_line()
		_:	
			current_id -= 1
			next_line()
