extends Panel

var json : Dictionary
@onready var company_name_label = $CompanyNameLabel
@onready var graph_line = $GraphViewportContainer/graph_viewport/GraphLine
@onready var profit_value_label = $SellAmount/SellButton/ProfitLabel/ProfitValueLabel
const GREEN_MONEY_UI = preload("res://scenes/green_money_ui.tscn")

const MIN_PRICE = 80
const MAX_PRICE = 85
const MAX_PRICE_EVENT = 95
const MIN_GROWTH_PRICE = 81.5
const MAX_GROWTH_PRICE = 83.5
const GROWTH_CHANGE_CHANCE = 0.2
const RANDOM_OFFSET = 1
const GROWTH_RANGE = 0.5
const SNAP_CHANCE = 0.1
const SNAP_MIN = 1.5
const SNAP_MAX = 3

var company : int = 0
const COMPANY_COUNT = 3
const POINT_COUNT = 30
const GRID_X_UNIT = 294.0 / (POINT_COUNT - 1)
const COMPANY_NAMES = ["Bergstrom Mining", "Granite Construction", "Lumina Computers"]
var base_stock_price = [0.0, 0.0, 0.0]
var stock_price = [0.0, 0.0, 0.0]
var stock_growth = [0.0, 0.0, 0.0]
var stocks_owned = [0, 0, 0]
var money_spent = [0, 0, 0]
var lines : Array[PackedVector2Array] = [[], [], []]

const EVENT_DELAY = 5
var event_company : int = 0
var event_moment : int = 0
var event_index : int = -1

const EVENTS = [
	[0.3, 0.5, 0.6, 0.8, 1.0, 0.9, 1.0, 0.8, 0.95, 0.7, 0.4, 0.3, 0.1],  # type 0 slow decline
	[0.25, 0.35, 0.5, 0.6, 0.75, 1.0, 0.8, 0.95, 1.0, 0.6, 0.2, 0.1],  # type 0 sharp decline
	[0.6, 0.9, 1.0, 0.9, 1.0, 0.95, 0.8, 0.75, 0.6, 0.45, 0.2, 0.1],  # type 1 slow decline
	[0.3, 0.9, 1.0, 0.8, 0.9, 1.0, 0.85, 0.9, 0.95, 0.85, 1.0, 0.3, 0.1]  #type 1 sharp decline
]

func add_event(company, type):
	event_company = company
	event_moment = -EVENT_DELAY
	event_index = type * 2 + randi() % 2
	pass

func update_visual():
	$SharePriceLabel.text = "Share price: $" + str(roundf(stock_price[company] * 10.0) / 10.0)
	company_name_label.text = COMPANY_NAMES[company]
	graph_line.points = lines[company]
	$BuyAmount/BuyButton.value = $BuyAmount.value * stock_price[company]
	$SellAmount/SellButton.value = -$SellAmount.value * stock_price[company]
	$SellAmount/SellButton.enabled = stocks_owned[company] >= $SellAmount.value
	$BuyAmount/BuyButton.enabled = stocks_owned[company] + $BuyAmount.value <= json["max_shares"]
	$BuyAmount/LimitLabel.visible = not $BuyAmount/BuyButton.enabled
	$SharesOwnedLabel.text = "Shares owned: " + str(int(stocks_owned[company]))
	$SellAmount.max_value = stocks_owned[company]
	if stocks_owned[company] > 0:
		var profit = (stock_price[company] * stocks_owned[company] - money_spent[company]) / float(stocks_owned[company])
		if profit < -0.05:
			profit_value_label.text = "-$" + str(-roundi(profit * 100))
			profit_value_label.modulate = Color(1, 0, 0)
		elif profit > 0.05:
			profit_value_label.text = "+$" + str(roundi(profit * 100))
			profit_value_label.modulate = Color(0, 1, 0)
		else:
			profit_value_label.text = "$0"
			profit_value_label.modulate = Color(0.7, 0.7, 0.7)
	else:
		profit_value_label.modulate = Color(0.7, 0.7, 0.7)
		profit_value_label.text = '-'


func get_y(val):
	return (1 - float(val - MIN_PRICE) / (MAX_PRICE_EVENT - MIN_PRICE)) * 150.0

func update_price(i):
	var new_price = base_stock_price[i]
	base_stock_price[i] += stock_growth[i]
	base_stock_price[i] = clamp(base_stock_price[i], MIN_GROWTH_PRICE, MAX_GROWTH_PRICE)
	base_stock_price[i] += randf_range(-RANDOM_OFFSET, RANDOM_OFFSET)
	if randf() < SNAP_CHANCE:
		base_stock_price[i] += randf_range(SNAP_MIN, SNAP_MAX) * (int(base_stock_price[i] < (MIN_PRICE + MAX_PRICE) / 2) * 2 - 1)
	base_stock_price[i] = clamp(base_stock_price[i], MIN_PRICE, MAX_PRICE)
	if randf() < GROWTH_CHANGE_CHANCE:
		stock_growth[i] = randf_range(-GROWTH_RANGE, GROWTH_RANGE)
	stock_price[i] = base_stock_price[i]
	if event_index == -1 or event_moment < 0 or i != event_company:
		return
	stock_price[i] += EVENTS[event_index][event_moment] * (MAX_PRICE_EVENT - MAX_PRICE)


func _ready():
	for i in range(COMPANY_COUNT):
		base_stock_price[i] = (MIN_PRICE + MAX_PRICE) / 2 + randf_range(-RANDOM_OFFSET, RANDOM_OFFSET)
		stock_price[i] = base_stock_price[i]
		stock_growth[i] = randf_range(-GROWTH_RANGE, GROWTH_RANGE)
		for j in range(POINT_COUNT):
			lines[i].push_back(Vector2(j * GRID_X_UNIT, get_y(stock_price[i])))
			update_price(i)
	update_visual.call_deferred()

func _on_company_tabs_tab_changed(tab):
	company = tab
	update_visual()

func hour_update():
	if event_index != -1:
		event_moment += 1
		if event_moment >= EVENTS[event_index].size():
			event_index = -1
	for i in range(COMPANY_COUNT):
		for j in range(POINT_COUNT):
			lines[i][j].x -= GRID_X_UNIT
		lines[i].remove_at(0)
		update_price(i)
		lines[i].append(Vector2(GRID_X_UNIT * (POINT_COUNT - 1), get_y(stock_price[i])))
	update_visual()


func _on_sell_amount_value_changed(value):
	update_visual()

func _on_buy_amount_value_changed(value):
	update_visual()


func _on_buy_button_pressed():
	stocks_owned[company] += $BuyAmount.value
	money_spent[company] += $BuyAmount.value * stock_price[company]
	update_visual.call_deferred()


func _on_sell_button_pressed():
	var prev_stocks_owned = stocks_owned[company]
	stocks_owned[company] -= $SellAmount.value
	money_spent[company] *= (stocks_owned[company] / prev_stocks_owned)
	var g = GREEN_MONEY_UI.instantiate()
	g.position = Vector2(27, -10)
	$SellAmount/SellButton.add_child(g)
	g.label.text = '$' + str(int(-$SellAmount/SellButton.value))
	update_visual.call_deferred()
