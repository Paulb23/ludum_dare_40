extends Node2D

var Job = preload("res://Job.gd")

signal request_job
signal request_path
signal hit_tile
signal build_tile
signal dead
signal eat

var delta
var tile_size = 24
var portal_tile

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

var building = false
var building_speed = 10
var building_timer
var can_build = true;

var eating = false
var eating_wait_timer
var eating_timer
var full = true
var dead = false
var attemps_to_eat = 0

var name = "worker"

func _ready():
	mining_timer = get_node("mining_timer")
	mining_timer.connect("timeout", self, "set_can_mine")

	building_timer = get_node("building_timer")
	building_timer.connect("timeout", self, "set_can_build")

	eating_timer = get_node("eating_timer")
	eating_timer.connect("timeout", self, "finished_eating")

	eating_wait_timer = get_node("eating_wait_timer")
	eating_wait_timer.connect("timeout", self, "set_can_eat")

func _physics_process(delta):
	self.delta = delta

	if dead:
		return

	if (eating):
		if (!at_target):
			move_to_position(portal_tile)
		elif (eating_timer.is_stopped()):
			get_node("eating").play()
			emit_signal("eat", self, 10)
			eating_timer.start()
		return

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
					if (at_target && self.get_position().distance_to(assigned_job.pos * tile_size) < speed):
						print(name + " Starting to mine")
						mining = true
					elif(at_target):
						print(name + " job is out of reach, quitting..")
						has_job = false
				if (mining && can_mine):
					if (!get_node("mining").playing):
						get_node("mining").play()
					print(name + " attempts to hits tile " + String(assigned_job.pos))
					emit_signal("hit_tile", self, assigned_job.pos, mining_dmg);
					can_mine = false
					mining_timer.start()
					if (assigned_job.pos.y * tile_size < self.get_position().y):
						get_node("sprite").play("mine_up")
					else:
						get_node("sprite").play("mine_down")
			Job.Type.BUILD:
				if (!at_target):
					move_to_position(assigned_job.pos)
					if (at_target && self.get_position().distance_to(assigned_job.pos * tile_size) < speed):
						print(name + " Starting to build")
						building = true
					elif(at_target):
						print(name + " job is out of reach, quitting..")
						has_job = false
				if (building && can_build):
					if (!get_node("mining").playing):
						get_node("mining").play()
					print(name + " attempts to build tile " + String(assigned_job.pos))
					emit_signal("build_tile", self, assigned_job.pos, building_speed);
					can_build = false
					building_timer.start()
					if (assigned_job.pos.y * tile_size < self.get_position().y):
						get_node("sprite").play("mine_up")
					else:
						get_node("sprite").play("mine_down")
	else:
		get_node("sprite").play("down")

func move_to_position(target):
	if (!has_path && !waiting_for_path):
		print(name + " is requesting navigation path")
		waiting_for_path = true
		emit_signal("request_path", self, target)
	if (has_path):
		if (!get_node("walk").playing):
			get_node("walk").play()
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
		if (target_pos.y + 0.5 < self.get_position().y):
			get_node("sprite").play("up")
		else:
			get_node("sprite").play("down")
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

func set_can_build():
	can_build = true

func set_can_eat():
	print(name + " is going to eat!")
	at_target = false
	eating = true

func finished_eating():
	if (full):
		at_target = false
		eating = false
		attemps_to_eat = 0
		eating_wait_timer.start()
	else:
		attemps_to_eat += 1
		if (attemps_to_eat > 3):
			dead = true
			print(name + " has starved to death.")
			emit_signal("dead", self)
			get_node("death").play()

func notify_tile_removed():
	match assigned_job.type:
		Job.Type.MINE:
			print(name + " removed a tile")
			mining = false
			has_job = false;
		Job.Type.BUILD:
			print(name + " finished building")
			building = false
			has_job = false;