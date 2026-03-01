extends Node

signal volume_changed(bus_name, value)

var master_volume := 2.0
var music_volume := 2.0
var sfx_volume := 2.0
var dialogue_volume := 2.0

func set_bus_volume(bus_name: String, value: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	var normalized_value = value / 2.0

	if normalized_value <= 0.0:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(normalized_value))

	match bus_name:
		"Master":
			master_volume = value
		"MUSIC":
			music_volume = value
		"SFX":
			sfx_volume = value
		"Dialogue":
			dialogue_volume = value

	emit_signal("volume_changed", bus_name, value)
