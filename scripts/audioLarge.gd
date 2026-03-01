extends Node2D

const ACCESSIBILITY_SCENE = "res://scenes/Options/accessbility.tscn"
const GAMEPLAY_SCENE = "res://scenes/Options/Gameplay.tscn"
const OTHER_SCENE = "res://scenes/Options/Other.tscn"
const MAIN_MENU_SCENE = "res://scenes/options/main_menu.tscn"

@onready var master_slider = $"Audio Settings 1/Audio Settings/Master"
@onready var music_slider = $"Audio Settings 2/Audio balance/Music"
@onready var sfx_slider = $"Audio Settings 2/Audio balance/SFX"
@onready var dialogue_slider = $"Audio Settings 2/Audio balance/Dialogue"

func _ready():
	master_slider.value = Audio.master_volume
	music_slider.value = Audio.music_volume
	sfx_slider.value = Audio.sfx_volume
	dialogue_slider.value = Audio.dialogue_volume
	
	Audio.volume_changed.connect(_on_volume_changed)
	
func _on_volume_changed(bus_name, value):
	match bus_name:
		"Master":
			master_slider.value = value
		"MUSIC":
			music_slider.value = value
		"SFX":
			sfx_slider.value = value
		"Dialogue":
			dialogue_slider.value = value

func change_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)

func _on_accessibility_pressed() -> void:
	change_scene(ACCESSIBILITY_SCENE)

func _on_gameplay_pressed() -> void:
	change_scene(GAMEPLAY_SCENE)

func _on_other_pressed() -> void:
	change_scene(OTHER_SCENE)

func _on_back_pressed() -> void:
	change_scene(MAIN_MENU_SCENE)

func _on_master_value_changed(value: float) -> void:
	Audio.set_bus_volume("Master", value)

func _on_music_value_changed(value: float) -> void:
	Audio.set_bus_volume("MUSIC", value)

func _on_sfx_value_changed(value: float) -> void:
	Audio.set_bus_volume("SFX", value)

func _on_dialogue_value_changed(value: float) -> void:
	Audio.set_bus_volume("Dialogue", value)
