extends Node

enum Type {
	NONE,
	MOVE,
	MINE,
	BUILD
}

var name
var type
var pos
var build

func _init(name, type, pos, build = null):
	self.name = name
	self.type = type
	self.pos = pos
	self.build = build