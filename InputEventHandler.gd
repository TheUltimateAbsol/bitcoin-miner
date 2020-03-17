extends Node

signal pressed_attack
signal released_attack
signal released_down

var fake_clicks =[];
var to_remove=[];

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _process(delta):		

#	If we get to this point and a click is queued for deletion it has ran once already
	if to_remove.size() > 0:
		for click in to_remove:
			Input.action_release(click);
		to_remove = [];

#	Actual input handlers
	if Input.is_action_just_pressed("attack"):
		emit_signal("pressed_attack");
	if Input.is_action_just_released("attack"): 
		emit_signal("released_attack");
	if Input.is_action_just_released("down"): 
		emit_signal("released_down");
		

#	If we get to this point, we know the fake click has processed exactly once
	if fake_clicks.size() > 0:
		for click in fake_clicks:
			to_remove.push_back(click)
		fake_clicks = [];

func fake_click(action):
	Input.action_press(action);
	fake_clicks.append(action);

func _unhandled_input(event: InputEvent) -> void:
	var valid_event: bool = (
		event is InputEventSwipe or
		event is InputEventTap #or
#		event.is_action('ui_next') or
#		event.is_action('ui_previous')
	)
	if not valid_event:
		return
		
	if event is InputEventSwipe:
		if abs(event.direction.x) > abs(event.direction.y):
			if sign(event.direction.x) == 1:
				print("received left")
				fake_click("left");
			else:
				print("received right")
				fake_click("right");
		else:
			if sign(event.direction.y) == 1:
				print("received up")
				fake_click("jump");
			else:
				print("received down")
				fake_click("down");
	if event is InputEventTap:
		print("received attack")
		fake_click("attack");
				
#	elif event is InputEventMouseButton:
#		match event.button_index:
#			BUTTON_LEFT:
#				self.index_active += 1
#			BUTTON_RIGHT:
#				self.index_active -= 1
	get_tree().set_input_as_handled()
