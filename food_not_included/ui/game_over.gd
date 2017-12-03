extends Control

func _ready():
	get_node("retry").connect("pressed", self, "play_pressed")
	get_node("menu").connect("pressed", self, "menu_pressed")
	get_node("exit").connect("pressed", self, "exit_pressed")

func play_pressed():
	Globals.set_scene("res://levels/main_level.tscn")

func menu_pressed():
	Globals.set_scene("res://ui/main_menu.tscn")

func exit_pressed():
	get_tree().quit()