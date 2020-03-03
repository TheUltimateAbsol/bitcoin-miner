extends Node

signal pressed_attack
signal released_attack
signal released_down

var fake_clicks =[];

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _process(delta):
	if Input.is_action_just_pressed("attack"):
		emit_signal("pressed_attack");
	if Input.is_action_just_released("attack"): 
		emit_signal("released_attack");
	if Input.is_action_just_released("down"): 
		emit_signal("released_down");
	if fake_clicks.size() > 0:
		for click in fake_clicks:
			Input.action_release(click);

func fake_click(action):
	Input.action_press(action);
	fake_clicks.append(action);

func _unhandled_input(event: InputEvent) -> void:
	var valid_event: bool = (
		event is InputEventSwipe #or
#		event is InputEventMouseButton or
#		event.is_action('ui_next') or
#		event.is_action('ui_previous')
	)
	if not valid_event:
		return
		
	if event is InputEventSwipe:
		if sign(event.direction.x > event.direction.x):
			if sign(event.direction.x) == 1:
				fake_click("attack");
			else:
				fake_click("left");
		else:
			if sign(event.direction.y) == 1:
				fake_click("down");
			else:
				fake_click("up");
				
#	elif event is InputEventMouseButton:
#		match event.button_index:
#			BUTTON_LEFT:
#				self.index_active += 1
#			BUTTON_RIGHT:
#				self.index_active -= 1
	get_tree().set_input_as_handled()