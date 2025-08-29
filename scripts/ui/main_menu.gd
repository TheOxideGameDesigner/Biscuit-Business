extends Control

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_ui.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_credits_pressed():
	$CreditsPanel.visible = true

func _on_close_credits_pressed():
	$CreditsPanel.visible = false

func _on_options_pressed():
	$OptionsContainer.visible = true
