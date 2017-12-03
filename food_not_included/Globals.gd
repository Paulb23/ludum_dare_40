extends Node2D

const screen_width = 1024
const screen_height = 576
const tile_size = 24

var varibles = {}

var currernt_scene = null

func _ready():
	currernt_scene = get_tree().get_root().get_child(get_tree().get_root().get_child_count() -1)
	set_screen_res(screen_width, screen_height)
	set_globals()

func set_scene(new_scene_path):
	currernt_scene.queue_free()
	currernt_scene.set_name( currernt_scene.get_name() + "_deleted" )
	var new_scene = ResourceLoader.load(new_scene_path)
	currernt_scene = new_scene.instance()
	get_tree().get_root().add_child(currernt_scene)

func set_screen_res(width, height):
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, Vector2(width , height))

func set_globals():
	Globals.set("SCREEN_WIDTH", screen_width)
	Globals.set("SCREEN_HEIGHT", screen_height)
	Globals.set("TILE_SIZE", tile_size)

func set(name, value):
	varibles[name] = value

func get(name):
	if varibles.has(name):
		return varibles[name]
	else:
		return ""