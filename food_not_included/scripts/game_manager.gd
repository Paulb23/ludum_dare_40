extends Node

var Job = preload("res://Job.gd")
var Names = preload("res://names.gd")
var UI = preload("res://ui/game_ui.gd")
var noise = preload("res://libs/softnoise.gd")
var Portal = preload("res://rooms/home_portal.tscn")
var Worker = preload("res://wokers/worker.tscn")

var soft_noise

var stone_count = 0

var tile_size = 24

var world_size = 100

var world
var tile_set

var process_jobs_timer
var jobs = []
var waiting_wokers = []

var ui
var buildings
var workers
var portal

func _ready():
	rand_seed(OS.get_unix_time())
	buildings = get_node("buildings")
	workers = get_node("workers")
	world = get_node("navigation/world")
	tile_set = world.tile_set
	soft_noise = noise.SoftNoise.new(OS.get_unix_time())
	create_world()
	process_jobs_timer = Timer.new()
	process_jobs_timer.set_wait_time(1)
	process_jobs_timer.set_one_shot(false)
	process_jobs_timer.start()
	process_jobs_timer.connect("timeout", self, "process_waiting_workers")
	add_child(process_jobs_timer)

	get_node("camera").world_size = world_size * tile_size
	get_node("camera").focus_center()
	ui = get_node("camera/game_ui")
	ui.connect("use_tool", self, "use_tool")

func create_worker():
	print("Creating new worker")
	var worker = Worker.instance()
	worker.name = Names.get_name()
	worker.set_position(portal.get_position() - Vector2(-tile_size * 2, -tile_size * 2))
	worker.connect("request_job", self, "add_wating_worker")
	worker.connect("request_path", self, "get_path")
	worker.connect("hit_tile", self, "hit_tile")
	workers.add_child(worker)

func process_waiting_workers():
	var i = waiting_wokers.size() - 1
	while (i > -1):
		var job = get_job()
		if (job):
			print("assiging " + waiting_wokers[i].name + " to " + job.name)
			waiting_wokers[i].assign_job(job)
			waiting_wokers.remove(i)
		i -= 1

func get_job():
	if (jobs.size() <= 0):
		return null
	return jobs.pop_back()

func create_job(job):
	print("new job created " + job.name)
	jobs.push_front(job)

func add_wating_worker(worker):
	print("adding " + worker.name + " to list of unemployed workers")
	waiting_wokers.push_front(worker)

func get_path(worker, path_to):
	get_node("navigation").update()

	for x in range(-1, 2):
		for y in range(-1, 2):
			if (is_walkable_tile(world.get_cell(path_to.x + x, path_to.y + y))):
				var tile = Vector2(((path_to.x + x) * tile_size) + (tile_size / 2), ((path_to.y + y) * tile_size) + (tile_size / 2))
				var path = get_node("navigation").get_simple_path(worker.position, tile)
				if (path.size() > 0):
					worker.assign_path(path)
					return
	worker.assign_path([])

func hit_tile(worker, tile, dmg):
	var tile_id  = world.get_cell(tile.x, tile.y)
	if (tile_set.tile_get_name(tile_id).find("mine") > -1):
		if (!world.has_meta(String(tile))):
			world.set_meta(String(tile), String(50))
		world.set_meta(String(tile), String(int(world.get_meta(String(tile))) - dmg))
		print(worker.name + " hits tile " + String(tile) + " for " + String(dmg))
		if (int(world.get_meta(String(tile))) <= 0):
			worker.notify_tile_removed()
			world.set_cell(tile.x, tile.y, 0)
	else:
		worker.notify_tile_removed()

func use_tool(tile):
	match ui.current_selected:
		UI.Tool.REMOVE:
			var job = Job.new("Mining " + String(tile), Job.Type.MINE, tile)
			create_job(job)

func is_walkable_tile(tile_id):
	return (tile_set.tile_get_name(tile_id).find("ground") > -1)

func create_world():
	for x in range(0, world_size):
		for y in range(0, world_size):
			var tile_id = soft_noise.value_noise2d(x, y)
			if (tile_id < 0):
				tile_id = tile_set.find_tile_by_name("ground_normal")
			else :
				tile_id = 7
			world.set_cell(x, y, tile_id)

	var center = world_size / 2
	# make sure we have enough space
	for x in range(center - 3, center + 3):
		for y in range(center - 3, center + 3):
			var tile_id = tile_set.find_tile_by_name("ground_normal")
			world.set_cell(x, y, tile_id)

	# load portal
	world.set_cell(center, center, -1)
	world.set_cell(center - 1, center, -1)
	world.set_cell(center - 1, center - 1, -1)
	world.set_cell(center, center - 1, -1)
	var new_portal = Portal.instance()
	new_portal.set_position(Vector2(center * tile_size, center * tile_size))
	buildings.add_child(new_portal)
	new_portal.connect("create_worker", self, "create_worker")
	portal = new_portal