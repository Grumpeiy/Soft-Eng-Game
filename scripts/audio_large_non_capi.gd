extends Node2D

const ACCESSIBILITY_SCENE = "res://scenes/Options/accessbilityLargeNonCapi.tscn"
const GAMEPLAY_SCENE = "res://scenes/Options/GameplayLargeNonCapi.tscn"
const OTHER_SCENE = "res://scenes/Options/OtherLargeNonCapi.tscn"
const MAIN_MENU_SCENE = "res://scenes/options/MainMenuNonCapiLarge.tscn"

func _ready():
	Audio.volume_changed.connect(_on_volume_changed)

	$"Audio Settings 1/Audio Settings/Master".value = Audio.master_volume
	$"Audio Settings 2/Audio balance/Music".value = Audio.music_volume
	$"Audio Settings 2/Audio balance/Dialogue".value = Audio.sfx_volume
	$"Audio Settings 2/Audio balance/SFX".value = Audio.dialogue_volume
	
func _on_volume_changed(bus_name, value):
	match bus_name:
		"Master":
			$"Audio Settings 1/Audio Settings/Master".value = value
		"MUSIC":
			$"Audio Settings 2/Audio balance/Music".value = value
		"SFX":
			$"Audio Settings 2/Audio balance/Dialogue".value = value
		"Dialogue":
			$"Audio Settings 2/Audio balance/SFX".value = value

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

func _on_sfx_value_changed(value: float) -> void:
	Audio.set_bus_volume("SFX", value)


func _on_master_value_changed(value: float) -> void:
	Audio.set_bus_volume("Master", value)


func _on_music_value_changed(value: float) -> void:
	Audio.set_bus_volume("MUSIC", value)


func _on_dialogue_value_changed(value: float) -> void:
	Audio.set_bus_volume("Dialogue", value)


func _on_audio_pressed() -> void:
	pass # Replace with function body.
