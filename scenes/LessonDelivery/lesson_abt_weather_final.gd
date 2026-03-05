extends Control

@export var dialogue_file: String = "res://dialogue/LessonDelivery/WeatherPatterns.json"
@onready var teacher_sprite = $wizardTeacher
@onready var emoticon = $wizardTeacher/emoticons


var thought_bubble_scene = preload("res://scenes/LessonDelivery/thoughtBubble.tscn")
var dialogue: Array = []
var current_id: int = -1
var dActive: bool = false
var type_speed: float = 0.05
var current_tween: Tween

@onready var thought_bubble = $MarginContainer # adjust to your node path
@onready var anim_player = $AnimationPlayer
func _ready():
	$wizardTeacher/emoticons.visible = false
	$wizardTeacher.play("idle")
	
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
	var text = entry['Text']

	# trigger emoticon and sprite animation
	if entry.has("action"):
		show_emoticon(entry["action"])
	match text:
		"Welcome to the Workshop!":
			anim_player.play("lesson workshop enter")
		"My name's Gandalf":
			await play_then_continue("lesson workshop exit")
		_:
			pass  # no animation change for other lines
	var label = thought_bubble.get_node("NinePatchRect/content")
	label.text = ""
	
	if current_tween:
		current_tween.kill()
	
	current_tween = create_tween()
	current_tween.tween_method(
		func(val):
			label.text = text.substr(0, val),
	0, text.length(), text.length() * type_speed
	)

func play_then_continue(anim_name: String):
	anim_player.play(anim_name)
	await anim_player.animation_finished
	anim_player.play("lesson workshop min")
	
func show_emoticon(action: String):
	# map action to emoticon animation
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
		"talk":
			emoticon.visible = true
			emoticon.play("talk")
		"appreciate":
			emoticon.visible = true
			emoticon.play("appreciate")
		"excited":
			emoticon.visible = true
			emoticon.play("excited")
		"sorry":
			emoticon.visible = true
			emoticon.play("sorry")
		"afk":
			emoticon.visible = false
		"idle":
			emoticon.visible = true
			var idles = ["idle1", "idle2"]
			emoticon.play(idles[randi() % idles.size()])
	if action != "afk":
		await emoticon.animation_finished
		emoticon.visible = false
		
func _input(event):
	if not dActive:
		return
	if event.is_action_pressed("ui_accept"):
		# skip typewriter if still playing
		if current_tween and current_tween.is_running():
			current_tween.kill()
			var text = dialogue[current_id]['Text']
			thought_bubble.get_node("NinePatchRect/content").text = text
			return
		# advance to next line
		next_line()

func on_dialogue_finished():
	dActive = false
	thought_bubble.visible = false
	print("Lesson dialogue finished!")
