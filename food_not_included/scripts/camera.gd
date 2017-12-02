extends Camera2D

var shakeTime = 0
var amount = 0
var speed = 5

func shake(time, amount):
	self.shakeTime = time
	self.amount = amount

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
		