extends Node2D

const T = 1.0
const D = 15

@onready var label = $Label
@onready var init_pos = position.y
var time = 0.0

var wait_time = 0.0

func _process(delta):
	visible = time > wait_time
	var t = pow((time - wait_time) / T, 0.5)
	label.modulate.a = lerp(1, 0, t)
	position.y = init_pos + lerp(0, -D, t)
	time += delta
	if time >= T + wait_time:
		queue_free()
