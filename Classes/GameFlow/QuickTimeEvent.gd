extends Node2D

signal QTE_input
signal done_button_pressed
var QTE_Result = false;

var actions = ["up", "down", "attack"]
var donePressed = false

func activate():
	visible = true;
	$Circle.visible = false;
	
	Global.minersbought = 0
	Global.minerprice = 10
	
	var temp = Timer.new();
	temp.wait_time = 1;
	add_child(temp);
	temp.start();
	yield(temp, "timeout");
	temp.queue_free();
	#TODO Currently every time this event is called, the initial price will always stay the same. 
	
	#TODO Make it so if the done button isn't pressed, stay waiting for an input.
#	$AnimationPlayer.play("Activate");
	InputEventHandler.connect("qt_input", self, "QTE_input_handler")
	yield(self, "QTE_input");
#	InputEventHandler.disconnect("qt_input", self, "QTE_input_handler");
	
	visible = false;
	
	return QTE_Result;


func QTE_anim_handler(anim_name):
	QTE_Result = false;
	
	#Release connections
	InputEventHandler.disconnect("pressed_attack", self, "QTE_input_handler");
	emit_signal("QTE_input");
	
func QTE_input_handler():
	print("HELLO WORLD")
	if Input.is_action_pressed("attack"):
		#Global.numcoin -= minerPrice
		Global.minersbought += 1
		Global.minerprice += 10 #TODO: Do we want to have the price increase linearly or logarithmically?
		


	# var amount = $AnimationPlayer.current_animation_position;
	# if ($AnimationPlayer.current_animation_length-0.1 - amount < 0.2):
	# 	QTE_Result = true;
	# else:
	# 	QTE_Result = false;
	$AnimationPlayer.stop();
	emit_signal("QTE_input");

func _on_Button_pressed():
	emit_signal("done_button_pressed")
