extends Node2D

var called = false

func _unhandled_input(event):
	if not Input.is_key_pressed(KEY_0):
		return
	var map = get_world_2d().get_navigation_map()
	$Line2D.points = NavigationServer2D.map_get_path(map, global_position, $target.global_position, true, 1)
