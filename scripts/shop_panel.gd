extends Panel

var json : Dictionary
var mouse_hovering : bool
var shop : Node

func update_visual():
	$LevelLabel.text = "Level " + str(int(shop.level))
	$UpgradeButton.value = json["shop_upgrade_cost"][shop.level - 1]
	$UpgradeButton.enabled = shop.level < 3
	

func set_shop(s : Node):
	shop = s
	update_visual()

func _on_mouse_entered():
	mouse_hovering = true

func _on_mouse_exited():
	mouse_hovering = false
