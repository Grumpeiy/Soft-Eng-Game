extends Control

func _ready():
	visible = false
	$background.visible = false
	event_handler.battle_started.connect(Callable(self, "init"))
	
func init(character_name, lvl):
	visible = true
	$AnimationPlayer.play("fade_in")
	get_tree().paused = true
	$Panel/Label.text = "A wild %s lvl %s appears" % [character_name, lvl]

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_in":
		$AnimationPlayer.play("fade_out")
		$background.visible = true
		
		#PLAYER
		$background/Player.play("idle")
		
		#SKELETONN RAHHHH
		$background/Enemy.play("idle")
		$background/Enemy.flip_h = true
		
		$Panel/answer_button.grab_focus()
	
func _on_run_button_pressed():
	get_tree().paused = false
	visible = false
	$background.visible = false

func _on_answer_button_pressed():
	$Panel/Label.text = "You can't fight"
