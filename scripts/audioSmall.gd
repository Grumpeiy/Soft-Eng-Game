extends Node2D

const ACCESSIBILITY_SCENE = "res://scenes/Options/accessbilitySmall.tscn"
const GAMEPLAY_SCENE = "res://scenes/Options/GameplaySmall.tscn"
const OTHER_SCENE = "res://scenes/Options/OtherSmall.tscn"
const MAIN_MENU_SCENE = "res://scenes/options/main_menuSmall.tscn"

func _ready():
	Audio.volume_changed.connect(_on_volume_changed)

	$"AudioSmall/SettingsSmall/Master".value = Audio.master_volume
	$"AudioSmall2/BalanceSmall/Music".value = Audio.music_volume
	$"AudioSmall2/BalanceSmall/SFX".value = Audio.sfx_volume
	$"AudioSmall2/BalanceSmall/Dialogue".value = Audio.dialogue_volume
	
func _on_volume_changed(bus_name, value):
	match bus_name:
		"Master":
			$"AudioSmall/SettingsSmall/Master".value = value
		"MUSIC":
			$"AudioSmall2/BalanceSmall/Music".value = value
		"SFX":
			$"AudioSmall2/BalanceSmall/SFX".value = value
		"Dialogue":
			$"AudioSmall2/BalanceSmall/Dialogue".value = value

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

func _on_master_small_value_changed(value: float) -> void:
	Audio.set_bus_volume("Master", value)


func _on_music_small_value_changed(value: float) -> void:
	Audio.set_bus_volume("MUSIC", value)


func _on_dialogue_small_value_changed(value: float) -> void:
	Audio.set_bus_volume("Dialogue", value)


func _on_sfx_value_changed(value: float) -> void:
	Audio.set_bus_volume("SFX", value)
