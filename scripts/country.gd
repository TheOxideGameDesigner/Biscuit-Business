extends Node2D

var factories = []
var shops = []

func _ready():
	for i in get_children():
		if i.is_in_group("factory"):
			factories.push_back(i)
		elif i.is_in_group("shop"):
			shops.push_back(i)
