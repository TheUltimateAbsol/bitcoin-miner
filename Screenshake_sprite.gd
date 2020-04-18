extends Node

const TRANS = Tween.TRANS_SINE

const EASE = Tween.EASE_IN_OUT

var amplitude = 0;
var priority = 0

onready var sprite = get_parent()
#onready var text_box = $Sprite
#onready var camera = get_node("Camera")

func start(duration = 0.2, frequency = 15, amplitude = 6, priority = 0):
	if priority >= self.priority:
		self.amplitude = amplitude
		$Duration.wait_time = duration
		$Frequency.wait_time = 1 / float(frequency)
		
		$Duration.start()
		$Frequency.start()
		
		print(sprite)
		
		_new_shake()
	

func _new_shake():
	var rand = Vector2()
	rand.x = rand_range(-amplitude, amplitude)
	rand.y = rand_range(-amplitude, amplitude)
	
	$ShakeTween.interpolate_property(sprite, "offset", sprite.offset, rand, $Frequency.wait_time, TRANS, EASE)
#	$ShakeTween.interpolate_property(text_box, "offset", text_box.offset, rand, $Frequency.wait_time, TRANS, EASE)  
	$ShakeTween.start()

func _reset():
	$ShakeTween.interpolate_property(sprite, "offset", sprite.offset, Vector2(), $Frequency.wait_time, TRANS, EASE) 
#	$ShakeTween.interpolate_property(text_box, "offest", text_box.offset, Vector2(), $Frequency.wait_time, TRANS, EASE)
	$ShakeTween.start()
	
	priority = 0

func _on_Frequency_timeout():
	_new_shake()


func _on_Duration_timeout():
	_reset()
	$Frequency.stop()


func _on_Button_pressed():
	start()
