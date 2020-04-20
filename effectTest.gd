extends Control

onready var ScreenShake = $TextureRect/Screenshake
onready var SpriteShake = $Sprite/Screenshake_sprite
#onready var TextureRect = $TextureRect
#onready var Sprite = $Sprite

var amplitude = 0;
var priority = 0

func _on_Button_pressed():
	SpriteShake.start()
	ScreenShake.start()
