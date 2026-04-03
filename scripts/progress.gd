extends Node2D

const BASE_URL       = "http://localhost/gamified_learning/"
const GET_QUESTS_URL = BASE_URL + "get_quests.php"

@onready var chapter1_btn = $Quest

var current_lrn : String = ""
var quest_data  : Array  = []

func _ready():
	Settings.narration_player = $NarrationPlayer
	Settings.current_main_menu_scene = scene_file_path
	
	current_lrn = PlayerData.lrn
	if current_lrn == "":
		push_error("Progress: LRN is empty")
		return
	chapter1_btn.pressed.connect(_on_chapter1_pressed)
	_fetch_quests()

func _fetch_quests():
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

func _on_chapter1_pressed():
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/Quest.tscn")

func _on_back_pressed() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/Options/main_menu.tscn")

func _on_back_mouse_entered() -> void:
	Settings.play_narration("Back")
