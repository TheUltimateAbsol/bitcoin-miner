extends Node

signal pressed_attack
signal released_attack
signal released_down
signal qt_input

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _process(delta):
	if Input.is_action_just_pressed("attack"):
		emit_signal("pressed_attack");
	if Input.is_action_just_released("attack"): 
		emit_signal("released_attack");
	if Input.is_action_just_released("down"): 
		emit_signal("released_down");
	if Input.is_action_just_pressed("literally_every_button"):
		emit_signal("qt_input");
	