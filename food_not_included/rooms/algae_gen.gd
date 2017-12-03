extends Node2D

signal algae_created

var built = false

var algae_created_timer

func _ready():
	algae_created_timer = get_node("algae_created_timer")
	algae_created_timer.connect("timeout", self, "algae_created")
	get_node("sprite").play("building")

func built():
	built = true;
	get_node("sprite").play("active")
	algae_created_timer.start()

func algae_created():
	emit_signal("algae_created", 3)
	algae_created_timer.start()

static func get_tile_size():
	return Vector2(3, 2)