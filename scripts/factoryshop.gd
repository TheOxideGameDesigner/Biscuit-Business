extends Node2D
const DOTTED_LINE = preload("res://scenes/dotted_line.tscn")
const TP = Vector2(0, 1)
const SHIP = preload("res://images/ship.png")
const TRUCK = preload("res://images/truck.png")
const GREEN_MONEY = preload("res://scenes/green_money.tscn")

const TSPEED_GLOBAL = 26
const TSPEED_LOCAL = 23

var country
var port
var port_land

@onready var map = get_world_2d().get_navigation_map()
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
var factory_trucks : int = 0
var shop_biscuit_price : int = 10
var shop_clients_yesterday : int = -1
var shop_earnings_yesterday : int = -1
var shop_clients_today : int = 0
var shop_earnings_today : int = 0
var cookies : int = 0

var connections = []
var connection_line_list = []
var factory_paths = []

var truck_list = []
var truck_paths = []
var truck_targets = []
var truck_is_moving = []
var truck_current_stage = []
var truck_current_node = []
var truck_node_progress = []
var truck_speed = []
var truck_wait = []

func add_truck():
	factory_trucks += 1
	var truck = Sprite2D.new()
	truck.texture = TRUCK
	truck.offset = Vector2(0, -3.5)
	truck.scale = Vector2(3, 3)
	truck.position = TP
	truck.visible = false
	truck.add_to_group("constant_size")
	truck_list.append(truck)
	truck_paths.append(null)
	truck_targets.append(null)
	truck_is_moving.append(false)
	truck_current_stage.append(0)
	truck_current_node.append(0)
	truck_node_progress.append(0.0)
	truck_speed.append(0)
	truck_wait.append(0)
	add_child(truck)

func hour_update():
	if not purchased:
		return
	if not is_factory:
		var M = country.optimal_price * 2.0
		var A = (log(json["shop_marketing"][level - 1]) + 1) * json["shop_demand_constant"]
		var clients = min(A * exp(-shop_biscuit_price / M), int(cookies / 10))
		var earnings = clients * shop_biscuit_price
		if earnings > 0:
			var g = GREEN_MONEY.instantiate()
			g.position = Vector2(0, -20) * selection_sprite.scale.x / 3.0
			g.wait_time = randf_range(0, json["hour_duration"])
			add_child(g)
			g.label.text = "$" + str(int(earnings))
		main_ui.money += earnings
		shop_clients_today += clients
		shop_earnings_today += earnings
		cookies -= clients * 10
		return
	if factory_running:
		var prev_cookies = cookies
		var aux_cookies = min(json["factory_storage"][level - 1], cookies + json["factory_speed"][level - 1])
		var cost = (aux_cookies - prev_cookies)* json["factory_cost_per_biscuit"]
		if cost > main_ui.money:
			return
		cookies = aux_cookies
		main_ui.money -= cost

func day_update():
	if not purchased:
		return
	if not is_factory:
		shop_clients_yesterday = shop_clients_today
		shop_earnings_yesterday = shop_earnings_today

func update_visual():
	visible = purchased

func add_connection(shop):
	if connections.has(shop):
		return
	connections.append(shop)
	shop.connections.append(self)
	
	var path = []
	if shop.port == port:
		path.append(NavigationServer2D.map_get_path(map, global_position + TP, shop.global_position + TP, true, 0b1))
	else:
		path.append(NavigationServer2D.map_get_path(map, global_position + TP, port_land.global_position, true, 0b1))
		path.append(NavigationServer2D.map_get_path(map, port.global_position, shop.port.global_position, true, 0b10))
		path.append(NavigationServer2D.map_get_path(map, shop.port_land.global_position, shop.global_position + TP, true, 0b1))
	factory_paths.append(path)
	
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
		factory_paths.pop_front()

func remove_connection(shop):
	if not connections.has(shop):
		return
	var idx = connections.find(shop)
	connections.remove_at(idx)
	factory_paths.remove_at(idx)
	connection_line_list[idx].queue_free()
	connection_line_list.remove_at(idx)
	var shop_idx = shop.connections.find(self)
	shop.connections.remove_at(shop_idx)
	shop.connection_line_list[shop_idx].queue_free()
	shop.connection_line_list.remove_at(shop_idx)

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
	add_truck()
	update_visual()

func update_truck(i, delta):
	var returning : bool = truck_targets[i] == null
	var sgn = -1 if returning else 1
	var t = truck_list[i]
	if truck_wait[i] > 0.0:
		t.visible = returning or truck_current_stage[i] != 0
		truck_wait[i] -= delta
		return
	var stage = truck_current_stage[i]
	t.texture = SHIP if stage == 1 else TRUCK
	var node = truck_paths[i][stage][truck_current_node[i]]
	var next_node = truck_paths[i][stage][truck_current_node[i] + sgn]
	t.flip_h = next_node.x < node.x
	truck_node_progress[i] += truck_speed[i] * delta / node.distance_to(next_node)
	t.global_position = lerp(node, next_node, truck_node_progress[i])
	if truck_node_progress[i] >= 1.0:
		truck_node_progress[i] = 0.0
		if (returning and truck_current_node[i] > 1) or (not returning and truck_current_node[i] < truck_paths[i][stage].size() - 2):
			truck_current_node[i] += sgn
		else:
			if (returning and stage > 0) or (not returning and stage < truck_paths[i].size() - 1):
				truck_wait[i] = 0.5
				truck_current_stage[i] += sgn
				truck_current_node[i] = truck_paths[i][truck_current_stage[i]].size() - 1 if returning else 0
			else:
				if returning:
					truck_is_moving[i] = false
				else:
					truck_wait[i] = 1
					truck_targets[i].cookies = min(json["shop_storage"][truck_targets[i].level - 1], truck_targets[i].cookies + json["truck_capacity"])
					truck_targets[i] = null
					truck_current_node[i] += 1

func _process(delta):
	if not purchased:
		return
	no_connection_warning.visible = connections.is_empty()
	if is_factory:
		if connections.is_empty():
			return
		for i in range(factory_trucks):
			if cookies < json["truck_capacity"]:
				break
			if truck_is_moving[i]:
				continue
			var t = truck_list[i]
			var min_shop = null
			var min_shop_val = 99999999
			for s in range(connections.size()):
				var c = connections[s].cookies + truck_targets.count(connections[s]) * json["truck_capacity"]
				if c < min_shop_val:
					min_shop = s
					min_shop_val = c
			cookies -= json["truck_capacity"]
			truck_is_moving[i] = true
			truck_current_stage[i] = 0
			truck_node_progress[i] = 0
			truck_current_node[i] = 0
			if country == connections[min_shop].country:
				truck_speed[i] = TSPEED_LOCAL
			else:
				truck_speed[i] = TSPEED_GLOBAL
			truck_targets[i] = connections[min_shop]
			truck_paths[i] = factory_paths[min_shop]
			truck_wait[i] = 2.0 + randf_range(-1, 1)
		for i in range(factory_trucks):
			truck_list[i].visible = truck_is_moving[i]
			if not truck_is_moving[i]:
				continue
			update_truck(i, delta)
			
	

func _on_area_2d_mouse_entered():
	mouse_hovering = true

func _on_area_2d_mouse_exited():
	mouse_hovering = false
