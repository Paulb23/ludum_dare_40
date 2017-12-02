extends Node

var Job = preload("res://Job.gd")

signal request_job
signal request_path

var delta

var waiting_for_job = false
var has_job = false
var assigned_job

var speed = 50
var has_path = false
var waiting_for_path = false
var at_target = false
var path_offset = 0
var path

var mining_timer
var can_mine = true;

func _ready():
	mining_timer = get_node("mining_timer")
	mining_timer.connect("timeout", self, "set_can_mine")
	
func _physics_process(delta):
	self.delta = delta 
	
	if (!has_job && !waiting_for_job):
		print(get_name() + " is requesting a new job")
		waiting_for_job = true
		emit_signal("request_job", self)
	
	if (!has_job):
		return
	match assigned_job.type:
		Job.Type.MOVE:
			if (!at_target):
				move_to_position(assigned_job.pos)
			else:
				has_job = false
		Job.Type.MINE:
			if (!at_target):
				move_to_position(assigned_job.pos)
			elif (can_mine):
				print("mining")
				can_mine = false
				mining_timer.start()
				
				
func move_to_position(target):
	if (!has_path && !waiting_for_path):
		print(get_name() + " is requesting navigation path")
		waiting_for_path = true
		emit_signal("request_path", self, target)
	if (has_path):
		var target_pos = path[path_offset]
		var distance = self.get_position().distance_to(target_pos)
		
		if (distance < speed * delta):
			path_offset += 1
			
			if (path_offset == path.size()):
				has_path = false;
				at_target = true;
				print(get_name() + " has reached their target")
		else:
			var delta_x = target_pos.x - self.get_position().x
			var delta_y = target_pos.y - self.get_position().y
			var ratio = speed / distance
			var x_move = (ratio * delta_x) * delta
			var y_move = (ratio * delta_y) * delta
			var new_x_pos = x_move + self.get_position().x
			var new_y_pos = y_move + self.get_position().y
			target_pos = Vector2(new_x_pos, new_y_pos)
		set_position(target_pos)

func assign_job(new_job):
	print(get_name() + " has picked up job " + String(new_job.name) + " of type " + String(new_job.type))
	assigned_job = new_job
	has_job = true
	waiting_for_job = false
	at_target = false
	
func assign_path(new_path):
	print(get_name() + " has recived navigation path ")
	path = new_path
	path_offset = 0
	has_path = true
	waiting_for_path = false
	
func set_can_mine():
	can_mine = true