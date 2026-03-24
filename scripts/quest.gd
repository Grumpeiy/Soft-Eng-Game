extends Node2D

# ── Config ────────────────────────────────────────────────────────────────────
const BASE_URL           = "https://yourserver.com/api/"  # ← change this
const COMPLETE_QUEST_URL = BASE_URL + "complete_quest.php"

# ── Node references — matched to your actual Quest.tscn ──────────────────────
# Root:          Progress (Node2D)
# Back button:   Back (TextureButton) — direct child of root
# Quest rows go: ScrollContainer/VBoxContainer
@onready var quest_container = $ScrollContainer/VBoxContainer
@onready var back_button     = $Back
# No TitleLabel in your scene yet — add one if you want a header

# ─────────────────────────────────────────────────────────────────────────────
var quest_data  : Array  = []
var current_lrn : String = ""

# Status colors
const COLOR_COMPLETED   = Color(0.2, 0.8, 0.2)  # green
const COLOR_IN_PROGRESS = Color(1.0, 0.8, 0.2)  # yellow
const COLOR_LOCKED      = Color(0.5, 0.5, 0.5)  # grey
const COLOR_NOT_STARTED = Color(1.0, 1.0, 1.0)  # white

# ─────────────────────────────────────────────────────────────────────────────
func _ready():
		back_button.pressed.connect(_on_back_pressed)

	# Hide the static placeholder row that exists in the .tscn
	# The real rows are built in code into ScrollContainer/VBoxContainer
	if has_node("PanelContainer"):
		$PanelContainer.visible = false

	# Also hide the duplicate unconnected BackButton node
	if has_node("BackButton"):
		$BackButton.visible = false

	# Load LRN from PlayerData
	current_lrn = PlayerData.lrn

	# Fetch quest data from server on open
	_fetch_quests_from_server()

# ─────────────────────────────────────────────────────────────────────────────
# Called by Progress.gd if passing data directly instead of fetching
# ─────────────────────────────────────────────────────────────────────────────
func setup(quests: Array, lrn: String):
	quest_data  = quests
	current_lrn = lrn

func _enter_tree():
	if quest_data.size() > 0:
		_build_quest_list()

# ─────────────────────────────────────────────────────────────────────────────
# HTTP — fetch quests from get_quests.php
# ─────────────────────────────────────────────────────────────────────────────
func _fetch_quests_from_server():
	if current_lrn == "":
		push_error("Quest: LRN is empty, cannot fetch quests")
		return
	var url  = "%sget_quests.php?lrn=%s" % [BASE_URL, current_lrn]
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(res, code, h, body):
		if code == 200:
			var json = JSON.new()
			if json.parse(body.get_string_from_utf8()) == OK:
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
# UI BUILD
# ─────────────────────────────────────────────────────────────────────────────
func _build_quest_list():
	# Clear any previously built rows
	for child in quest_container.get_children():
		child.queue_free()

	for quest in quest_data:
		quest_container.add_child(_build_quest_row(quest))

func _build_quest_row(quest: Dictionary) -> Control:
	var status    = quest["completion_status"]
	var is_locked = quest["is_locked"]

	var panel = PanelContainer.new()
	var hbox  = HBoxContainer.new()
	panel.add_child(hbox)

	# ── Left: quest info ──────────────────────────────────────────────────────
	var info_vbox   = VBoxContainer.new()
	var name_label  = Label.new()
	var topic_label = Label.new()
	var score_label = Label.new()

	name_label.text  = "%d. %s" % [quest["order_number"], quest["title"]]
	topic_label.text = quest["curriculum_topic"]

	if quest["activity_type"] == "lesson":
		score_label.text = "Lesson — no score"
	elif quest["score_display"] != null:
		score_label.text = "Score: %s" % quest["score_display"]
	elif status == "not_started" or status == null:
		score_label.text = "Not yet attempted"
	else:
		score_label.text = "Score: --/%d" % quest["max_score"]

	if is_locked:
		name_label.modulate  = COLOR_LOCKED
		topic_label.modulate = COLOR_LOCKED
		score_label.modulate = COLOR_LOCKED

	info_vbox.add_child(name_label)
	info_vbox.add_child(topic_label)
	info_vbox.add_child(score_label)
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)

	# ── Right: status badge ───────────────────────────────────────────────────
	var status_label = Label.new()
	if is_locked:
		status_label.text     = "🔒 Locked"
		status_label.modulate = COLOR_LOCKED
	elif status == "completed":
		status_label.text     = "✅ Done"
		status_label.modulate = COLOR_COMPLETED
	elif status == "in_progress":
		status_label.text     = "▶ In Progress"
		status_label.modulate = COLOR_IN_PROGRESS
	else:
		status_label.text     = "○ Not Started"
		status_label.modulate = COLOR_NOT_STARTED
	hbox.add_child(status_label)

	# ── Play button (hidden if locked or completed) ───────────────────────────
	if not is_locked and status != "completed":
		var play_btn  = Button.new()
		play_btn.text = "▶ Play"
		play_btn.pressed.connect(func(): _on_quest_play_pressed(quest))
		hbox.add_child(play_btn)

	return panel

# ─────────────────────────────────────────────────────────────────────────────
# QUEST PLAY
# ─────────────────────────────────────────────────────────────────────────────
func _on_quest_play_pressed(quest: Dictionary):
	PlayerData.set_save_value("active_quest_id",    quest["quest_id"])
	PlayerData.set_save_value("active_quest_start", Time.get_datetime_string_from_system())

	match quest["activity_type"]:
		"puzzle":  get_tree().change_scene_to_file("res://scenes/minigame_map.tscn")
		"lesson":  get_tree().change_scene_to_file("res://scenes/WizardLesson.tscn")
		"battle":  get_tree().change_scene_to_file("res://scenes/World.tscn")

# ─────────────────────────────────────────────────────────────────────────────
# COMPLETE QUEST — called from BattleScene, puzzle, or lesson when done
# ─────────────────────────────────────────────────────────────────────────────
func complete_quest_on_server(quest_id: int, score: int, attempts_count: int, time_on_task: int):
	var payload = JSON.stringify({
		"lrn"             : current_lrn,
		"quest_id"        : quest_id,
		"score"           : score,
		"attempts_count"  : attempts_count,
		"time_on_task_sec": time_on_task,
		"date_started"    : PlayerData.get_save_value("active_quest_start", ""),
	})
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(Callable(self, "_on_quest_completed").bind(http))
	http.request(COMPLETE_QUEST_URL, ["Content-Type: application/json"], HTTPClient.METHOD_POST, payload)

func _on_quest_completed(result, response_code, _headers, body, http_node):
	http_node.queue_free()
	if response_code != 200:
		push_error("complete_quest failed (HTTP %d)" % response_code)
		return
	var json = JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		return
	var data = json.get_data()
	if data.get("success", false):
		if data.get("badge_awarded") != null:
			_show_badge_popup(data["badge_awarded"])
		_fetch_quests_from_server()  # refresh list
	else:
		push_error("complete_quest error: " + str(data.get("error", "")))

# ─────────────────────────────────────────────────────────────────────────────
# BADGE POPUP
# ─────────────────────────────────────────────────────────────────────────────
func _show_badge_popup(badge: Dictionary):
	var popup           = AcceptDialog.new()
	popup.title         = "🏅 Badge Earned!"
	popup.dialog_text   = "%s\n\n%s" % [badge["name"], badge["description"]]
	popup.popup_hide_on_ok = true
	add_child(popup)
	popup.popup_centered()

# ─────────────────────────────────────────────────────────────────────────────
func _on_back_pressed():
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/Progress.tscn")

func _on_back_mouse_entered() -> void:
	pass
