extends Control

# ── HOW TO SET UP IN THE INSPECTOR ───────────────────────────────────────────
# 1. Set each QuestStep position by clicking the array elements below
# 2. The marker advances automatically when you call quest_marker.advance_step()
#    from your NPC scripts and puzzle completion scripts
#
# Step order matches the questline timeline:
#   0 → NPC (start of "Where's My Water")
#   1 → Wizard's house ("Wizard's Training" starts)
#   2 → Underground entrance (puzzle)
#   3 → NPC again (return after puzzle, end of "Wizard's Training")
#   4 → NPC again ("Fetching Bones" starts — same NPC, new quest)
#   5 → Skeleton area (fight the 3 skeletons)
#   6 → NPC (return after all 3 skeletons — quest complete)
#   7 → (empty / hidden — all quests done)
# ─────────────────────────────────────────────────────────────────────────────

@export var step_positions : Array[Vector2] = [
	Vector2.ZERO,  # Step 0 — NPC (Where's My Water)
	Vector2.ZERO,  # Step 1 — Wizard's house
	Vector2.ZERO,  # Step 2 — Underground entrance
	Vector2.ZERO,  # Step 3 — NPC (return after puzzle)
	Vector2.ZERO,  # Step 4 — NPC (Fetching Bones)
	Vector2.ZERO,  # Step 5 — Skeleton area
	Vector2.ZERO,  # Step 6 — NPC (final return)
]

@onready var texture_rect = $TextureRect

const ARROW = preload("res://Art/Arrow.png")
const CROSS = preload("res://Art/Cross.png")

var camera_zoom         : Vector2
var current_step        : int = 0
var quest_target_position : Vector2 = Vector2.ZERO

# ─────────────────────────────────────────────────────────────────────────────
func _ready():
	camera_zoom = get_viewport().get_camera_2d().zoom
	_load_step_from_save()
	_apply_current_step()

# ─────────────────────────────────────────────────────────────────────────────
# Call this from NPC scripts and puzzle scripts when an interaction completes
# ─────────────────────────────────────────────────────────────────────────────
func advance_step():
	current_step += 1
	PlayerData.set_save_value("quest_marker_step", current_step)
	print("QuestMarker: advanced to step ", current_step)
	_apply_current_step()

# ─────────────────────────────────────────────────────────────────────────────
# Restore step from save file so progress survives reloading
# ─────────────────────────────────────────────────────────────────────────────
func _load_step_from_save():
	current_step = PlayerData.get_save_value("quest_marker_step", 0)

func _apply_current_step():
	if current_step >= step_positions.size():
		# All quests done — hide the marker
		visible = false
		quest_target_position = Vector2.ZERO
		return

	visible = true
	quest_target_position = step_positions[current_step]
	print("QuestMarker: now pointing to step %d at %s" % [current_step, quest_target_position])

# ─────────────────────────────────────────────────────────────────────────────
# ARROW LOGIC (unchanged from your original)
# ─────────────────────────────────────────────────────────────────────────────
func _process(_delta):
	if quest_target_position == Vector2.ZERO:
		return

	var quest_target_screen_position = (quest_target_position - _get_camera_rect().position) * camera_zoom

	if _target_on_screen():
		texture_rect.visible = false
	else:
		texture_rect.visible = true
		texture_rect.texture = ARROW
		_set_screen_position(quest_target_screen_position)
		_rotate_to_target()

func _get_camera_rect():
	var pos         = get_viewport().get_camera_2d().get_screen_center_position()
	var screen_size = get_viewport_rect().size / camera_zoom
	return Rect2(pos - screen_size / 2, screen_size)

func _target_on_screen():
	return _get_camera_rect().has_point(quest_target_position)

func _set_screen_position(screen_target_position):
	var screen_size  = get_viewport_rect().size
	var borderOffSet = 50
	var target_pos   = screen_target_position

	if target_pos.x < borderOffSet:               target_pos.x = borderOffSet
	if target_pos.x > screen_size.x - borderOffSet: target_pos.x = screen_size.x - borderOffSet
	if target_pos.y < borderOffSet:               target_pos.y = borderOffSet
	if target_pos.y > screen_size.y - borderOffSet: target_pos.y = screen_size.y - borderOffSet

	global_position = target_pos

func _rotate_to_target():
	var current_position = get_viewport().get_camera_2d().get_screen_center_position()
	var direction        = (quest_target_position - current_position).normalized()
	rotation             = direction.angle()
