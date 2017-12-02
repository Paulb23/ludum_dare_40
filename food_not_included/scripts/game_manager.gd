extends Node

var Job = preload("res://Job.gd")
var UI = preload("res://ui/game_ui.gd")

var tile_size = 24
var world 

var process_jobs_timer
var jobs = []
var waiting_wokers = []

var ui 

func _ready():
	world = get_node("navigation/world")
	process_jobs_timer = Timer.new()
	process_jobs_timer.set_wait_time(1)
	process_jobs_timer.set_one_shot(false)
	process_jobs_timer.start()
	process_jobs_timer.connect("timeout", self, "process_waiting_workers")
	add_child(process_jobs_timer)
	
	ui = get_node("camera/game_ui")
	
	for worker in get_node("workers").get_children():
		worker.connect("request_job", self, "add_wating_worker")
		worker.connect("request_path", self, "get_path")
		worker.connect("hit_tile", self, "hit_tile")
	
func process_waiting_workers():
	var i = 0
	while (i < waiting_wokers.size()):
		var job = get_job()
		if (job.type != Job.Type.NONE):
			print("assiging " + waiting_wokers[i].get_name() + " to " + job.name)
			waiting_wokers[i].assign_job(job)
			waiting_wokers.remove(i)
		i += 1
	
func get_job():
	if (jobs.size() <= 0):
		return Job.new("null", Job.Type.NONE, Vector2(0,0))
	return jobs.pop_back()
	
func create_job(job):
	print("new job created " + job.name)
	jobs.push_front(job)

func add_wating_worker(worker):
	print("adding " + worker.get_name() + " to list of unemployed workers")
	waiting_wokers.push_front(worker)

func get_path(worker, path_to):
	var tile = Vector2(path_to.x * tile_size, path_to.y * tile_size)
	get_node("navigation").update()
	worker.assign_path(get_node("navigation").get_simple_path(worker.position, tile))

func hit_tile(worker, tile, dmg):
	var tile_id  = world.get_cell(tile.x, tile.y)
	if (tile_id == 7):
		if (!world.has_meta(String(tile))):
			world.set_meta(String(tile), String(50))
		world.set_meta(String(tile), String(int(world.get_meta(String(tile))) - dmg))
		print(worker.get_name() + " hits tile " + String(tile) + " for " + String(dmg))
		if (int(world.get_meta(String(tile))) <= 0):
			worker.notify_tile_removed()
			world.set_cell(tile.x, tile.y, 0)
	else:
		worker.notify_tile_removed()

func _input(event):
	if (event is InputEventMouseButton):
		var tile = Vector2(int(event.position.x) / tile_size, int(event.position.y) / tile_size)
		if (event.is_action_released("left_click")):
			match ui.current_selected:
				UI.Tool.REMOVE:
					var job = Job.new("Mining " + String(tile), Job.Type.MINE, tile)
					create_job(job)