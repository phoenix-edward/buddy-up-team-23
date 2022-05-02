class_name TitleScreen
extends Control


func _ready() -> void:
	$AnimationPlayer.play("EaseIn")
	$AnimationPlayer.connect("animation_finished", self, "_on_animation_finished")
	get_tree().paused = true


func _on_animation_finished() -> void:
	get_tree().paused = false


func _on_play_button_pressed() -> void:
	print("play button pressed")


func _on_settings_button_pressed() -> void:
	print("settings button pressed")
