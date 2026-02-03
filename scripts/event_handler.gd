extends Node2D

# This line tells Godot to stop checking for unused signals in this file
@warning_ignore("unused_signal")

signal battle_started(enemy_node, character_name, lvl)
signal battle_finished()
