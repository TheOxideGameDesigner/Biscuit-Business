extends Control

@onready var money_label = $TabBarPanel/Money
@onready var tabs = [$Map, $Property, $"Stock Market", $News]
@onready var factory_panel = $Map/FactoryPanel
@onready var shop_panel = $Map/ShopPanel
@onready var loan_panel = $LoanPanel
@onready var loan_amount = $LoanPanel/Amount
@onready var loan_button = $LoanPanel/TakeButton
@onready var debt_label = $LoanPanel/DebtLabel
@onready var daily_payment_label = $LoanPanel/DailyPaymentLabel
@onready var debt_too_high_label = $LoanPanel/DebtTooHighLabel

@onready var countries = get_tree().get_nodes_in_group("country")
var bought_countries = []

var json : Dictionary
var tutorial_json : Array
var tutorial_idx : int = 0
var tutorial_condition : int = -1
@onready var buy_buttons = get_tree().get_nodes_in_group("buy_button")
@onready var factories = get_tree().get_nodes_in_group("factory")
@onready var shops = get_tree().get_nodes_in_group("shop")
@onready var hour_updaters = get_tree().get_nodes_in_group("get_hour_update")
@onready var day_updaters = get_tree().get_nodes_in_group("get_day_update")
@onready var two_day_updaters = get_tree().get_nodes_in_group("get_two_day_update")
@onready var spinboxes = get_tree().get_nodes_in_group("spinbox")
var shopsandfactories
var selected_unit = null
var selected_factory : bool
var last_mouse_pressed_pos : Vector2
var selecting_shop_connection : bool = false
var selecting_remove_connection : bool = false
var hovering_tutorial_panel : bool = false

var loans = []
var loans_unpaid = []

var money : int

func tutorial_condition_met():
	match tutorial_condition:
		0:
			return $TabBarPanel/TabBar.current_tab == 1
		1:
			return $TabBarPanel/TabBar.current_tab == 0
		2:
			return selected_unit != null and selected_factory
		3:
			return selected_unit != null and selected_factory and selected_unit.connections.size() > 0
		4:
			return selected_unit != null and not selected_factory
		5:
			return $TabBarPanel/TabBar.current_tab == 2
		6:
			return $TabBarPanel/TabBar.current_tab == 3
		7:
			return loans.size() > 0
		8: 
			if $TabBarPanel/TabBar.current_tab != 0:
				return false
			for i in bought_countries:
				var ok = false
				for f in i.factories:
					if f.purchased:
						ok = true
						break
				if not ok:
					return false
				ok = false
				for s in i.shops:
					if s.purchased:
						ok = true
						break
				if not ok:
					return false
			return true
	return false

func update_tutorial_panel():
	if tutorial_idx >= tutorial_json.size():
		$TutorialPanel.visible = false
		$two_day_timer.start()
		return
	var t = tutorial_json[tutorial_idx]
	tutorial_condition = t["condition"]
	$TutorialPanel/Button.visible = t["condition"] == -1
	$TabBarPanel/TabBar.set_tab_disabled(t["unlock_tab"], false)
	$TutorialPanel/Label.text = t["text"]

func _ready():
	tabs[0].visible = true
	for i in range(1, tabs.size()):
		tabs[i].visible = false
	json = JSON.parse_string(FileAccess.get_file_as_string("res://values.json"))
	tutorial_json = JSON.parse_string(FileAccess.get_file_as_string("res://tutorial.json"))
	update_tutorial_panel()
	money = json["initial_money"]
	for n : Button in buy_buttons:
		n.json = json
		n.pressed.connect(pay.bind(n))
	for n in get_tree().get_nodes_in_group("request_json"):
		n.json = json
	for n : SpinBox in spinboxes:
		n.get_line_edit().mouse_default_cursor_shape = Control.CURSOR_ARROW
	$hour_timer.wait_time = json["hour_duration"]
	$hour_timer.start()
	$day_timer.wait_time = json["hour_duration"] * 24
	$day_timer.start()
	$two_day_timer.wait_time = json["hour_duration"] * 24 #not actually 2 days
	shopsandfactories = factories.duplicate()
	shopsandfactories.append_array(shops)
	
	loan_amount.max_value = json["max_loan"]
	$WinPanel/Label2.text = "You have reached\n$" + str(int(json["win_money"]))
	$LosePanel/Label2.text = "You went bankrupt"

func pay(b : Button):
	money -= b.value

func _process(delta):
	if tutorial_idx < tutorial_json.size():
		if tutorial_condition_met():
			tutorial_idx += 1
			update_tutorial_panel()
	
	if money >= 0:
		money_label.text = '$' + str(money)
		money_label.modulate = Color(1, 1, 0.27)
	else:
		money_label.text = "-$" + str(-money)
		money_label.modulate = Color(0.7, 0, 0)
	for n in buy_buttons:
		n.disabled = (n.value > money and n.value > 0) or not n.enabled
		n.get_child(0).text = '$' + str(int(abs(n.value)))
	for n : SpinBox in spinboxes:
		if n.get_line_edit().has_focus():
			n.get_line_edit().release_focus()
	
	var debt : int = 0
	for i in loans_unpaid:
		debt += i
		
	loan_button.value = -loan_amount.value
	loan_button.enabled = (debt + loan_amount.value) <= json["max_loan"]
	debt_too_high_label.visible = not loan_button.enabled
	
	debt_label.text = "Debt: $" + str(debt)
	
	if money >= json["win_money"]:
		$WinPanel.visible = true
		process_mode = Node.PROCESS_MODE_DISABLED
	elif money < 0 and debt - money >= json["max_loan"]:
		$LosePanel.visible = true
		process_mode = Node.PROCESS_MODE_DISABLED

func select(f : Node2D, is_factory):
	if selected_factory and not is_factory:
		if selecting_shop_connection:
			selected_unit.add_connection(f)
			selecting_shop_connection = false
			$Map/FactoryPanel/ConnectionsButton.text = "Add Connection"
			$Map/FactoryPanel/ConnectionsButton.disabled = false
			return
		elif selecting_remove_connection:
			selected_unit.remove_connection(f)
			selecting_remove_connection = false
			$Map/FactoryPanel/RemoveConnectionsButton.text = "Remove Connection"
			$Map/FactoryPanel/RemoveConnectionsButton.disabled = false
			return
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
		selecting_shop_connection = false
		selecting_remove_connection = false
		panel.set_factory(f)
	else:
		panel.set_shop(f)

func _input(event):
	if factory_panel.mouse_hovering or shop_panel.mouse_hovering or hovering_tutorial_panel:
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
			selecting_shop_connection = false
			selecting_remove_connection = false

func _on_tab_bar_tab_changed(tab):
	for i in tabs:
		i.visible = false
	tabs[tab].visible = true
	loan_panel.visible = false
	if tab == 3:
		$NewsUpdatePanel.visible = false


func _on_connections_button_pressed():
	selecting_shop_connection = true
	selecting_remove_connection = false
	
func _on_remove_connections_button_pressed():
	selecting_shop_connection = false
	selecting_remove_connection = true


func _on_hour_timer_timeout():
	for n in hour_updaters:
		n.hour_update()


func _on_day_timer_timeout():
	for n in day_updaters:
		n.day_update()
	for i in range(loans.size()):
		var daily = int(loans[i] * json["loan_pay_per_day"])
		money -= min(daily, loans_unpaid[i]) * (1 + json["loan_bank_profit"])
		loans_unpaid[i] -= daily
	var filtered_loans = []
	var filtered_loans_unpaid = []
	for i in range(loans.size()):
		if loans_unpaid[i] > 0:
			filtered_loans.append(loans[i])
			filtered_loans_unpaid.append(loans_unpaid[i])
	loans = filtered_loans
	loans_unpaid = filtered_loans_unpaid

func _on_two_day_timer_timeout():
	for n in two_day_updaters:
		n.two_day_update()
	if $TabBarPanel/TabBar.current_tab != 3:
		$NewsUpdatePanel.visible = true

func _on_loan_pressed():
	loan_panel.visible = true


func _on_close_pressed():
	loan_panel.visible = false


func _on_take_button_mouse_entered():
	$LoanPanel/PaymentIncreaseLabel.text = "+$" + str(int((1 + json["loan_bank_profit"]) * loan_amount.value * json["loan_pay_per_day"]))
	$LoanPanel/PaymentIncreaseLabel.visible = true


func _on_take_button_mouse_exited():
	$LoanPanel/PaymentIncreaseLabel.visible = false


func _on_take_button_pressed():
	var daily = 0
	loans.append(loan_amount.value)
	loans_unpaid.append(loan_amount.value)
	for i in range(loans.size()):
		daily += int((1 + json["loan_bank_profit"]) * loans[i] * json["loan_pay_per_day"])
	daily_payment_label.text = "Daily payment: $" + str(int(daily))


func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_button_2_pressed():
	get_tree().reload_current_scene()


func _on_tutorial_button_pressed():
	tutorial_idx += 1
	update_tutorial_panel()


func _on_tutorial_panel_mouse_entered():
	hovering_tutorial_panel = true


func _on_tutorial_panel_mouse_exited():
	hovering_tutorial_panel = false


func _on_skip_button_pressed():
	tutorial_idx = 10000
	for i in range(4):
		$TabBarPanel/TabBar.set_tab_disabled(i, false)
	update_tutorial_panel()
