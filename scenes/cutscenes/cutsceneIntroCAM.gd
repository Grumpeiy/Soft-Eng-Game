extends Camera2D
@export var tilemap:TileMapLayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_anchor_mode(Camera2D.ANCHOR_MODE_DRAG_CENTER)
	set_zoom(Vector2(0.9,0.8))
	pass # Replace with functio n body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
