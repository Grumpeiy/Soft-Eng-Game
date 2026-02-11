extends Node2D

func _ready():
	$fade_transition/AnimationPlayer.play("fade_out")
