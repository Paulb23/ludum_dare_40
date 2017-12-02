extends Node

enum Type {
	NONE,
	MOVE,
	MINE
}

var name
var type
var pos

func _init(name, type, pos):
	self.name = name
	self.type = type
	self.pos = pos