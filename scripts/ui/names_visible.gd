extends Button

var v : bool = true

const NAMES_VISIBLE_ICON = preload("res://images/ui/names_visible_icon.png")
const NAMES_INVISIBLE_ICON = preload("res://images/ui/names_invisible_icon.png")

func _on_pressed():
	v = not v
	icon = NAMES_VISIBLE_ICON if v else NAMES_INVISIBLE_ICON
	for n in get_tree().get_nodes_in_group("constant_size_label"):
		n.visible = v
