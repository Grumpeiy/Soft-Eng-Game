extends RigidBody2D

var snap_target: Vector2 = Vector2.ZERO
var should_snap: bool = false
var was_moving: bool = false
var sfx: AudioStreamPlayer

func _ready():
	sfx = AudioStreamPlayer.new()
	sfx.stream = load("res://Sounds/music/rock-sliding.mp3")  # update to your sfx path
	sfx.volume_db = -25.0
	if sfx.stream == null:
		print("ERROR: SFX file not found!")
	else:
		print("SFX loaded successfully")
	add_child(sfx)
	
func teleport_to(target: Vector2):
	snap_target = target
	should_snap = true
	freeze = false  # unfreeze so _integrate_forces runs

func _integrate_forces(state):
	if should_snap:
		should_snap = false
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0
		var t = state.transform
		t.origin = snap_target
		state.transform = t
		set_deferred("freeze", true) 
		
func _physics_process(_delta):
	if linear_velocity.length() > 1.0 and not was_moving:
		was_moving = true
		print("block moving, playing SFX")
		sfx.play()
	elif linear_velocity.length() <= 1.0:
		was_moving = false
		sfx.stop()
