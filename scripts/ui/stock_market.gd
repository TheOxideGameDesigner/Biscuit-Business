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
const COMPANY_NAMES = ["Bergstrom Mining", "Hellvik Construction", "Lumina Computers"]
var stock_price = [0.0, 0.0, 0.0]
var stock_growth = [0.0, 0.0, 0.0]
var stocks_owned = [0, 0, 0]
var money_spent = [0, 0, 0]
var lines : Array[PackedVector2Array] = [[], [], []]


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
	var new_price = stock_price[i]
	stock_price[i] += stock_growth[i]
	stock_price[i] = clamp(stock_price[i], MIN_GROWTH_PRICE, MAX_GROWTH_PRICE)
	stock_price[i] += randf_range(-RANDOM_OFFSET, RANDOM_OFFSET)
	if randf() < SNAP_CHANCE:
		stock_price[i] += randf_range(SNAP_MIN, SNAP_MAX) * (int(stock_price[i] < (MIN_PRICE + MAX_PRICE) / 2) * 2 - 1)
	stock_price[i] = clamp(stock_price[i], MIN_PRICE, MAX_PRICE)
	if randf() < GROWTH_CHANGE_CHANCE:
		stock_growth[i] = randf_range(-GROWTH_RANGE, GROWTH_RANGE)


func _ready():
	for i in range(COMPANY_COUNT):
		stock_price[i] = (MIN_PRICE + MAX_PRICE) / 2 + randf_range(-RANDOM_OFFSET, RANDOM_OFFSET)
		stock_growth[i] = randf_range(-GROWTH_RANGE, GROWTH_RANGE)
		for j in range(POINT_COUNT):
			lines[i].push_back(Vector2(j * GRID_X_UNIT, get_y(stock_price[i])))
			update_price(i)
	update_visual.call_deferred()

func _on_company_tabs_tab_changed(tab):
	company = tab
	update_visual()

func hour_update():
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
