extends Node2D

signal create_worker

var worker_timer

var workers_created = 0

func _ready():
	worker_timer = get_node("worker_check")
	worker_timer.connect("timeout", self, "create_worker")
	
func create_worker():
	print("Requesting new worker")
	emit_signal("create_worker")
	workers_created += 1
	worker_timer.set_wait_time(rand_range(90, 300))
	
func _physics_process(delta):
	pass

func get_tile_size():
	return Vector2(2, 2)