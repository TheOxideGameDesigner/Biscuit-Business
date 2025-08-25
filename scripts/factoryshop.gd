extends Node2D

@export var is_factory : bool
var purchased : bool = false

func update_visual():
	visible = purchased

func purchase():
	purchased = true
	update_visual()

func _ready():
	update_visual()
