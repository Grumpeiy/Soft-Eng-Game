extends Node2D

@onready var create_button = $Create
@onready var load_button   = $Load
@onready var erase_button  = $Erase
@onready var save_info_label = $SaveInfoLabel if has_node("SaveInfoLabel") else null

var http_request: HTTPRequest

const CUTSCENE_SCENE = "res://scenes/cutscenes/cut_scene_transition.tscn"
const WELL_SCENE     = "res://scenes/Well.tscn"

func _ready() -> void:
	Settings.narration_player = $NarrationPlayer if has_node("NarrationPlayer") else null

	if not PlayerData.is_logged_in:
		get_tree().change_scene_to_file("res://scenes/login_menu.tscn")
		return

	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_http_request_completed)

	check_character_exists()

func check_character_exists():
	var url       = "http://localhost/gamified_learning/character.php"
	var json_data = JSON.stringify({"action": "check", "lrn": PlayerData.lrn})
	var headers   = ["Content-Type: application/json"]
	http_request.request(url, headers, HTTPClient.METHOD_POST, json_data)

	create_button.disabled = true
	load_button.disabled   = true
	erase_button.disabled  = true

	if save_info_label:
		save_info_label.text = "Loading..."

func _on_http_request_completed(result, response_code, headers, body):
	var response_text = body.get_string_from_utf8()
	var json          = JSON.new()
	if json.parse(response_text) != OK:
		update_button_states(false)
		return
	var response = json.get_data()
	if response.get("success", false):
		var exists = response.get("exists", false)
		if exists:
			PlayerData.set_character_data(response.get("character", {}))
			update_button_states(true)
		else:
			PlayerData.has_character = false
			update_button_states(false)
	else:
		update_button_states(false)

func update_button_states(has_character: bool):
	if has_character:
		create_button.disabled = true
		load_button.disabled   = false
		erase_button.disabled  = false
		if save_info_label:
			var level    = PlayerData.character_data.get("level", 1)
			var username = PlayerData.character_data.get("username", "Unknown")
			save_info_label.text = "Character: %s\nLevel: %d" % [username, level]
	else:
		create_button.disabled = false
		load_button.disabled   = true
		erase_button.disabled  = true
		if save_info_label:
			save_info_label.text = "No Character\nClick 'Create' to start"

func proceed_to_game(new_game: bool = false):
	if new_game:
		#Brand new character — show tutorial and/or cutscene
		if Settings.tutorial_mode_enabled and not Settings.has_seen_tutorial:
			get_tree().change_scene_to_file("res://scenes/tutorial.tscn")
		else:
			get_tree().change_scene_to_file(CUTSCENE_SCENE)
	else:
		#Returning player — skip intro and restore their saved position
		get_tree().change_scene_to_file(WELL_SCENE)

func _on_back_pressed() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/main_menu.tscn")

func _on_create_pressed() -> void:
	Audio.play_click()
	create_button.disabled = true
	if save_info_label:
		save_info_label.text = "Creating character..."
	create_character()

func create_character():
	var url       = "http://localhost/gamified_learning/character.php"
	var json_data = JSON.stringify({
		"action"      : "create",
		"lrn"         : PlayerData.lrn,
		"username"    : PlayerData.username,
		"avatar_image": "default_avatar.png"
	})
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_create_completed)
	http.request(url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, json_data)

func _on_create_completed(result, response_code, headers, body):
	create_button.disabled = false
	var json = JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		if save_info_label: save_info_label.text = "Error creating character."
		return
	var response = json.get_data()
	if response.get("success", false):
		PlayerData.set_character_data(response.get("character", {}))
		proceed_to_game(true)   # new game — show cutscene/tutorial
	else:
		if save_info_label:
			save_info_label.text = "Failed to create character."

func _on_load_pressed() -> void:
	Audio.play_click()
	load_button.disabled = true
	if save_info_label:
		save_info_label.text = "Loading character..."
	load_character()

func load_character():
	var url       = "http://localhost/gamified_learning/character.php"
	var json_data = JSON.stringify({"action": "load", "lrn": PlayerData.lrn})
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_load_completed)
	http.request(url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, json_data)

func _on_load_completed(result, response_code, headers, body):
	load_button.disabled = false
	var json = JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		return
	var response = json.get_data()
	if response.get("success", false):
		PlayerData.set_character_data(response.get("character", {}))
		print("Character loaded: ", PlayerData.character_data.get("username", "Unknown"))
		PlayerData.load_save_file()
		proceed_to_game(false)
	else:
		if save_info_label:
			save_info_label.text = "Failed to load character."

#── ERASE ─────────────────────────────────────────────────────────────────────
func _on_erase_pressed() -> void:
	Audio.play_click()
	if has_node("ConfirmDialog"):
		$ConfirmDialog.popup_centered()
	else:
		erase_character()

func erase_character():
	erase_button.disabled = true
	if save_info_label:
		save_info_label.text = "Erasing character..."
	var url       = "http://localhost/gamified_learning/character.php"
	var json_data = JSON.stringify({"action": "delete", "lrn": PlayerData.lrn})
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_erase_completed)
	http.request(url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, json_data)

func _on_erase_completed(result, response_code, headers, body):
	erase_button.disabled = false
	var json = JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		return
	var response = json.get_data()
	if response.get("success", false):
		PlayerData.has_character  = false
		PlayerData.character_data = {}
		# Also wipe the local save file so defeated enemies etc. reset
		PlayerData.save_game_data({})
		update_button_states(false)

func _on_confirm_dialog_confirmed():
	erase_character()

func _on_back_mouse_entered() -> void:
	Settings.play_narration("Back")
func _on_create_mouse_entered() -> void:
	Settings.play_narration("Create")
func _on_erase_mouse_entered() -> void:
	Settings.play_narration("Erase")
func _on_load_mouse_entered() -> void:
	Settings.play_narration("Load")
	
