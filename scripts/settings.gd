extends Node

signal capitalization_changed

var capitalization_enabled := true:
	set(value):
		capitalization_enabled = value
		emit_signal("capitalization_changed")
