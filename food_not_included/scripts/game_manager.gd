extends Node

var Job = preload("res://Job.gd")
var Names = preload("res://names.gd")
var UI = preload("res://ui/game_ui.gd")
var noise = preload("res://libs/softnoise.gd")
var Portal = preload("res://rooms/home_portal.tscn")
var Worker = preload("res://wokers/worker.tscn")

var Algae_gen = preload("res://rooms/algae_gen.tscn")
var Algae_to_food_gen = preload("res://rooms/algae_to_food_gen.tscn")

var soft_noise

var food_count = 40
var stone_count = 100
var plant_count = 0
var pop = 0
var tile_size = 24

var world_size = 1000

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
	update_ui()

func create_worker():
	print("Creating new worker")
	var worker = Worker.instance()
	worker.name = Names.get_name()
	worker.portal_tile = Vector2(world_size / 2, world_size / 2)
	worker.set_position(portal.get_position() - Vector2(-tile_size * 2, -tile_size * 2))
	worker.connect("request_job", self, "add_wating_worker")
	worker.connect("request_path", self, "get_path")
	worker.connect("hit_tile", self, "hit_tile")
	worker.connect("build_tile", self, "build_tile")
	worker.connect("eat", self, "worker_eat")
	worker.connect("dead", self, "worker_death")
	workers.add_child(worker)
	pop += 1
	update_ui()

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
			if (tile_set.tile_get_name(tile_id).find("algae") > -1):
				stone_count += 10
				plant_count += 2
			else:
				stone_count += 20
			update_ui()
			worker.notify_tile_removed()
			world.set_cell(tile.x, tile.y, 0)
	else:
		worker.notify_tile_removed()

func build_tile(worker, tile, speed):
	# given up cancel request..
	if (!worker.has_job):
		var size = worker.assigned_job.build.get_tile_size()
		for x in range(tile.x,  tile.x + size.x):
				for y in range(tile.y,  tile.y + size.y):
					var tile_id = tile_set.find_tile_by_name("ground_normal")
					world.set_cell(x, y, tile_id)
					world.set_meta(String(tile), String(0))
		worker.assigned_job.build.queue_free()
		return
	var tile_id  = world.get_cell(tile.x, tile.y)
	if (tile_id == -1):
		if (!world.has_meta(String(tile))):
			world.set_meta(String(tile), String(1))
		world.set_meta(String(tile), String(int(world.get_meta(String(tile))) + speed))
		print(worker.name + " build tile " + String(tile) + " for " + String(speed))
		if (int(world.get_meta(String(tile))) >= 100):
			worker.assigned_job.build.built()
			update_ui()
			worker.notify_tile_removed()
	else:
		worker.notify_tile_removed()

func algae_created(amount):
	print(amount, " algae created!")
	plant_count += amount
	update_ui()

func collect_algae(building, amount):
	print(building.get_name(), " is requesting ", amount, " algae" )
	if plant_count < amount:
		print("not enough algae for ", building.get_name(), " giving 0" )
		building.give_algae(0)
	else:
		building.give_algae(amount)
		plant_count -= amount
	update_ui()

func food_created(amount):
	print(amount, " food created!")
	food_count += amount
	update_ui()

func update_ui():
	ui.stone_count = stone_count
	ui.food_count = food_count
	ui.population = pop
	ui.plant_count = plant_count
	ui.update_ui()

func use_tool(tile):
	match ui.current_selected:
		UI.Tool.REMOVE:
			var job = Job.new("Mining " + String(tile), Job.Type.MINE, tile)
			create_job(job)
		UI.Tool.BUILD_ALGAE_GEN:
			var size = Vector2(3,2)
			var can_build = true
			if (stone_count < 50 || plant_count < 10):
				can_build = false

			if (can_build):
				can_build = is_free_space(tile, size)

			if (can_build):
				stone_count -= 50
				plant_count -= 10
				for x in range(tile.x,  tile.x + size.x):
					for y in range(tile.y,  tile.y + size.y):
						world.set_meta(String(tile), String(1))
						world.set_cell(x, y, -1)
				var new_build = create_building(UI.Tool.BUILD_ALGAE_GEN, tile)
				var job = Job.new("Building Algae Genorator at " + String(tile), Job.Type.BUILD, tile, new_build)
				create_job(job)
			else:
				pass
		UI.Tool.BUILD_ALGAE_TO_FOOD_GEN:
			var size = Vector2(2,2)
			var can_build = true
			if (stone_count < 75 || plant_count < 20):
				can_build = false

			if (can_build):
				can_build = is_free_space(tile, size)

			if (can_build):
				stone_count -= 75
				plant_count -= 20
				for x in range(tile.x,  tile.x + size.x):
					for y in range(tile.y,  tile.y + size.y):
						world.set_meta(String(tile), String(1))
						world.set_cell(x, y, -1)
				var new_build = create_building(UI.Tool.BUILD_ALGAE_TO_FOOD_GEN, tile)
				var job = Job.new("Building Algae  To Food Genorator at " + String(tile), Job.Type.BUILD, tile, new_build)
				create_job(job)
			else:
				pass

func is_free_space(tile, size):
	var is_free = true
	for x in range(tile.x,  tile.x + size.x):
		for y in range(tile.y,  tile.y + size.y):
			var tile_id  = world.get_cell(x, y)
			if (is_walkable_tile(tile_id)):
				if (world.has_meta(String(tile))):
					if (int(world.get_meta(String(tile))) < 0):
						is_free = false
						break
			else:
				is_free = false
				break
	return is_free

func create_building(type, tile):
	var new_build = null
	match type:
		UI.Tool.BUILD_ALGAE_GEN:
			print("Creating new Algae Genorator")
			var size = Vector2(1.5,1)
			tile.x += size.x
			tile.y += size.y
			new_build = Algae_gen.instance()
			new_build.set_position(tile * tile_size)
			buildings.add_child(new_build)
			new_build.connect("algae_created", self, "algae_created")
		UI.Tool.BUILD_ALGAE_TO_FOOD_GEN:
			print("Creating new Algae TO Food Genorator")
			var size = Vector2(1,1)
			tile.x += size.x
			tile.y += size.y
			new_build = Algae_to_food_gen.instance()
			new_build.set_position(tile * tile_size)
			buildings.add_child(new_build)
			new_build.connect("request_algae", self, "collect_algae")
			new_build.connect("food_created", self, "food_created")
	update_ui()
	return new_build

func worker_eat(worker, amount):
	if food_count < amount:
		print(worker.name + " does not have enough food!")
		worker.full = false
	else:
		print(worker.name + " is enjoying their meal")
		worker.full = true
		food_count -= amount
	update_ui()

func worker_death(worker):
	if (worker.has_job):
		create_job(worker.assigned_job)
	else:
		waiting_wokers.erase(worker)
	worker.queue_free()
	pop -= 1
	update_ui()
	if (pop <= 0):
		Globals.set_scene("res://ui/game_over.tscn")

func is_walkable_tile(tile_id):
	return (tile_set.tile_get_name(tile_id).find("ground") > -1)

func create_world():
	for x in range(0, world_size):
		for y in range(0, world_size):
			var tile_id = soft_noise.value_noise2d(x, y)
			if (tile_id < 0):
				tile_id = tile_set.find_tile_by_name("ground_normal")
			else :
				if (tile_id > 0.5):
					tile_id = tile_set.find_tile_by_name("un_mined")
				else:
					tile_id = tile_set.find_tile_by_name("un_mined_algae")
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