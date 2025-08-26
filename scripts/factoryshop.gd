extends Node2D

@export var is_factory : bool
@onready var selection_sprite = $SelectionSprite
var selected : bool = false
var purchased : bool = false
var mouse_hovering : bool = false

var level : int = 1
var factory_running : bool = true
var factory_trucks : int = 1
var shop_biscuit_price : int = 4
var cookies : int = 0

func update_visual():
	visible = purchased

func purchase():
	$Area2D/CollisionShape2D.disabled = false
	$Area2D.input_pickable = true
	purchased = true
	update_visual()

func set_selected(s : bool):
	selected = s
	selection_sprite.visible = s

func _ready():
	$Area2D/CollisionShape2D.disabled = true
	$Area2D.input_pickable = false
	update_visual()

func _on_area_2d_mouse_entered():
	mouse_hovering = true

func _on_area_2d_mouse_exited():
	mouse_hovering = false
