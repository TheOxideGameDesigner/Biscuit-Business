extends Panel

@onready var panels : Array[Sprite2D] = [$NewsBackground, $NewsBackground2, $NewsBackground3, $NewsBackground4]
@onready var countries = get_tree().get_nodes_in_group("country")
@onready var main_ui = get_tree().get_first_node_in_group("main_ui")
var filler_news : Array
var stock_news : Array
var biscuit_good_news : Array
var biscuit_bad_news : Array
var filler_idx = 0
var stock_idx = 0
var event_country = null

var news_json : Dictionary

const MIN_COUNTRIES_BAD_NEWS = 3
const GOOD_NEWS_CHANCE = 0.7

func update_panel_visual(i, news : Dictionary):
	panels[i].get_node("Headline").text = news["headline"]
	panels[i].get_node("Content").text = news["content"]
	panels[i].get_node("Image").texture = load("res://images/news/" + news["image"])

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
	
	var sn = stock_news[stock_idx]
	stock_idx += 1
	if stock_idx >= stock_news.size():
		stock_idx = 0
		stock_news.shuffle()
	$"../Stock Market".add_event(sn["company"], sn["event_type"])
	update_panel_visual(order[2], sn)
	
	var owned_countries = main_ui.bought_countries
	var good_news : bool = owned_countries.size() < MIN_COUNTRIES_BAD_NEWS or randf() < GOOD_NEWS_CHANCE
	var bn = news_json["biscuit_good_news"].pick_random() if good_news else news_json["biscuit_bad_news"].pick_random()
	var bcountry = countries.pick_random() if good_news else owned_countries.pick_random()
	bn["headline"] = bn["headline"].replace("{country}", bcountry.name)
	bn["headline"] = bn["headline"][0].to_upper() + bn["headline"].substr(1,-1)
	bn["content"] = bn["content"].replace("{country}", bcountry.name)
	if event_country != null:
		event_country.event_price = -1
	bcountry.event_price = randf_range(bn["optimal_price_min"], bn["optimal_price_max"])
	event_country = bcountry
	
	update_panel_visual(order[3], bn)

func two_day_update():
	update_news()

func _ready():
	news_json = JSON.parse_string(FileAccess.get_file_as_string("res://news.json"))
	filler_news = news_json["filler_news"]
	filler_news.shuffle()
	stock_news = news_json["stock_news"]
	stock_news.shuffle()
	biscuit_good_news = news_json["biscuit_good_news"]
	biscuit_bad_news = news_json["biscuit_bad_news"]
	update_news()
