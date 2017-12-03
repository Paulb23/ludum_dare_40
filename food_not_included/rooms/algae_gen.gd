extends Node2D

var built = false

func _physics_process(delta):
	if (!built):
		get_node("sprite").play("building")
		return
	get_node("sprite").play("active")

static func get_tile_size():
	return Vector2(3, 2)