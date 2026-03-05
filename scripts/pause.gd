extends Control 

@onready var save_button = $Save if has_node("Save") else null
@onready var save_message = $SaveMessageLabel if has_node("SaveMessageLabel") else null

var save_message_tween: Tween = null

func _ready():
	hide()

func _process(delta: float) -> void:
	testEsc()

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	hide()

func pause():
	show()
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	update_save_button()

func testEsc():
	if Input.is_action_just_pressed("esc"):
		if get_tree().paused:
			resume()
		else:
			pause()

func update_save_button():
	if save_button:
		save_button.disabled = not PlayerData.has_save_file

func _on_resume_pressed() -> void:
	Audio.play_click()
	resume()

func _on_quit_pressed() -> void:
	Audio.play_click()

	if PlayerData.has_save_file:
		save_game()
		show_message("Progress saved!")
		await get_tree().create_timer(0.5).timeout
	
	get_tree().paused = false
	get_tree().change_scene_to_file(Settings.current_main_menu_scene)

func _on_option_pressed() -> void:
	Audio.play_click()
	pass

func _on_progress_pressed() -> void:
	Audio.play_click()
	pass

func _on_badges_2_pressed() -> void:
	Audio.play_click()
	pass

func _on_save_pressed() -> void:
	Audio.play_click()
	
	if not PlayerData.has_save_file:
		show_message("No save file found!\nCreate one from Start menu", 2.0)
		return
	
	if save_button:
		save_button.disabled = true
	
	if save_game():
		show_message("Game Saved!", 1.5)
	else:
		show_message("Save Failed!", 1.5)
	
	await get_tree().create_timer(1.0).timeout
	if save_button:
		save_button.disabled = false

func save_game() -> bool:
	if not PlayerData.has_character:
		return false

	var url = "http://localhost/gamified_learning/character.php"
	
	# TODO: Get actual inventory from game
	var inventory = []  # Replace with actual inventory data
	
	var json_data = JSON.stringify({
		"action": "update",
		"lrn": PlayerData.lrn,
		"level": PlayerData.character_data.get("level", 1),
		"inventory": inventory
	})
	
	var headers = ["Content-Type: application/json"]
	
	var save_http = HTTPRequest.new()
	add_child(save_http)
	save_http.request_completed.connect(_on_save_completed)
	save_http.request(url, headers, HTTPClient.METHOD_POST, json_data)
	
	return true

func _on_save_completed(result, response_code, headers, body):
	var response_text = body.get_string_from_utf8()
	print("Save response: ", response_text)
	
	var json = JSON.new()
	var parse_result = json.parse(response_text)
	
	if parse_result == OK:
		var response = json.get_data()
		if response.get("success", false):
			print("Game saved successfully to database")
		else:
			print("Save failed: ", response.get("message", "Unknown error"))

func show_message(text: String, duration: float = 2.0):
	if not save_message:
		print("Save Message: ", text)
		return
	
	if save_message_tween and save_message_tween.is_valid():
		save_message_tween.kill()
	
	save_message.text = text
	save_message.modulate.a = 0
	save_message.visible = true
	
	save_message_tween = create_tween()
	save_message_tween.tween_property(save_message, "modulate:a", 1.0, 0.3)
	save_message_tween.tween_interval(duration)
	save_message_tween.tween_property(save_message, "modulate:a", 0.0, 0.3)
	save_message_tween.tween_callback(func(): save_message.visible = false)
	
