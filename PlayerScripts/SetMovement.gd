extends Node2D

enum {LEFT, MIDDLE, RIGHT}
enum {INPUT_OPEN, INPUT_BUSY}

var currpos = MIDDLE
var currtar = LEFT
var state = INPUT_OPEN

onready var main = $Main
onready var y = main.position.y
onready var x1 = $Area1.position.x
onready var x2 = $Area2.position.x
onready var x3 = $Area3.position.x

func to_target():
	print(currpos, currtar)
	state = INPUT_BUSY
	yield(move(main, currtar), "completed")
	currpos = currtar	
	state = INPUT_OPEN
	
func move(bot, target):
	var target_x
	match target:
		LEFT: target_x = x1
		MIDDLE: target_x = x2
		RIGHT: target_x = x3
	var diff = target_x - bot.position.x;
	
	if (diff >= 0): 
		bot.flip(true);
	else: 
		bot.flip(false);
	
	var target_position;
	match target:
		LEFT: 
			target_position = Vector2(x1, y)
		MIDDLE: 
			target_position = Vector2(x2, y)
		RIGHT: 
			target_position = Vector2(x3, y)
	bot.walk();
	var track = 0
	$AnimationPlayer.get_animation("Walk").track_set_key_value(track, 0, bot.position)
	$AnimationPlayer.get_animation("Walk").track_set_key_value(track, 1, target_position)
	$AnimationPlayer.play("Walk");
	yield($AnimationPlayer, "animation_finished");
	bot.idle();


func get_input():
	if (state != INPUT_OPEN): return
	if Input.is_action_pressed('right'):
		print("RIGHT")
		if (currpos == RIGHT): return
		if (currpos == LEFT):
			currtar = MIDDLE
		else: 
			currtar = RIGHT
		to_target()
	if Input.is_action_pressed('left'):
		print("LEFT")
		if (currpos == LEFT): return
		if (currpos == RIGHT):
			currtar = MIDDLE
		else: 
			currtar = LEFT
		to_target()


func _physics_process(delta):
    get_input()
	