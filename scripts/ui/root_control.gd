extends Control

@onready var money_label = $TabBarPanel/Money
@onready var tabs = [$Map, $Property, $"Stock Market", $News]
@onready var factory_panel = $Map/FactoryPanel
@onready var shop_panel = $Map/ShopPanel

var json : Dictionary
@onready var buy_buttons = get_tree().get_nodes_in_group("buy_button")
@onready var factories = get_tree().get_nodes_in_group("factory")
@onready var shops = get_tree().get_nodes_in_group("shop")
var shopsandfactories
var selected_unit = null
var selected_factory : bool
var last_mouse_pressed_pos : Vector2

var money : int

func _ready():
	tabs[0].visible = true
	for i in range(1, tabs.size()):
		tabs[i].visible = false
	json = JSON.parse_string(FileAccess.get_file_as_string("res://values.json"))
	money = json["initial_money"]
	for n : Button in buy_buttons:
		n.json = json
		n.pressed.connect(pay.bind(n))
	for n in get_tree().get_nodes_in_group("request_json"):
		n.json = json
	shopsandfactories = factories.duplicate()
	shopsandfactories.append_array(shops)

func pay(b : Button):
	money -= b.value

func _process(delta):
	money_label.text = '$' + str(money)
	for n in buy_buttons:
		n.disabled = n.value > money or not n.enabled
		n.get_child(0).text = '$' + str(int(n.value))

func select(f : Node2D, is_factory):
	if selected_unit != null:
		selected_unit.set_selected(false)
	selected_unit = f
	f.set_selected(true)
	selected_factory = is_factory
	var screen_pos = f.get_global_transform_with_canvas().origin.x
	var panel = factory_panel if is_factory else shop_panel
	if not panel.visible:
		panel.position.x = 3 if screen_pos > 950 / 2 else 972 - panel.size.x
	shop_panel.visible = false
	factory_panel.visible = false
	panel.visible = true
	if is_factory:
		panel.set_factory(f)
	else:
		panel.set_shop(f)

func _input(event):
	if factory_panel.mouse_hovering or shop_panel.mouse_hovering:
		return
	if event.is_action_pressed("lmb"):
		last_mouse_pressed_pos = get_viewport().get_mouse_position()
	if event.is_action_released("lmb"):
		var is_hovering : bool = false
		for f in factories:
			if not f.mouse_hovering:
				continue
			is_hovering = true
			select(f, true)
			break
		if not is_hovering:
			for s in shops:
				if not s.mouse_hovering:
					continue
				is_hovering = true
				select(s, false)
				break
		if not is_hovering and last_mouse_pressed_pos.distance_to(get_viewport().get_mouse_position()) < 10.0:
			if selected_unit != null:
				selected_unit.set_selected(false)
				selected_unit = null
			factory_panel.visible = false
			shop_panel.visible = false

func _on_tab_bar_tab_changed(tab):
	for i in tabs:
		i.visible = false
	tabs[tab].visible = true
