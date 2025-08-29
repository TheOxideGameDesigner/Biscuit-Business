extends Node


var paused : bool = false

func update():
	get_tree().paused = paused
	$PausePanel.visible = paused

func _unhandled_input(event):
	if event is InputEventKey:
		if not event.is_pressed() or not event.keycode == KEY_ESCAPE:
			return
		paused = not paused
		update()
	

func _on_continue_pressed():
	paused = false
	update()

func _on_back_pressed():
	$PausePanel/Panel.visible = true

func _on_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_button_2_pressed():
	$PausePanel/Panel.visible = false
