extends CharacterBody2D

# Set these in the Inspector per enemy instance in the scene
@export var enemy_number : int = 1   # 1=easy, 2=normal, 3=hard questions
@export var quest_id     : int = 3   # Fetching Bones = quest 3

@onready var walk: AudioStreamPlayer2D = $walk

var speed        = 50
var player_chase = false
var player       = null

const NAMES  = {1: "Skeleton", 2: "Skeleton", 3: "Skeleton"}
const LEVELS = {1: 10, 2: 30, 3: 49}

func _ready():
	# Don't spawn if already defeated this session
	var enemy_key = "skeleton_%d" % enemy_number
	if PlayerData.is_enemy_defeated(enemy_key):
		queue_free()

func _physics_process(delta):
	if player_chase and player:
		var direction = (player.position - position).normalized()
		var collision = move_and_collide(direction * speed * delta)

		$AnimatedSprite2D.flip_h = direction.x < 0
		$AnimatedSprite2D.play("walk")

		if not walk.playing:
			walk.play()

		if collision:
			var body = collision.get_collider()
			if body.is_in_group("player"):
				player_chase = false
				event_handler.battle_started.emit(
					self,
					NAMES.get(enemy_number, "Skeleton"),
					LEVELS.get(enemy_number, 1),
					quest_id,
					PlayerData.lrn,
					enemy_number
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
