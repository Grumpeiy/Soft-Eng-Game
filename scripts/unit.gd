extends Node2D
class_name TurnQueue

var active_character

func initialize():
	if get_child_count() == 0:
		print("Error: No units in TurnQueue!")
		return
	
	# Start with the first child
	active_character = get_child(0)
	play_turn()

func play_turn():
	# Safety Check: If the active character died or was removed, restart loop
	if not is_instance_valid(active_character):
		if get_child_count() > 0:
			active_character = get_child(0)
		else:
			print("Battle Over!")
			return

	# Play the turn and wait for it to finish
	await active_character.play_turn()
	
	# Calculate next index
	var current_index = active_character.get_index()
	var new_index = (current_index + 1) % get_child_count()
	
	active_character = get_child(new_index)
	
	play_turn()
