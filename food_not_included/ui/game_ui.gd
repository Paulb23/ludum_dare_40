extends Control

enum Tool {
	NONE,
	REMOVE
}

var current_selected = null
var mouse_icon

var tile_size = 24

func _ready():
	mouse_icon = get_node("mouse_icon")
	get_node("remove_tiles").connect("pressed", self, "remove_tiles")

func _input(event):
	if (event.is_action_released("right_click")):
		current_selected = null
		mouse_icon.texture = null
		return

	if (event is InputEventMouseMotion):
		var tile = Vector2(int(event.position.x) / tile_size, int(event.position.y) / tile_size)
		tile *= tile_size
		tile.x += tile_size / 4
		tile.y += tile_size / 4
		mouse_icon.set_position(tile)

func remove_tiles():
	current_selected = Tool.REMOVE
	mouse_icon.texture = load("res://ui/buttons/remove_icon.png")

func in_ui(y):
	return y > get_node("bottom_bar").get_position().y