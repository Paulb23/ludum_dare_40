extends Camera2D

var shakeTime = 0
var amount = 0
var speed = 5
var world_size = 0

func shake(time, amount):
	self.shakeTime = time
	self.amount = amount

func focus_center():
	var x_off = get_viewport().get_visible_rect().end.x / 2
	var y_off = get_viewport().get_visible_rect().end.y / 2 
	var size = world_size / 2
	self.position = Vector2(size - x_off, size - y_off)

func _physics_process(delta):
	if (shakeTime > 0):
		shakeTime -= 1
		set_offset(Vector2(rand_range(0, amount), rand_range(0, amount)))
	else:
		set_offset(Vector2(0,0))
		
	var direction = Vector2(0, 0)
	if (Input.is_action_pressed("camera_up")):
		direction += Vector2(0, -speed)
	if (Input.is_action_pressed("camera_down")):
		direction += Vector2(0, speed)
	if (Input.is_action_pressed("camera_left")):
		direction += Vector2(-speed, 0)
	if (Input.is_action_pressed("camera_right")):
		direction += Vector2(speed, 0)
	self.position += direction
	
	if (position.x < 0):
		position.x = 0
		
	if (position.y < 0):
		position.y = 0
		
	if (position.x + get_viewport().get_visible_rect().end.x > world_size):
		position.x = world_size - get_viewport().get_visible_rect().end.x
		
	if (position.y + get_viewport().get_visible_rect().end.y > world_size):
		position.y = world_size - get_viewport().get_visible_rect().end.y