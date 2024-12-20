extends PanelContainer

@onready var world = get_tree().root.get_node("world")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("Control/CheckButton").button_pressed = false
	world.useColor = false
	get_node("Control/Hbox/LineEdit").text = "5"
	world.numItterations = 7
	get_node("Control/circleSize/sizeEdit").text = "0.5"
	world.defaultCircle = [[Vector2(1.0/2.0, 0), 2.0, 1], [Vector2(-1.0/2.0, 0), 2.0, 1]]
	world.defaultCalculate = [[[Vector2(0,0), -1.0], world.defaultCircle[0], world.defaultCircle[1]]]
	world.reset()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_check_button_toggled(toggled_on: bool) -> void:
	world.useColor = toggled_on


func _on_size_edit_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float:
		var radius: float = clampf(new_text.to_float(), 0.1, 0.9)
		var rad2: float = 1.0 - radius
		var pos: Vector2 = Vector2(-1.0 + radius, 0.0)
		var pos2: Vector2 = Vector2(-1.0 + radius + radius + rad2, 0.0)
		world.defaultCircle = [[pos, 1.0/radius, 1], [pos2, 1.0/rad2, 1]]
		world.defaultCalculate = [[[Vector2(0,0), -1.0], world.defaultCircle[0], world.defaultCircle[1]]]
		world.reset()


func _on_line_edit_text_submitted(new_text: String) -> void:
		if new_text.is_valid_int():
			world.numItterations = clampi(new_text.to_int(), 0, 20)
			print(world.numItterations)
			world.reset()
