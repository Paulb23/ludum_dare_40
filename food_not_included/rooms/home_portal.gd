extends Node2D

var tile_size = 24

func has_tile(tile):
	var a = get_node("TileMap").get_cellv(tile*tile_size)
	print(String(a))
	return false
	
func can_hit(tile):
	return true
	
func hit_tile(tile, dmg):
	print(tile + " hit for " + String(dmg))