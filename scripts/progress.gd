extends Node2D

# ── Config ────────────────────────────────────────────────────────────────────
const BASE_URL       = "https://yourserver.com/api/"  # ← change this
const GET_QUESTS_URL = BASE_URL + "get_quests.php"

# ── Node references — matched to your actual Progress.tscn ───────────────────
# "Quest" is the Button node on the Chapter 1 card
@onready var chapter1_btn = $Quest

var current_lrn : String = ""
var quest_data  : Array  = []

# ─────────────────────────────────────────────────────────────────────────────
func _ready():
	current_lrn = PlayerData.lrn
	if current_lrn == "":
		push_error("Progress: LRN is empty")

	chapter1_btn.pressed.connect(_on_chapter1_pressed)

	# Fetch quest data in background so it's ready when player taps Chapter 1
	_fetch_quests()

# ─────────────────────────────────────────────────────────────────────────────
# HTTP — load quest list + statuses for this student
# ─────────────────────────────────────────────────────────────────────────────
func _fetch_quests():
	if current_lrn == "":
		return
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(res, code, h, body):
		if code == 200:
			var json = JSON.new()
			if json.parse(body.get_string_from_utf8()) == OK:
				var d = json.get_data()
				if d.get("success", false):
					quest_data = d["quests"]
					print("Progress: loaded %d quests" % quest_data.size())
				else:
					push_error("Progress: " + str(d.get("error", "")))
		http.queue_free()
	)
	http.request("%s?lrn=%s" % [GET_QUESTS_URL, current_lrn])

# ─────────────────────────────────────────────────────────────────────────────
# CHAPTER 1 BUTTON — opens Quest.tscn and passes the loaded quest data
# ─────────────────────────────────────────────────────────────────────────────
func _on_chapter1_pressed():
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/Quest.tscn")

# ─────────────────────────────────────────────────────────────────────────────
# BACK button (already connected in your .tscn via signal)
# ─────────────────────────────────────────────────────────────────────────────
func _on_back_pressed() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/main_menu.tscn")

func _on_back_mouse_entered() -> void:
	Settings.play_narration("Back")
