extends Panel

var json : Dictionary
var mouse_hovering : bool
var factory : Node = null

@onready var storage_label = $StorageLabel
@onready var main_control = get_tree().get_first_node_in_group("main_ui")

func update_visual():
	if factory.level >= 3:
		$UpgradeStorageLabel.visible = false
		$UpgradeSpeedLabel.visible = false
		$UpgradeCostLabel.visible = false
	else:
		$UpgradeStorageLabel.text = "+" + str(int(json["factory_storage"][factory.level] - json["factory_storage"][factory.level - 1]))
		$UpgradeSpeedLabel.text = "+" + str(int(json["factory_speed"][factory.level] - json["factory_speed"][factory.level - 1]))
		$UpgradeCostLabel.text = "+" + str(int(json["factory_cost_per_biscuit"] * (json["factory_speed"][factory.level] - json["factory_speed"][factory.level - 1])))
	$UpgradeButton.value = json["factory_upgrade_cost"][factory.level - 1]
	$UpgradeButton.enabled = factory.level < 3
	$UpgradeButton/Label.visible = factory.level < 3
	$TrucksLabel/BuyTrucks.enabled = factory.factory_trucks < 3
	$LevelLabel.text = "Level " + str(int(factory.level))
	$RunningSwitch.button_pressed = factory.factory_running
	$SpeedLabel.text = "Speed:   " + str(int(json["factory_speed"][factory.level - 1])) + "/hour"
	$TrucksLabel.text = "Trucks: " + str(int(factory.factory_trucks)) + "/3"
	$CostLabel.text = "Running cost: $" + str(int(json["factory_cost_per_biscuit"] * json["factory_speed"][factory.level - 1])) + "/hour"

func set_factory(f : Node):
	factory = f
	$ConnectionsButton.text = "Add connection"
	$ConnectionsButton.disabled = false
	update_visual()

func _process(delta):
	if factory != null:
		storage_label.text = "Storage:   " + str(int(factory.cookies)) + '/' + str(int(json["factory_storage"][factory.level - 1]))
		$NoConnectionLabel.visible = factory.connections.is_empty()
		$NoMoneyLabel.visible = main_control.money < json["factory_cost_per_biscuit"] * json["factory_speed"][factory.level - 1]

func _on_mouse_entered():
	mouse_hovering = true

func _on_mouse_exited():
	mouse_hovering = false

func _on_running_switch_toggled(toggled_on):
	factory.factory_running = toggled_on

func _on_buy_trucks_pressed():
	factory.add_truck()
	update_visual()

func _on_upgrade_button_pressed():
	factory.level += 1
	update_visual.call_deferred()


func _on_upgrade_button_mouse_entered():
	if factory.level >= 3:
		return
	
	$UpgradeStorageLabel.visible = true
	$UpgradeSpeedLabel.visible = true
	$UpgradeCostLabel.visible = true


func _on_upgrade_button_mouse_exited():
	$UpgradeStorageLabel.visible = false
	$UpgradeSpeedLabel.visible = false
	$UpgradeCostLabel.visible = false


func _on_connections_button_pressed():
	$ConnectionsButton.text = "Select shop..."
	$ConnectionsButton.disabled = true
