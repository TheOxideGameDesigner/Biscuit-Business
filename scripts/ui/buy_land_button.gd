extends Button

var value
var json : Dictionary
var enabled = true

var factories = 0
var shops = 0

func ready_deff():
	value = json["land_factory_price"] * factories + json["land_shop_price"] * shops

func _ready():
	ready_deff.call_deferred()
