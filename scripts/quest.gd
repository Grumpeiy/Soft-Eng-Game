extends Node2D

const BASE_URL = "http://localhost/gamified_learning/"

@onready var quest_container = $ScrollContainer/VBoxContainer
@onready var back_button     = $Back

var quest_data  : Array  = []
var current_lrn : String = ""

const COLOR_COMPLETED   = Color(0.2, 0.8, 0.2)
const COLOR_IN_PROGRESS = Color(1.0, 0.8, 0.2)
const COLOR_LOCKED      = Color(0.5, 0.5, 0.5)
const COLOR_NOT_STARTED = Color(1.0, 1.0, 1.0)

func _ready():
	# Fix: was missing correct indentation causing back_button to be unconnected
	#back_button.pressed.connect(_on_back_pressed)

	# Hide the static placeholder row built in the editor
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
	var status    = quest.get("completion_status", null)
	var is_locked = quest.get("is_locked", false)

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

	if quest.get("activity_type") == "lesson":
		score_label.text = "Lesson — no score"
	elif quest.get("score_display") != null:
		score_label.text = "Score: %s" % quest["score_display"]
	elif status == "not_started" or status == null:
		score_label.text = "Not yet attempted"
	else:
		score_label.text = "Score: --/%d" % quest.get("max_score", 0)

	if is_locked:
		for lbl in [name_label, topic_label, score_label]:
			lbl.modulate = COLOR_LOCKED

	info_vbox.add_child(name_label)
	info_vbox.add_child(topic_label)
	info_vbox.add_child(score_label)
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)

	# ── Right: status badge ───────────────────────────────────────────────────
	var status_label = Label.new()
	if is_locked:
		status_label.text     = "Locked"
		status_label.modulate = COLOR_LOCKED
	elif status == "completed":
		status_label.text     = "Done"
		status_label.modulate = COLOR_COMPLETED
	elif status == "in_progress":
		status_label.text     = "In Progress"
		status_label.modulate = COLOR_IN_PROGRESS
	else:
		status_label.text     = "Not Started"
		status_label.modulate = COLOR_NOT_STARTED
	hbox.add_child(status_label)

	# ── Play button ───────────────────────────────────────────────────────────
	if not is_locked and status != "completed":
		var play_btn  = Button.new()
		play_btn.text = "Play"
		play_btn.pressed.connect(func(): _on_quest_play_pressed(quest))
		hbox.add_child(play_btn)

	return panel

# ─────────────────────────────────────────────────────────────────────────────
# PLAY
# ─────────────────────────────────────────────────────────────────────────────
func _on_quest_play_pressed(quest: Dictionary):
	PlayerData.set_save_value("active_quest_id",    quest["quest_id"])
	PlayerData.set_save_value("active_quest_start", Time.get_datetime_string_from_system())

	match quest.get("activity_type", ""):
		"puzzle":  get_tree().change_scene_to_file("res://scenes/minigame_map.tscn")
		"lesson":  get_tree().change_scene_to_file("res://scenes/WizardLesson.tscn")
		"battle":  get_tree().change_scene_to_file("res://scenes/Well.tscn")
		_:         get_tree().change_scene_to_file("res://scenes/Well.tscn")

# ─────────────────────────────────────────────────────────────────────────────
# BACK
# ─────────────────────────────────────────────────────────────────────────────
func _on_back_pressed():
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/Progress.tscn")

func _on_back_mouse_entered() -> void:
	Settings.play_narration("Back")
