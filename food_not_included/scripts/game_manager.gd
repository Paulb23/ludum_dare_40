extends Node

var Job = preload("res://Job.gd")

var tile_size = 24

var process_jobs_timer
var jobs = []
var waiting_wokers = []

func _ready():
	process_jobs_timer = Timer.new()
	process_jobs_timer.set_wait_time(1)
	process_jobs_timer.set_one_shot(false)
	process_jobs_timer.start()
	process_jobs_timer.connect("timeout", self, "process_waiting_workers")
	add_child(process_jobs_timer)
	
	get_node("worker").connect("request_job", self, "add_wating_worker")
	get_node("worker").connect("request_path", self, "get_path")
	
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
	worker.assign_path(get_node("navigation").get_simple_path(worker.position, tile))

func _input(event):
	if (event is InputEventMouseButton):
		var tile = Vector2(int(event.position.x) / tile_size, int(event.position.y) / tile_size)
		if (event.is_action_released("left_click")):
			var job = Job.new("Move to " + String(tile), Job.Type.MOVE, tile)
			create_job(job)
		if (event.is_action_released("right_click")):
			var job = Job.new("Mining " + String(tile), Job.Type.MINE, tile)
			create_job(job)