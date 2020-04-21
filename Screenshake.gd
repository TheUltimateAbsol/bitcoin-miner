extends Node

export (String) var property
export (float) var duration = 0.2
export (float) var frequency = 30
export (float) var amplitude = 20

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

onready var camera:Node = get_parent()
var target:Vector2 = Vector2()
var original:Vector2 = Vector2()
var original_set = false;
#onready var text_box = $Sprite
#onready var camera = get_node("Camera")

func start():
	
	if original_set == false:
		original = camera.get(property)
		original_set = true;
	
	$ShakeTween.stop_all()
	$Duration.stop();
	$Frequency.stop()
	
	camera.set(property, original)
	
	self.amplitude = amplitude
	$Duration.wait_time = duration
	$Frequency.wait_time = 1 / float(frequency)
	
	$Duration.start()
	$Frequency.start()
	
	_new_shake()
	

func _new_shake():
	$ShakeTween.stop_all()
	var rand = Vector2()
	rand.x = rand_range(-amplitude, amplitude)
	rand.y = rand_range(-amplitude, amplitude)
	target = rand + camera.get(property)
	print(rand)
	
	$ShakeTween.interpolate_property(camera, property, camera.get(property), target, $Frequency.wait_time, TRANS, EASE)
	$ShakeTween.start()

func _reset():
	$ShakeTween.stop_all()
	$ShakeTween.interpolate_property(camera, property, camera.get(property), original, $Frequency.wait_time, TRANS, EASE) 
	$ShakeTween.start()

func _on_Frequency_timeout():
	_new_shake()

func _on_Duration_timeout():
	_reset()
	$Frequency.stop()


