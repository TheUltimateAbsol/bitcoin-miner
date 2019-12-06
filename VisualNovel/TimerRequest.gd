extends Node
class_name TimerRequest

#Wrapper class to a timer that emits signals when it is forcibly ended (unlike stop)

signal timeout
var timer;

func _init(xtimer):
	timer = xtimer
	timer.connect("timeout", self, "on_timeout");
	
func set_time(wait_time):
	timer.wait_time = wait_time + 0.0001;
	
func start():
	timer.start();
	
func stop():
	timer.stop();

func on_timeout():
	emit_signal("timeout");
	
func force_end():
	emit_signal("timeout");
	timer.stop();