extends VBoxContainer

const LAND_PANEL = preload("res://scenes/ui/land_panel.tscn")
@onready var countries = get_tree().get_nodes_in_group("country")

@onready var purchased_land = $PurchasedLand
@onready var unpurchased_land = $UnpurchasedLand

var purchased_country_panels = []
var unpurchased_country_panels = []
var panels = []

func compare_panels(a : Node, b : Node):
	var na = a.country.name.erase(0, 4) if a.country.name.begins_with("the") else a.country.name
	var nb = b.country.name.erase(0, 4) if b.country.name.begins_with("the") else b.country.name
	return na.naturalnocasecmp_to(nb) < 0

func update_ui():
	unpurchased_country_panels.sort_custom(compare_panels)
	purchased_country_panels.sort_custom(compare_panels)
	var i = 0
	for node in purchased_country_panels:
		purchased_land.move_child(node, i)
		i += 1
	i = 0
	for node in unpurchased_country_panels:
		unpurchased_land.move_child(node, i)
		i += 1

func on_purchased(panel):
	purchased_country_panels.push_back(panel)
	unpurchased_country_panels.erase(panel)
	unpurchased_land.remove_child(panel)
	purchased_land.add_child(panel)
	update_ui()

func _ready():
	var uk = null
	for i in countries:
		if i.name == "the UK":
			uk = i
			break
	if uk == null:
		printerr("failed to find uk")
	for i in countries:
		if i != uk:
			var land_panel = LAND_PANEL.instantiate()
			land_panel.country = i
			unpurchased_country_panels.push_back(land_panel)
			land_panel.purchased_land.connect(on_purchased.bind(land_panel))
	var uk_land_panel = LAND_PANEL.instantiate()
	uk_land_panel.purchased = true
	uk_land_panel.country = uk
	purchased_country_panels.push_back(uk_land_panel)
	unpurchased_country_panels.sort_custom(compare_panels)
	for node in purchased_country_panels:
		purchased_land.add_child(node)
	for node in unpurchased_country_panels:
		unpurchased_land.add_child(node)
