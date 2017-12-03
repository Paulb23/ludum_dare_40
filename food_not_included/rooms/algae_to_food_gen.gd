extends Node2D

signal request_algae
signal food_created

var built = false


var food_created_timer
var request_timer
var creating_food = false

func _ready():
	food_created_timer = get_node("food_created_timer")
	food_created_timer.connect("timeout", self, "food_created")

	request_timer = get_node("request_timer")
	request_timer.connect("timeout", self, "request")
	get_node("sprite").play("building")

func request():
	if (built && !creating_food):
		print(get_name(), " requesting algae" )
		emit_signal("request_algae", self, 10)

func built():
	built = true;
	get_node("sprite").play("active")
	request_timer.start()

func food_created():
	emit_signal("food_created", 15)
	creating_food = false
	request_timer.start()

func give_algae(amount):
	if (amount != 0):
		print(get_name(), " recived algae" )
		creating_food = true
		food_created_timer.start()
	else:
		print(get_name(), " recived 0 algae waiting before rquesting again" )
		request_timer.start()

static func get_tile_size():
	return Vector2(3, 2)
