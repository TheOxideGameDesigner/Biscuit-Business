extends Node2D
const DOTTED_LINE = preload("res://scenes/dotted_line.tscn")
@export var is_factory : bool
@onready var selection_sprite = $SelectionSprite
@onready var connection_lines = $ConnectionLines
@onready var no_connection_warning = $Sprite/NoConnectionWarning

@onready var main_ui = get_tree().get_first_node_in_group("main_ui")
var json : Dictionary

var selected : bool = false
var purchased : bool = false
var mouse_hovering : bool = false

var level : int = 1
var factory_running : bool = true
var factory_trucks : int = 1
var shop_biscuit_price : int = 4
var cookies : int = 0

var connections = []
var connection_line_list = []

func hour_update():
	if is_factory and purchased and factory_running:
		var prev_cookies = cookies
		cookies = min(json["factory_storage"][level - 1], cookies + json["factory_speed"][level - 1])
		main_ui.money -= (cookies - prev_cookies) * json["factory_cost_per_biscuit"] 

func update_visual():
	visible = purchased

func add_connection(shop):
	if connections.has(shop):
		return
	connections.append(shop)
	shop.connections.append(self)
	var dl1 = DOTTED_LINE.instantiate()
	var dl2 = DOTTED_LINE.instantiate()
	dl1.start = self.global_position
	dl2.start = self.global_position
	dl1.end = shop.global_position
	dl2.end = shop.global_position
	connection_lines.add_child(dl1)
	connection_line_list.append(dl1)
	shop.connection_lines.add_child(dl2)
	shop.connection_line_list.append(dl2)
	if connections.size() > 3:
		var erase_shop = connections[0]
		var idx = erase_shop.connections.find(self)
		erase_shop.connection_line_list[idx].queue_free()
		erase_shop.connections.remove_at(idx)
		erase_shop.connection_line_list.remove_at(idx)
		connection_line_list[0].queue_free()
		connection_line_list.pop_front()
		connections.pop_front()

func purchase():
	$Area2D/CollisionShape2D.disabled = false
	$Area2D.input_pickable = true
	purchased = true
	update_visual()

func set_selected(s : bool):
	selected = s
	selection_sprite.visible = s
	connection_lines.visible = s

func _ready():
	$Area2D/CollisionShape2D.disabled = true
	$Area2D.input_pickable = false
	update_visual()

func _process(delta):
	no_connection_warning.visible = connections.is_empty()

func _on_area_2d_mouse_entered():
	mouse_hovering = true

func _on_area_2d_mouse_exited():
	mouse_hovering = false
