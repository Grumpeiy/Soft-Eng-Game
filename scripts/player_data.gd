extends Node

# ─────────────────────────────────────────────────────────────────────────────
# USER IDENTITY
# ─────────────────────────────────────────────────────────────────────────────
var user_type               = ""
var user_id                 = ""
var username                = ""
var full_name               = ""
var lrn                     = ""
var teacher_id              = ""
var admin_id                = ""
var sensory_profile_setting = ""
var capability_level        = ""
var is_logged_in            = false
var has_character           = false
var has_save_file: bool:
	get: return has_character
	set(value): has_character = value
var character_data = {}
var character_id   = 0

# ─────────────────────────────────────────────────────────────────────────────
# SAVE FILE
# Persists small pieces of game progress locally (intro watched, active quest,
# etc.). Stored per-LRN so switching students doesn't bleed data.
# ─────────────────────────────────────────────────────────────────────────────
var save_file_data : Dictionary = {}

const SAVE_DIR  = "user://saves/"
const SAVE_EXT  = ".json"

# Returns the save file path for the current student
func _save_path() -> String:
	var safe_lrn = lrn.strip_edges().replace("/", "_").replace("\\", "_")
	if safe_lrn == "":
		safe_lrn = "guest"
	return SAVE_DIR + safe_lrn + SAVE_EXT

# Call once after login to load (or create) the student's save file
func load_save_file():
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)

	var path = _save_path()
	if FileAccess.file_exists(path):
		var file    = FileAccess.open(path, FileAccess.READ)
		var parsed  = JSON.parse_string(file.get_as_text())
		file.close()
		if parsed is Dictionary:
			save_file_data = parsed
			print("PlayerData: save file loaded for LRN '%s'" % lrn)
			return
	# No file yet — start fresh
	save_file_data = {}
	print("PlayerData: no save file found for LRN '%s', starting fresh" % lrn)

# Call whenever you change save_file_data
func save_game_data(data: Dictionary):
	save_file_data = data
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var file = FileAccess.open(_save_path(), FileAccess.WRITE)
	file.store_string(JSON.stringify(save_file_data, "\t"))
	file.close()
	print("PlayerData: save file written for LRN '%s'" % lrn)

# Convenience — set one key and save immediately
func set_save_value(key: String, value) -> void:
	save_file_data[key] = value
	save_game_data(save_file_data)

# Convenience — read one key with a default
func get_save_value(key: String, default = null):
	return save_file_data.get(key, default)

# ─────────────────────────────────────────────────────────────────────────────
# LOGIN HELPERS
# ─────────────────────────────────────────────────────────────────────────────
func set_student_data(data: Dictionary):
	user_type               = "student"
	lrn                     = data.get("lrn", "")
	username                = data.get("username", "")
	full_name               = data.get("name", "")
	teacher_id              = data.get("assigned_teacher_id", "")
	sensory_profile_setting = data.get("sensory_profile_setting", "")
	capability_level        = data.get("capability_level", "")
	is_logged_in            = true
	# Load this student's save file right after login
	load_save_file()

func set_teacher_data(data: Dictionary):
	user_type    = "teacher"
	teacher_id   = data.get("teacher_id", "")
	username     = data.get("username", "")
	full_name    = data.get("name", "")
	is_logged_in = true

func set_admin_data(data: Dictionary):
	user_type    = "admin"
	admin_id     = data.get("admin_id", "")
	username     = data.get("username", "")
	full_name    = data.get("full_name", "")
	is_logged_in = true

# ─────────────────────────────────────────────────────────────────────────────
# LOGOUT
# ─────────────────────────────────────────────────────────────────────────────
func logout():
	user_type               = ""
	user_id                 = ""
	username                = ""
	full_name               = ""
	lrn                     = ""
	teacher_id              = ""
	admin_id                = ""
	sensory_profile_setting = ""
	capability_level        = ""
	is_logged_in            = false
	has_character           = false
	character_data          = {}
	character_id            = 0
	save_file_data          = {}   # clear in memory — file on disk stays intact

# ─────────────────────────────────────────────────────────────────────────────
# CHARACTER
# ─────────────────────────────────────────────────────────────────────────────
func get_display_name() -> String:
	return full_name if full_name != "" else username

func set_character_data(data: Dictionary):
	has_character = true
	character_data = data
	character_id   = data.get("character_id", 0)
