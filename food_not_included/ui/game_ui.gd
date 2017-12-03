extends Control

enum Tool {
	NONE,
	REMOVE,
	BUILD_ALGAE_GEN,
	BUILD_ALGAE_TO_FOOD_GEN
}

signal use_tool

var current_selected = null
var mouse_icon

var tile_size = 24

var stone_count = 0
var food_count = 0
var plant_count = 0
var population = 0

func _ready():
	mouse_icon = get_node("mouse_icon")

	get_node("actions").connect("pressed", self, "actions_pressed")
	get_node("pause").connect("pressed", self, "paused_pressed")
	get_node("actions").connect("item_pressed", self, "actions_index_pressed")

	get_node("buildings").connect("pressed", self, "buildings_pressed")
	get_node("buildings").connect("item_pressed", self, "buildings_index_pressed")

	toggle_action_visible(false)
	toggle_buildings_visible(false)

func _input(event):
	if (event.is_action_pressed("pause")):
		paused_pressed()
	if (event.is_action_released("go_to_portal")):
		get_parent().focus_center()

func paused_pressed():
	if (!get_tree().is_paused()):
		get_tree().set_pause(true)
		get_node("pause_menu").visible = true
	else:
		get_node("pause_menu").visible = false
		get_tree().set_pause(false)

func _gui_input(event):
	if (event.is_action_released("left_click")):
		var cam_pos = get_parent().position
		var tile = Vector2(int(cam_pos.x + event.position.x) / tile_size, int(cam_pos.y + event.position.y) / tile_size)
		emit_signal("use_tool", tile)

	if (event.is_action_released("right_click")):
		current_selected = null
		mouse_icon.texture = null
		return

	## offset due to camera todo fix...
	if (event is InputEventMouseMotion):
		var cam_pos = get_parent().position
		var tile = Vector2(int(cam_pos.x + (event.position.x - cam_pos.x)) / tile_size, int(event.position.y) / tile_size)
		tile *= tile_size
		mouse_icon.set_position(tile)

func actions_pressed():
	toggle_action_visible(null)

func toggle_action_visible(force):
	for node in get_node("actions").get_children():
		if (force != null):
			node.visible = force
		else:
			node.visible = !node.visible

func actions_index_pressed(name):
	toggle_action_visible(false)
	if (name == "Clear Tile"):
		remove_tiles()

func buildings_pressed():
	toggle_buildings_visible(null)

func toggle_buildings_visible(force):
	for node in get_node("buildings").get_children():
		if (force != null):
			node.visible = force
		else:
			node.visible = !node.visible

func buildings_index_pressed(name):
	toggle_buildings_visible(false)
	if (name == "Algae Genorator"):
		place_algae_gen()
	if (name == "Algae to food Genorator"):
		place_algae_to_food_gen()

func remove_tiles():
	current_selected = Tool.REMOVE
	mouse_icon.texture = load("res://ui/buttons/remove_icon.png")

func place_algae_gen():
	current_selected = Tool.BUILD_ALGAE_GEN
	mouse_icon.texture = load("res://rooms/algae_gen_active.png")

func place_algae_to_food_gen():
	current_selected = Tool.BUILD_ALGAE_TO_FOOD_GEN
	mouse_icon.texture = load("res://rooms/algae_to_food_gen_active.png")

func update_ui():
	get_node("stone_sprite/stone_count").text = String(stone_count)
	get_node("food_sprite/food_count").text = String(food_count)
	get_node("plant_sprite/plant_count").text = String(plant_count)
	get_node("population_sprite/population_count").text = String(population)