extends Control

enum Tool {
	NONE,
	REMOVE
}

signal use_tool

var current_selected = null
var mouse_icon

var tile_size = 24

func _ready():
	mouse_icon = get_node("mouse_icon")

	get_node("actions").connect("pressed", self, "actions_pressed")
	get_node("actions").connect("item_pressed", self, "actions_index_pressed")

	toolgle_action_visible(false)

func _gui_input(event):
	if (event.is_action_released("left_click")):
		var cam_pos = get_parent().position
		var tile = Vector2(int(cam_pos.x + event.position.x) / tile_size, int(cam_pos.y + event.position.y) / tile_size)
		emit_signal("use_tool", tile)

	if (event.is_action_released("right_click")):
		current_selected = null
		mouse_icon.texture = null
		return

	if (event is InputEventMouseMotion):
		var tile = Vector2(int(get_position().x + event.position.x) / tile_size, int(event.position.y) / tile_size)
		tile *= tile_size
		tile.x += tile_size / 2
		tile.y += tile_size / 2
		mouse_icon.set_position(tile)

func actions_pressed():
	toolgle_action_visible(null)

func toolgle_action_visible(force):
	for node in get_node("actions").get_children():
		if (force != null):
			node.visible = force
		else:
			node.visible = !node.visible

func actions_index_pressed(name):
	toolgle_action_visible(false)
	if (name == "Clear Tile"):
		remove_tiles()

func remove_tiles():
	current_selected = Tool.REMOVE
	mouse_icon.texture = load("res://ui/buttons/remove_icon.png")