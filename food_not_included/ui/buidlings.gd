extends Button

signal item_pressed

func _ready():
	get_node("algae_gen").connect("pressed", self, "algae_pressed")

func algae_pressed():
	emit_signal("item_pressed", "Algae Genorator")