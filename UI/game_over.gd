extends Control

signal restart_button_pressed

func _on_restart_button_pressed() -> void:
	restart_button_pressed.emit()

func _on_quit_button_pressed() -> void:
	pass
