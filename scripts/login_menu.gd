extends Control

@onready var username_input = $Panel/username
@onready var password_input = $TextureRect/password
@onready var login_button = $TextureRect/Login
@onready var error_popup = $ErrorPopup
@onready var eye_button = $TextureRect/password/eye_button

var http_request: HTTPRequest
var eye_open = preload("res://Art/LogInMenu/eyeopen.png")   # UPDATE path
var eye_closed = preload("res://Art/LogInMenu/eyeclose.png") # UPDATE path

var password_visible: bool = false

func _ready() -> void:
	
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_login_response)
	
	password_input.secret = true
	#login_button.pressed.connect(_on_login_pressed)
	eye_button.texture_normal = eye_closed
	#eye_button.pressed.connect(_on_eye_button_pressed)
	
func _on_login_pressed() -> void:
	
	var username = username_input.text.strip_edges()
	var password = password_input.text.strip_edges()
	
	if username.is_empty() or password.is_empty():
		show_error("Please enter username and password")
		return
	
	login_button.disabled = true
	login_button.text = "Logging in..."
	
	send_login_request(username, password)

func send_login_request(username: String, password: String):
	var url = "http://localhost/gamified_learning/login.php"
	
	var json_data = JSON.stringify({
		"username": username,
		"password": password
	})
	
	var headers = ["Content-Type: application/json"]
	http_request.request(url, headers, HTTPClient.METHOD_POST, json_data)

func _on_login_response(result, response_code, headers, body):
	login_button.disabled = false
	login_button.text = "Login"
	
	var response_text = body.get_string_from_utf8()
	print("=== Login Response ===")
	print("Result: ", result)
	print("HTTP Code: ", response_code)
	print("Body: ", response_text)
	print("======================")
	
	if result != HTTPRequest.RESULT_SUCCESS:
		show_error("Connection failed. Make sure XAMPP is running.")
		return
	
	var json = JSON.new()
	var parse_result = json.parse(response_text)
	
	if parse_result != OK:
		show_error("Invalid response from server")
		return
	
	var response = json.get_data()
	
	if response.get("success", false):
		handle_successful_login(response)
	else:
		show_error(response.get("message", "Login failed"))

func handle_successful_login(response: Dictionary):
	var user_type = response.get("user_type", "")
	
	if user_type == "student":
		PlayerData.set_student_data(response)
		print("Student logged in: %s" % PlayerData.full_name)
		
		var possible_paths = [
			"res://scenes/Options/main_menu.tscn",
			"res://scenes/options/main_menu.tscn",
			"res://scenes/main_menu.tscn",
			"res://main_menu.tscn"
		]
		
		var found = false
		for path in possible_paths:
			if ResourceLoader.exists(path):
				print("Loading main menu from: ", path)
				get_tree().change_scene_to_file(path)
				found = true
				break
		
		if not found:
			show_error("Main menu scene not found!")
			print("Checked paths:", possible_paths)
	
	elif user_type == "teacher":
		show_error("Teachers must use the website")
	
	elif user_type == "admin":
		show_error("Admins must use the website")
	
	else:
		show_error("Unknown user type")

func show_error(message: String):
	error_popup.dialog_text = message
	error_popup.popup_centered()


func _on_eye_button_pressed():
	password_visible = !password_visible
	password_input.secret = !password_visible
	
	if password_visible:
		eye_button.texture_normal = eye_open
	else:
		eye_button.texture_normal = eye_closed
		
	eye_button.ignore_texture_size = true
	eye_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
