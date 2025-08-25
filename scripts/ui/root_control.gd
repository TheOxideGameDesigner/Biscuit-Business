extends Control

@onready var tabs = [$Map, $Property, $"Stock Market", $News]

func _on_tab_bar_tab_changed(tab):
	for i in tabs:
		i.visible = false
	tabs[tab].visible = true
