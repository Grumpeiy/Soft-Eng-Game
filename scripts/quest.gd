extends Node2D

const BASE_URL = "http://localhost/gamified_learning/"

@onready var quest_container = $ScrollContainer/VBoxContainer
@onready var back_button     = $Back

var quest_data  : Array  = []
var current_lrn : String = ""

const COLOR_COMPLETED   = Color(0.2, 0.8, 0.2)
const COLOR_IN_PROGRESS = Color(1.0, 0.8, 0.2)
const COLOR_NOT_STARTED = Color(1.0, 1.0, 1.0)

# ── Puzzle scoring legend (matches minigame_map.gd) ───────────────────────────
# < 3 min  → 100  Perfect
# < 4 min  → 80   Great
# < 5 min  → 70   Good
# 5 min+   → 50   Keep practicing

func _ready():
	Settings.narration_player = $NarrationPlayer
	Settings.current_main_menu_scene = scene_file_path

	if has_node("PanelContainer"):
		$PanelContainer.visible = false
	if has_node("BackButton"):
		$BackButton.visible = false

	current_lrn = PlayerData.lrn

	if current_lrn == "":
		push_error("Quest: LRN is empty")
		return

	_fetch_quests_from_server()

# ─────────────────────────────────────────────────────────────────────────────
# FETCH
# ─────────────────────────────────────────────────────────────────────────────
func _fetch_quests_from_server():
	var url  = "%sget_quests.php?lrn=%s" % [BASE_URL, current_lrn]
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(res, code, h, body):
		var text = body.get_string_from_utf8()
		print("get_quests response (", code, "): ", text)
		if code == 200:
			var json = JSON.new()
			if json.parse(text) == OK:
				var d = json.get_data()
				if d.get("success", false):
					quest_data = d["quests"]
					_build_quest_list()
				else:
					push_error("get_quests error: " + str(d.get("error", "")))
		http.queue_free()
	)
	http.request(url)

# ─────────────────────────────────────────────────────────────────────────────
# BUILD LIST
# ─────────────────────────────────────────────────────────────────────────────
func _build_quest_list():
	for child in quest_container.get_children():
		child.queue_free()
	for quest in quest_data:
		quest_container.add_child(_build_quest_row(quest))

func _build_quest_row(quest: Dictionary) -> Control:
	var status        = quest.get("completion_status", null)
	var activity_type = quest.get("activity_type", "")

	var panel = PanelContainer.new()
	var hbox  = HBoxContainer.new()
	panel.add_child(hbox)

	# ── Left: quest info ──────────────────────────────────────────────────────
	var info_vbox   = VBoxContainer.new()
	var name_label  = Label.new()
	var topic_label = Label.new()
	var score_label = Label.new()

	name_label.text  = "%d. %s" % [quest.get("order_number", 0), quest.get("title", "")]
	topic_label.text = quest.get("curriculum_topic", "")
	score_label.text = _get_score_text(quest)

	info_vbox.add_child(name_label)
	info_vbox.add_child(topic_label)
	info_vbox.add_child(score_label)
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)

	# ── Right: status badge ───────────────────────────────────────────────────
	var status_label = Label.new()
	if status == "completed":
		status_label.text     = "Done"
		status_label.modulate = COLOR_COMPLETED
	elif status == "in_progress":
		status_label.text     = "In Progress"
		status_label.modulate = COLOR_IN_PROGRESS
	else:
		status_label.text     = "Not Started"
		status_label.modulate = COLOR_NOT_STARTED
	hbox.add_child(status_label)

	# ── Play button — always visible, never locked ────────────────────────────
	if status != "completed":
		var play_btn  = Button.new()
		play_btn.text = "Play"
		play_btn.pressed.connect(func(): _on_quest_play_pressed(quest))
		hbox.add_child(play_btn)

	return panel

# ─────────────────────────────────────────────────────────────────────────────
# SCORE TEXT — different display per activity type
# ─────────────────────────────────────────────────────────────────────────────
func _get_score_text(quest: Dictionary) -> String:
	var activity_type = quest.get("activity_type", "")
	var status        = quest.get("completion_status", "")
	var score         = quest.get("score", null)
	var max_score     = quest.get("max_score", 100)

	# Lesson — no score ever
	if activity_type == "lesson":
		return "Lesson — no score"

	# Completed
	if status == "completed":
		if activity_type == "puzzle" and score != null:
			return "%s  (%d/100)" % [_puzzle_score_label(score), score]
		elif score != null:
			return "Score: %d/%d" % [score, max_score]
		else:
			return "Completed — no score"

	# In progress
	if status == "in_progress":
		if activity_type == "puzzle":
			return "Puzzle in progress..."
		return "In Progress..."

	# Not started
	if status == null or status == "" or status == "not_started":
		if activity_type == "puzzle":
			return "Score based on time:\n  < 3 min → 100  < 4 min → 80  < 5 min → 70  5min+ → 50"
		return "Not yet attempted"

	return "Unknown status"

func _puzzle_score_label(score: int) -> String:
	if score >= 100:
		return "Perfect! 🌟"
	elif score >= 80:
		return "Great job!"
	elif score >= 70:
		return "Good work!"
	else:
		return "Keep practicing!"

# ─────────────────────────────────────────────────────────────────────────────
# PLAY
# ─────────────────────────────────────────────────────────────────────────────
func _on_quest_play_pressed(quest: Dictionary):
	PlayerData.set_save_value("active_quest_id",    quest["quest_id"])
	PlayerData.set_save_value("active_quest_start", Time.get_datetime_string_from_system())

	match quest.get("activity_type", ""):
		"puzzle":  
			get_tree().change_scene_to_file("res://scenes/minigame_map.tscn")
		"lesson":  
			get_tree().change_scene_to_file("res://scenes/LessonDelivery/LessonAbtWeatherFinal.tscn")
		"battle":  
			# Temporarily save the target coordinates to PlayerData
			PlayerData.set_save_value("teleport_x", 1000.0)
			PlayerData.set_save_value("teleport_y", -252.0)
			get_tree().change_scene_to_file("res://scenes/Well.tscn")
		_:         
			get_tree().change_scene_to_file("res://scenes/Well.tscn")
# ─────────────────────────────────────────────────────────────────────────────
# BACK
# ─────────────────────────────────────────────────────────────────────────────
func _on_back_pressed():
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/Progress.tscn")

func _on_back_mouse_entered() -> void:
	Settings.play_narration("Back")
	
func _enter_tree():
	# Refetch quests whenever scene is entered
	if current_lrn != "":
		_fetch_quests_from_server()
		
