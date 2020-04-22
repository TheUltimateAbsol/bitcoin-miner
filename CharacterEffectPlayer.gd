extends Node2D

onready var anim = $AnimationPlayer

func reset():
#	Resets the animations without us having to think :)
	if anim.current_animation != "":
		anim.seek(anim.current_animation_length, true)
		anim.stop();

func angry():
	reset()
	GlobalFX.play_sound(GlobalFX.ANGRY)
	anim.play("angry")
	
func exclamation():
	reset()
	GlobalFX.play_sound(GlobalFX.EXCLAMATION)
	anim.play("exclamation")
	
func frustrated():
	reset()
	GlobalFX.play_sound(GlobalFX.FRUSTRATED)
	anim.play("frustrated")
	
func music_note():
	reset()
	GlobalFX.play_sound(GlobalFX.MUSIC_NOTE)
	anim.play("music_note")
	
func sweat():
	reset()
	GlobalFX.play_sound(GlobalFX.SWEAT)
	anim.play("sweat")
