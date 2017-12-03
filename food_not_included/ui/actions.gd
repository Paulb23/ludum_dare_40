extends Button

signal item_pressed


func _ready():
	get_node("remove").connect("pressed", self, "remove_pressed")

func remove_pressed():
	emit_signal("item_pressed", "Clear Tile")