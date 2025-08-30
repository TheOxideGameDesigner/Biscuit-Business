extends Panel

@onready var panels : Array[Sprite2D] = [$NewsBackground, $NewsBackground2, $NewsBackground3, $NewsBackground4]
@onready var countries = get_tree().get_nodes_in_group("country")
var country_idx : int = 0
@onready var main_ui = get_tree().get_first_node_in_group("main_ui")
var filler_news : Array
var stock_news : Array
var biscuit_good_news : Array
var filler_idx = 0
var stock_idx = 0

var news_json : Dictionary

const STOCK_EVENT_CHANCE = 0.375
const MIN_COUNTRIES_STOCK_EVENT = 3

func update_panel_visual(i, news : Dictionary):
	panels[i].get_node("Headline").text = news["headline"]
	panels[i].get_node("Content").text = news["content"]
	panels[i].get_node("Image").texture = load("res://images/news/" + news["image"])

func generate_biscuit_news(i):
	print(countries[country_idx].name + " " + str(country_idx))
	var bcountry = countries[country_idx]
	country_idx = (country_idx + 1) % countries.size()
	var bn = biscuit_good_news.pick_random().duplicate()
	bn["headline"] = bn["headline"].replace("{country}", bcountry.name)
	bn["headline"] = bn["headline"][0].to_upper() + bn["headline"].substr(1,-1)
	bn["content"] = bn["content"].replace("{country}", bcountry.name)
	bcountry.optimal_price = randf_range(bn["optimal_price_min"], bn["optimal_price_max"])
	update_panel_visual(i, bn)

func update_news():
	var order = range(panels.size())
	order.shuffle()
	update_panel_visual(order[0], filler_news[filler_idx])
	filler_idx += 1
	if filler_idx >= filler_news.size():
		filler_idx = 0
		filler_news.shuffle()
	update_panel_visual(order[1], filler_news[filler_idx])
	filler_idx += 1
	if filler_idx >= filler_news.size():
		filler_idx = 0
		filler_news.shuffle()
	
	var owned_countries = main_ui.bought_countries
	var shop_countries = 0
	for i in owned_countries:
		if i.shops.size() > 0:
			shop_countries += 1
	if shop_countries >= MIN_COUNTRIES_STOCK_EVENT and randf() < STOCK_EVENT_CHANCE:
		var sn = stock_news[stock_idx]
		stock_idx += 1
		if stock_idx >= stock_news.size():
			stock_idx = 0
			stock_news.shuffle()
		$"../Stock Market".add_event(sn["company"], sn["event_type"])
		update_panel_visual(order[2], sn)
	else:
		generate_biscuit_news(order[2])
	
	generate_biscuit_news(order[3])

func two_day_update():
	update_news()

func _ready():
	countries.shuffle()
	news_json = JSON.parse_string(FileAccess.get_file_as_string("res://news.json"))
	filler_news = news_json["filler_news"]
	filler_news.shuffle()
	stock_news = news_json["stock_news"]
	stock_news.shuffle()
	biscuit_good_news = news_json["biscuit_news"]
	update_news()
