extends Node
# Detects swipe gestures and generates InputEventSwipe events
# that are fed back into the engine.


signal swipe_canceled(start_position)

export(float, 0, 1) var min_swipe_distance = 50

onready var timer: Timer = $SwipeTimeout
var swipe_start_position: = Vector2()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if event.pressed:
		_start_detection(event.position)
	elif not timer.is_stopped():
		_end_detection(event.position)
	elif timer.is_stopped():
		_touch_detection();


func _start_detection(position: Vector2) -> void:
	print("Starting detection");
	swipe_start_position = position
	timer.start()


func _end_detection(position: Vector2) -> void:
	timer.stop()
	
#	End early if the swipe isn't big enough
	if (position - swipe_start_position).length() < min_swipe_distance:
		_touch_detection();
		return
	
	var direction: Vector2 = (position - swipe_start_position).normalized()
	print("Ending detection ", direction);

	var swipe = InputEventSwipe.new()
	if abs(direction.x) > abs(direction.y):
		swipe.direction = Vector2(-sign(direction.x), 0.0)
	else:
		swipe.direction = Vector2(0.0, -sign(direction.y))
	Input.parse_input_event(swipe)


func _touch_detection():
	var tap = InputEventTap.new()
	Input.parse_input_event(tap)

func _on_Timer_timeout() -> void:
	emit_signal('swipe_canceled', swipe_start_position)
	
	
