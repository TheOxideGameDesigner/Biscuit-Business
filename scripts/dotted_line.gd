extends Node2D

var step_size = 7.0
@export var start : Vector2 = Vector2.ZERO
@export var end : Vector2 = Vector2.ZERO
@export var col : Color = Color.BLUE

const TEX = preload("res://images/pixel.png")

func ready_deff():
	var steps = int(start.distance_to(end) / step_size)
	var step_dir = (end - start).normalized() * step_size
	var pos = start + step_dir
	for i in range(steps):
		var pixel = Sprite2D.new()
		pixel.texture = TEX
		pixel.add_to_group("constant_size")
		pixel.modulate = col
		add_child(pixel)
		pixel.global_position = pos
		pos += step_dir

func _ready():
	ready_deff.call_deferred()
	
