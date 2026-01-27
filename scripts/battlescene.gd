extends Control

var enemy_max_hp = 100
var enemy_current_hp = 100
var player_damage = 35 
var current_enemy_node = null

var questions = [
	{
		"text": "How many seasons does the Philippines have?",
		"options": ["Two (Wet & Dry)", "Four (Spring, Summer, Fall, Winter)"],
		"correct": 0
	},
	{
		"text": "Which season usually brings heavy rains?",
		"options": ["Dry Season", "Wet Season"],
		"correct": 1
	},
	{
		"text": "Which month is typically the hottest in the Philippines?",
		"options": ["May", "December"],
		"correct": 0
	}
]
var current_question = {}

func _ready():
	visible = false
	$background.visible = false
	
	$Panel/VBoxContainer/ChoiceA.pressed.connect(func(): check_answer(0))
	$Panel/VBoxContainer/ChoiceB.pressed.connect(func(): check_answer(1))
	
	event_handler.battle_started.connect(Callable(self, "init"))

func init(enemy_node, character_name, lvl):
	visible = true
	$AnimationPlayer.play("fade_in")
	get_tree().paused = true
	
	current_enemy_node = enemy_node 
	
	enemy_current_hp = enemy_max_hp
	$Panel/Label.text = "A wild %s lvl %s appears!" % [character_name, lvl]
	
	$Panel/VBoxContainer.visible = false
	$Panel/answer_button.visible = true

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
	
	$Panel/Label.text = current_question["text"]
	$Panel/VBoxContainer/ChoiceA.text = current_question["options"][0]
	$Panel/VBoxContainer/ChoiceB.text = current_question["options"][1]
	
	$Panel/answer_button.visible = false
	$Panel/VBoxContainer.visible = true
	$Panel/VBoxContainer/ChoiceA.grab_focus()

func check_answer(selected_index):
	$Panel/VBoxContainer.visible = false
	
	if selected_index == current_question["correct"]:
		handle_player_attack()
	else:
		handle_enemy_attack()

func handle_player_attack():
	$Panel/Label.text = "Correct! You attack!"
	
	$background/Player.play("attack")
	await get_tree().create_timer(0.5).timeout 
	
	enemy_current_hp -= player_damage
	
	if enemy_current_hp <= 0:
		$background/Enemy.play("death")
		$Panel/Label.text = "The enemy fainted!"
		
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
	
	$Panel/answer_button.visible = true
	$Panel/answer_button.grab_focus()

func win_battle():
	$Panel/Label.text = "You won! +50 EXP"
	
	if current_enemy_node != null:
		current_enemy_node.queue_free() # Deletes the skeleton from the world
	
	await get_tree().create_timer(2.0).timeout
	_on_run_button_pressed()

func _on_run_button_pressed():
	get_tree().paused = false
	visible = false
	$background.visible = false
