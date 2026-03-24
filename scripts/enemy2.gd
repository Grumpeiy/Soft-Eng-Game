extends CharacterBody2D

@onready var walk: AudioStreamPlayer2D = $walk

var character_name : String = "Skeleton"
var lvl            : int    = 25
var speed          = 50
var player_chase   = false
var player         = null

const QUEST_ID    = 3
const ENEMY_NUM   = 2   # ← 1 = easy questions

func _physics_process(delta):
	if player_chase and player:
		var direction = (player.position - position).normalized()
		var collision = move_and_collide(direction * speed * delta)
		if direction.x < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("walk")
		if not walk.playing:
			walk.play()
		if collision:
			var body = collision.get_collider()
			if body.is_in_group("player"):
				player_chase = false
				event_handler.battle_started.emit(
					self, character_name, lvl,
					QUEST_ID, PlayerData.lrn, ENEMY_NUM
				)
	else:
		$AnimatedSprite2D.play("idle")

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player       = body
		player_chase = true

func _on_detection_area_body_exited(body):
	if body == player:
		player       = null
		player_chase = false
