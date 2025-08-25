extends Panel

var purchased : bool = false
var bought_factories : int = 0
var bought_shops : int = 0
var total_factories : int
var total_shops : int
var country : Node2D

signal purchased_land

func update_visual():
	$FactoriesLabel.text = str(bought_factories) + '/' + str(total_factories)
	$ShopsLabel.text = str(bought_shops) + '/' + str(total_shops)
	if purchased:
		modulate = Color(1, 1, 1)
		$BuyLandButton.visible = false
	else:
		modulate = Color(0.6, 0.6, 0.6)
		$BuyLandButton.modulate = Color(1/0.6, 1/0.6,1/0.6)
		$BuyLandButton.visible = true
	

func _ready():
	$CountryLabel.text = country.name
	total_factories = country.factories.size()
	total_shops = country.shops.size()
	$BuyLandButton.factories = total_factories
	$BuyLandButton.shops = total_shops
	$BuyFactoryButton.enabled = purchased and total_factories > 0
	$BuyShopButton.enabled = purchased and total_shops > 0
	update_visual()

func _on_buy_land_button_pressed():
	purchased = true
	if total_factories > 0:
		$BuyFactoryButton.enabled = true
	if total_shops > 0:
		$BuyShopButton.enabled = true
	update_visual()
	purchased_land.emit()


func _on_buy_shop_button_pressed():
	country.shops[bought_shops].purchase()
	bought_shops += 1
	if bought_shops == total_shops:
		$BuyShopButton.remove_from_group("buy_button")
		$BuyShopButton.enabled = false
	update_visual()


func _on_buy_factory_button_pressed():
	country.factories[bought_factories].purchase()
	bought_factories += 1
	if bought_factories == total_factories:
		$BuyFactoryButton.remove_from_group("buy_button")
		$BuyFactoryButton.enabled = false
	update_visual()
