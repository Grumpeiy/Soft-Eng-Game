extends Node
var user_type = ""
var user_id = ""
var username = ""
var full_name = ""
var lrn = ""
var teacher_id = ""
var admin_id = ""
var sensory_profile_setting = ""
var capability_level = ""
var is_logged_in = false

var has_character = false
var has_save_file: bool:
	get: return has_character
	set(value): has_character = value
var character_data = {}
var character_id = 0

func set_student_data(data: Dictionary):
	user_type = "student"
	lrn = data.get("lrn", "")
	username = data.get("username", "")
	full_name = data.get("name", "")
	teacher_id = data.get("assigned_teacher_id", "")
	sensory_profile_setting = data.get("sensory_profile_setting", "")
	capability_level = data.get("capability_level", "")
	is_logged_in = true

func set_teacher_data(data: Dictionary):
	user_type = "teacher"
	teacher_id = data.get("teacher_id", "")
	username = data.get("username", "")
	full_name = data.get("name", "")
	is_logged_in = true

func set_admin_data(data: Dictionary):
	user_type = "admin"
	admin_id = data.get("admin_id", "")
	username = data.get("username", "")
	full_name = data.get("full_name", "")
	is_logged_in = true

func logout():
	user_type = ""
	user_id = ""
	username = ""
	full_name = ""
	lrn = ""
	teacher_id = ""
	admin_id = ""
	sensory_profile_setting = ""
	capability_level = ""
	is_logged_in = false
	has_character = false
	character_data = {}
	character_id = 0

func get_display_name() -> String:
	return full_name if full_name != "" else username

func set_character_data(data: Dictionary):
	has_character = true
	character_data = data
	character_id = data.get("character_id", 0)
