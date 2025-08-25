extends Node2D

func _ready():
	for c : Node2D in get_children():
		var l = Label.new()
		l.z_index = 5
		l.text = c.name
		l.add_to_group("constant_size_label")
		c.add_child(l)
		l.update_minimum_size()
		l.position = -l.size / 2
