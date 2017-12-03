extends Control

func _ready():
	get_node("continue").connect("pressed", self, "continue_pressed")
	get_node("exit").connect("pressed", self, "exit_pressed")
	get_node("menu").connect("pressed", self, "menu_pressed")

	get_node("music/music_vol").connect("value_changed", self, "music_vol")
	get_node("fx/fx_vol").connect("value_changed", self, "sfx_vol")

func continue_pressed():
	visible = false
	get_tree().set_pause(false)

func exit_pressed():
	get_tree().quit()

func menu_pressed():
	visible = false
	get_tree().set_pause(false)
	Globals.set_scene("res://ui/main_menu.tscn")

func music_vol(val):
	AudioServer.set_bus_volume_db(1, val)
	pass

func sfx_vol(val):
	AudioServer.set_bus_volume_db(2, val)
	AudioServer.set_bus_volume_db(3, val)
	pass