extends Panel

var json : Dictionary
var mouse_hovering : bool
var shop : Node
@onready var storage_label = $StorageLabel

func update_visual():
	if shop.level >= 3:
		$UpgradeStorageLabel.visible = false
		$UpgradeMarketingLabel.visible = false
		$UpgradeButton/Label.visible = false
	else:
		$UpgradeStorageLabel.text = "+" + str(int(json["shop_storage"][shop.level] - json["shop_storage"][shop.level - 1]))
		$UpgradeMarketingLabel.text = "+" + str(int(json["shop_marketing"][shop.level] - json["shop_marketing"][shop.level - 1]))
	$LevelLabel.text = "Level " + str(int(shop.level))
	$UpgradeButton.value = json["shop_upgrade_cost"][shop.level - 1]
	$UpgradeButton.enabled = shop.level < 3
	

func set_shop(s : Node):
	shop = s
	$PriceSpinBox.set_value_no_signal(shop.shop_biscuit_price)
	update_visual()

func _ready():
	$PriceSpinBox.get_line_edit().mouse_default_cursor_shape = Control.CURSOR_ARROW
	

func _process(delta):
	if shop != null:
		storage_label.text = "Storage:   " + str(int(shop.cookies)) + '/' + str(int(json["shop_storage"][shop.level - 1]))
		$NoConnectionLabel.visible = shop.connections.is_empty()
		$PriceSpinBox.get_line_edit().release_focus()

func _on_mouse_entered():
	mouse_hovering = true

func _on_mouse_exited():
	mouse_hovering = false

func _on_upgrade_button_pressed():
	shop.level += 1
	update_visual.call_deferred()

func _on_upgrade_button_mouse_entered():
	if shop.level >= 3:
		return
	$UpgradeStorageLabel.visible = true
	$UpgradeMarketingLabel.visible = true

func _on_upgrade_button_mouse_exited():
	$UpgradeStorageLabel.visible = false
	$UpgradeMarketingLabel.visible = false


func _on_price_spin_box_value_changed(value):
	shop.shop_biscuit_price = value
