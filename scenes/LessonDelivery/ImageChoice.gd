extends Node2D

signal image_clicked(node)

@onready var border = $ColorRect
@onready var area = $Area2D

func _ready():
	print("Children of ", name, ":")
	for child in get_children():
		print(" - ", child.name, " (", child.get_class(), ")")
	border.visible = false
	border.size = Vector2(98, 50)
	border.position = Vector2(-49, -25)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = Color(1, 1, 0, 1)  # yellow, change if needed
	border.add_theme_stylebox_override("panel", style)
	
	area.mouse_entered.connect(_on_hover)
	area.mouse_exited.connect(_on_exit)

func _on_hover():
	border.visible = true

func _on_exit():
	border.visible = false

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if border.visible:
			image_clicked.emit(self)
