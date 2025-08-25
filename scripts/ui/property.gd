extends VBoxContainer

const LAND_PANEL = preload("res://scenes/ui/land_panel.tscn")
@onready var countries = get_tree().get_nodes_in_group("country")

@onready var purchased_land = $PurchasedLand
@onready var unpurchased_land = $UnpurchasedLand

var purchased_country_panels = []
var unpurchased_country_panels = []
var panels = []

func compare_panels(a : Node, b : Node):
	return a.country.name.naturalnocasecmp_to(b.country.name) < 0

func update_ui():
	unpurchased_country_panels.sort_custom(compare_panels)
	purchased_country_panels.sort_custom(compare_panels)
	for node in purchased_land.get_children():
		remove_child(node)
	for node in purchased_country_panels:
		add_child(node)
	for node in unpurchased_land.get_children():
		remove_child(node)
	for node in unpurchased_country_panels:
		add_child(node)

func _ready():
	var uk = null
	for i in countries:
		if i.name == "The United Kingdom":
			uk = i
			break
	if uk == null:
		printerr("failed to find uk")
	for i in countries:
		if i != uk:
			var land_panel = LAND_PANEL.instantiate()
			land_panel.country = i
			unpurchased_country_panels.push_back(land_panel)
	var uk_land_panel = LAND_PANEL.instantiate()
	uk_land_panel.purchased = true
	uk_land_panel.country = uk
	purchased_country_panels.push_back(uk_land_panel)
	
	update_ui()
