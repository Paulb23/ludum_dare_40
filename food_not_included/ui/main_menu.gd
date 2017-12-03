extends Control

func _ready():
	get_node("play").connect("pressed", self, "play_pressed")
	get_node("exit").connect("pressed", self, "exit_pressed")
	get_node("play/play_deplay").connect("timeout", self, "load_play")

	get_node("music/music_vol").connect("value_changed", self, "music_vol")
	get_node("fx/fx_vol").connect("value_changed", self, "sfx_vol")

func play_pressed():
	get_node("loading").set_visible(true)
	get_node("AudioStreamPlayer").stop()
	get_node("play/play_deplay").start()

func load_play():
	Globals.set_scene("res://levels/main_level.tscn")

func exit_pressed():
	get_tree().quit()

func music_vol(val):
	AudioServer.set_bus_volume_db(1, val)
	pass

func sfx_vol(val):
	AudioServer.set_bus_volume_db(2, val)
	AudioServer.set_bus_volume_db(3, val)
	pass