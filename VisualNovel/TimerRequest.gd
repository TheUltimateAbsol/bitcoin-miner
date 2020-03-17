extends Node
class_name TimerRequest

#Wrapper class to a timer that emits signals when it is forcibly ended (unlike stop)

signal timeout
var timer: Timer;

func _init(xtimer):
	timer = xtimer
	timer.connect("timeout", self, "on_timeout");
	
func set_time(wait_time):
	timer.wait_time = wait_time;
	
func get_wait_time():
	return timer.get_wait_time()
	
func start(time=-1):
	timer.start(time);
	
func stop():
	timer.stop();

func on_timeout():
	emit_signal("timeout");
	
func force_end():
	emit_signal("timeout");
	timer.stop();
	
func delete():
	timer.queue_free()
	queue_free()
	
func time_elapsed():
	return timer.wait_time - timer.time_left
