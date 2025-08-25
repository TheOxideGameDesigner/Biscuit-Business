extends Control

@onready var money_label = $TabBarPanel/Money
@onready var tabs = [$Map, $Property, $"Stock Market", $News]
var json : Dictionary
@onready var buy_buttons = get_tree().get_nodes_in_group("buy_button")

var money : int

func _ready():
	print("ready")
	tabs[0].visible = true
	for i in range(1, tabs.size()):
		tabs[i].visible = false
	json = JSON.parse_string(FileAccess.get_file_as_string("res://values.json"))
	money = json["initial_money"]
	for n : Button in buy_buttons:
		n.json = json
		n.pressed.connect(pay.bind(n))

func pay(b : Button):
	money -= b.value

func _process(delta):
	money_label.text = '$' + str(money)
	for n in buy_buttons:
		n.disabled = n.value > money or not n.enabled
		n.get_child(0).text = '$' + str(int(n.value))

func _on_tab_bar_tab_changed(tab):
	for i in tabs:
		i.visible = false
	tabs[tab].visible = true
