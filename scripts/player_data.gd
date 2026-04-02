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
# Stored per-LRN at user://saves/<lrn>.json
# Keys used:
#   defeated_enemies  : Array[int]  e.g. [1, 2] = skeletons 1 & 2 beaten
#   active_quest_id   : int
#   active_quest_start: String (ISO datetime)
#   last_position     : {x, y}
#   settings          : {difficulty_level, guided_mode_enabled,
#                        tutorial_mode_enabled, menu_narration_enabled,
#                        narration_gender, sound_cues_enabled}
# ─────────────────────────────────────────────────────────────────────────────
var save_file_data : Dictionary = {}

const SAVE_DIR = "user://saves/"
const SAVE_EXT = ".json"

func _save_path() -> String:
	var safe = lrn.strip_edges().replace("/", "_").replace("\\", "_")
	if safe == "": safe = "guest"
	return SAVE_DIR + safe + SAVE_EXT

func load_save_file():
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var path = _save_path()
	if FileAccess.file_exists(path):
		var file   = FileAccess.open(path, FileAccess.READ)
		var parsed = JSON.parse_string(file.get_as_text())
		file.close()
		if parsed is Dictionary:
			save_file_data = parsed
			print("PlayerData: save loaded for '%s'" % lrn)
			_apply_saved_settings()
			return
	save_file_data = {}
	print("PlayerData: no save found for '%s', starting fresh" % lrn)

func save_game_data(data: Dictionary):
	save_file_data = data
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var file = FileAccess.open(_save_path(), FileAccess.WRITE)
	file.store_string(JSON.stringify(save_file_data, "\t"))
	file.close()

func set_save_value(key: String, value) -> void:
	save_file_data[key] = value
	save_game_data(save_file_data)

func get_save_value(key: String, default = null):
	return save_file_data.get(key, default)

# ─────────────────────────────────────────────────────────────────────────────
# SETTINGS PERSISTENCE
# Call save_settings() any time the player changes a setting.
# load_save_file() calls _apply_saved_settings() automatically on login.
# ─────────────────────────────────────────────────────────────────────────────
func save_settings():
	save_file_data["settings"] = {
		# Gameplay
		"difficulty_level"      : Settings.difficulty_level,
		"guided_mode_enabled"   : Settings.guided_mode_enabled,
		"tutorial_mode_enabled" : Settings.tutorial_mode_enabled,
		# Accessibility
		"menu_narration_enabled": Settings.menu_narration_enabled,
		"narration_gender"      : Settings.narration_gender,
		"sound_cues_enabled"    : Settings.sound_cues_enabled,
		"capitalization_enabled": Settings.capitalization_enabled,
		# Audio volumes
		"master_volume"         : Audio.master_volume,
		"music_volume"          : Audio.music_volume,
		"sfx_volume"            : Audio.sfx_volume,
		"narration_volume"      : Audio.narration_volume,
	}
	save_game_data(save_file_data)
	print("PlayerData: settings saved (difficulty=%s, master=%.1f)" % [
		Settings.difficulty_level, Audio.master_volume
	])


func _apply_saved_settings():
	var s = save_file_data.get("settings", {})
	if s.is_empty():
		return
 
	# Gameplay
	Settings.difficulty_level      = s.get("difficulty_level",      Settings.difficulty_level)
	Settings.guided_mode_enabled   = s.get("guided_mode_enabled",   Settings.guided_mode_enabled)
	Settings.tutorial_mode_enabled = s.get("tutorial_mode_enabled", Settings.tutorial_mode_enabled)
 
	# Accessibility
	Settings.menu_narration_enabled = s.get("menu_narration_enabled", Settings.menu_narration_enabled)
	Settings.narration_gender       = s.get("narration_gender",        Settings.narration_gender)
	Settings.sound_cues_enabled     = s.get("sound_cues_enabled",      Settings.sound_cues_enabled)
	Settings.capitalization_enabled = s.get("capitalization_enabled",  Settings.capitalization_enabled)
 
	# Audio volumes — restore to Audio singleton so sliders pick them up
	if s.has("master_volume"):
		Audio.set_bus_volume("Master",    s["master_volume"])
	if s.has("music_volume"):
		Audio.set_bus_volume("MUSIC",     s["music_volume"])
	if s.has("sfx_volume"):
		Audio.set_bus_volume("SFX",       s["sfx_volume"])
	if s.has("narration_volume"):
		Audio.set_bus_volume("Narration", s["narration_volume"])
 
	# Apply sound cues toggle so volume isn't overridden incorrectly
	Settings.apply_sound_cues()
 
	print("PlayerData: settings restored from save")

# ─────────────────────────────────────────────────────────────────────────────
# DEFEATED ENEMIES
# enemy_key: e.g. "skeleton_1", "skeleton_2", "skeleton_3"
# ─────────────────────────────────────────────────────────────────────────────
func mark_enemy_defeated(enemy_key: String):
	var defeated : Array = save_file_data.get("defeated_enemies", [])
	if enemy_key not in defeated:
		defeated.append(enemy_key)
	save_file_data["defeated_enemies"] = defeated
	save_game_data(save_file_data)
	print("PlayerData: enemy defeated -> ", enemy_key)

func is_enemy_defeated(enemy_key: String) -> bool:
	var defeated : Array = save_file_data.get("defeated_enemies", [])
	return enemy_key in defeated

# ─────────────────────────────────────────────────────────────────────────────
# LAST POSITION
# ─────────────────────────────────────────────────────────────────────────────
func save_position(pos: Vector2):
	save_file_data["last_position"] = {"x": pos.x, "y": pos.y}
	save_game_data(save_file_data)

func get_last_position(default: Vector2 = Vector2.ZERO) -> Vector2:
	var p = save_file_data.get("last_position", null)
	if p == null: return default
	return Vector2(p.get("x", default.x), p.get("y", default.y))

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
	# Always persist current settings before clearing anything
	if is_logged_in and lrn != "":
		save_settings()
 
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
	save_file_data          = {}   # cleared last, after save

# ─────────────────────────────────────────────────────────────────────────────
# CHARACTER
# ─────────────────────────────────────────────────────────────────────────────
func get_display_name() -> String:
	return full_name if full_name != "" else username

func set_character_data(data: Dictionary):
	has_character  = true
	character_data = data
	character_id   = data.get("character_id", 0)
