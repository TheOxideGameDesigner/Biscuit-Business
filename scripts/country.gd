extends Node2D

var factories = []
var shops = []
var port

var optimal_price : float = 4.0

func _ready():
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
