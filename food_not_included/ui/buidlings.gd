extends Button

signal item_pressed

func _ready():
	get_node("algae_gen").connect("pressed", self, "algae_pressed")
	get_node("algae_to_food_gen").connect("pressed", self, "algae_to_food_pressed")

func algae_pressed():
	emit_signal("item_pressed", "Algae Genorator")

func algae_to_food_pressed():
	emit_signal("item_pressed", "Algae to food Genorator")
