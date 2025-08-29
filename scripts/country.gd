extends Node2D

var factories = []
var shops = []
var port

var base_price : float = 5.0
var optimal_price : float = 5.0
const RANDOM_OFFSET = 1.0

func _ready():
	optimal_price = randf_range(5.0 - RANDOM_OFFSET, 5.0 + RANDOM_OFFSET)
	port = get_tree().get_first_node_in_group("default_port")
	for i in get_children():
		if i.is_in_group("port"):
			port = i
	for i in get_children():
		if i.is_in_group("factory"):
			factories.push_back(i)
			i.country = self
			i.port = port
			i.port_land = port.get_child(0)
		elif i.is_in_group("shop"):
			shops.push_back(i)
			i.country = self
			i.port = port
			i.port_land = port.get_child(0)
