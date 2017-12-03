extends Control

enum Tool {
	NONE,
	REMOVE
}

signal use_tool

var current_selected = null
var mouse_icon

var tile_size = 24

var stone_count = 0
var food_count = 0
var population = 0

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

	## offset dur ot camera todo fix...
	if (event is InputEventMouseMotion):
		var cam_pos = get_parent().position
		var tile = Vector2(int(get_position().x + event.position.x) / tile_size, int(event.position.y) / tile_size)
		tile *= tile_size
		tile.x += (tile_size / 2)
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

func update_ui():
	get_node("stone_sprite/stone_count").text = String(stone_count)
	get_node("food_sprite/food_count").text = String(food_count)
	get_node("population_sprite/population_count").text = String(population)