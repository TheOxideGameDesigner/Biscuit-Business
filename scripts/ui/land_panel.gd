extends Panel

var purchased : bool = false
var bought_factories : int = 0
var bought_shops : int = 0
var country : Node2D

func update_visual():
	if purchased:
		modulate = Color(1, 1, 1)
		$BuyLandButton.visible = false
	else:
		modulate = Color(0.6, 0.6, 0.6)
		$BuyLandButton.modulate = Color(1/0.6, 1/0.6,1/0.6)
		$BuyLandButton.visible = true

func _ready():
	update_visual()
	$CountryLabel.text = country.name
