extends Control

func _ready():
	get_node("retry").connect("pressed", self, "play_pressed")
	get_node("menu").connect("pressed", self, "menu_pressed")
	get_node("exit").connect("pressed", self, "exit_pressed")
	get_node("retry/retry_delay").connect("timeout", self, "load_play")

	get_node("pop").text = "Max Population: " + String(Globals.get("max_pop"))
	get_node("stone").text = "Stone Collected: " + String(Globals.get("stone_collected"))
	get_node("food").text = "Food Collected: " + String(Globals.get("food_collected"))
	get_node("algea").text = "Algea Collected: " + String(Globals.get("algea_collected"))

func play_pressed():
	get_node("loading").set_visible(true)
	get_node("AudioStreamPlayer").stop()
	get_node("retry/retry_delay").start()

func menu_pressed():
	Globals.set_scene("res://ui/main_menu.tscn")

func load_play():
	Globals.set_scene("res://levels/main_level.tscn")

func exit_pressed():
	get_tree().quit()