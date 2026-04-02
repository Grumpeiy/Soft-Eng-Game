extends Control

@onready var save_button    = $Save            if has_node("Save")             else null
@onready var save_message   = $SaveMessageLabel if has_node("SaveMessageLabel") else null

var save_message_tween: Tween = null

func _ready():
	hide()

func _process(_delta: float) -> void:
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

# ─────────────────────────────────────────────────────────────────────────────
# SAVE — saves settings + position locally, then syncs character to DB
# ─────────────────────────────────────────────────────────────────────────────
func save_game() -> bool:
	if not PlayerData.has_character:
		return false

	# 1. Save settings and position to local JSON file
	PlayerData.save_settings()

	# 2. Save player position — find by group so node name does not matter
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		PlayerData.save_position(players[0].global_position)
		print("Pause: position saved -> ", players[0].global_position)

	# 3. Sync character level to DB
	_save_character_to_db()

	return true

func _save_character_to_db():
	var url       = "http://localhost/gamified_learning/character.php"
	var json_data = JSON.stringify({
		"action"   : "update",
		"lrn"      : PlayerData.lrn,
		"level"    : PlayerData.character_data.get("level", 1),
		"inventory": []
	})
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_save_completed.bind(http))
	http.request(url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, json_data)

func _on_save_completed(result, response_code, headers, body, http_node):
	http_node.queue_free()
	var json = JSON.new()
	if json.parse(body.get_string_from_utf8()) == OK:
		var response = json.get_data()
		if response.get("success", false):
			print("Pause: character synced to DB")
		else:
			print("Pause: DB save failed — ", response.get("message", "unknown"))

# ─────────────────────────────────────────────────────────────────────────────
# BUTTONS
# ─────────────────────────────────────────────────────────────────────────────
func _on_resume_pressed() -> void:
	Audio.play_click()
	resume()

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

func _on_quit_pressed() -> void:
	Audio.play_click()

	# Always save everything before quitting to menu
	if PlayerData.has_save_file:
		save_game()
		show_message("Progress saved!")
		await get_tree().create_timer(0.8).timeout

	get_tree().paused = false
	get_tree().change_scene_to_file(Settings.current_main_menu_scene)

func _on_option_pressed() -> void:
	Audio.play_click()

func _on_progress_pressed() -> void:
	Audio.play_click()

func _on_badges_2_pressed() -> void:
	Audio.play_click()

# ─────────────────────────────────────────────────────────────────────────────
# MESSAGE
# ─────────────────────────────────────────────────────────────────────────────
func show_message(text: String, duration: float = 2.0):
	if not save_message:
		print("Save Message: ", text)
		return

	if save_message_tween and save_message_tween.is_valid():
		save_message_tween.kill()

	save_message.text       = text
	save_message.modulate.a = 0
	save_message.visible    = true

	save_message_tween = create_tween()
	save_message_tween.tween_property(save_message, "modulate:a", 1.0, 0.3)
	save_message_tween.tween_interval(duration)
	save_message_tween.tween_property(save_message, "modulate:a", 0.0, 0.3)
	save_message_tween.tween_callback(func(): save_message.visible = false)
	
