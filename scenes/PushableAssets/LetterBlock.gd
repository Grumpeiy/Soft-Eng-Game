extends RigidBody2D

var snap_target: Vector2 = Vector2.ZERO
var should_snap: bool = false

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
