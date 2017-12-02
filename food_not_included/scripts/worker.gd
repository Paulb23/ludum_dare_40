extends Node

var Job = preload("res://Job.gd")

signal request_job
signal request_path
signal hit_tile

var delta
var tile_size = 24

var waiting_for_job = false
var has_job = false
var assigned_job

var speed = 50
var has_path = false
var waiting_for_path = false
var at_target = false
var path_offset = 0
var path

var mining = false
var mining_dmg = 10
var mining_timer
var can_mine = true;

var name = "worker"

func _ready():
	mining_timer = get_node("mining_timer")
	mining_timer.connect("timeout", self, "set_can_mine")

func _physics_process(delta):
	self.delta = delta

	if (!has_job && !waiting_for_job):
		print(name + " is requesting a new job")
		waiting_for_job = true
		emit_signal("request_job", self)

	if (has_job):
		match assigned_job.type:
			Job.Type.MOVE:
				if (!at_target):
					move_to_position(assigned_job.pos)
				else:
					has_job = false
			Job.Type.MINE:
				if (!at_target):
					move_to_position(assigned_job.pos)
					if (at_target && self.get_position().distance_to(assigned_job.pos * tile_size) < 25):
						print(name + " Starting to mine")
						mining = true
					elif(at_target):
						print(name + " job is out of reach, quitting..")
						has_job = false
				if (mining && can_mine):
					print(name + " attempts to hits tile " + String(assigned_job.pos))
					emit_signal("hit_tile", self, assigned_job.pos, mining_dmg);
					can_mine = false
					mining_timer.start()


func move_to_position(target):
	if (!has_path && !waiting_for_path):
		print(name + " is requesting navigation path")
		waiting_for_path = true
		emit_signal("request_path", self, target)
	if (has_path):
		if (path.size() <= 0):
			has_path = false;
			at_target = true;
			print(name + " has reached their target")
			return

		var target_pos = path[path_offset]
		var distance = self.get_position().distance_to(target_pos)

		if (distance < speed * delta):
			path_offset += 1

			if (path_offset == path.size()):
				has_path = false;
				at_target = true;
				print(name + " has reached their target")
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
	print(name + " has picked up job " + String(new_job.name) + " of type " + String(new_job.type))
	assigned_job = new_job
	has_job = true
	waiting_for_job = false
	at_target = false

func assign_path(new_path):
	print(name + " has recived navigation path ")
	path = new_path
	path_offset = 0
	has_path = true
	waiting_for_path = false

func set_can_mine():
	can_mine = true

func notify_tile_removed():
	match assigned_job.type:
		Job.Type.MINE:
			print(name + " removed a tile ")
			mining = false
			has_job = false;