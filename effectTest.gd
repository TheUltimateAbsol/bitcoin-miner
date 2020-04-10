extends Control

onready var ScreenShake = $TextureRect/Screenshake
onready var TextureRect = $TextureRect

var amplitude = 0;
var priority = 0

func _on_Button_pressed():
	ScreenShake.start()