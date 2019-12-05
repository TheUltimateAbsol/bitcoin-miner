extends Node2D

signal QTE_input
var QTE_Result = false;

func activate():
	visible = true;
	$Circle.visible = false;
	
	var temp = Timer.new();
	temp.wait_time = 1;
	add_child(temp);
	temp.start();
	yield(temp, "timeout");
	temp.queue_free();
	
	$AnimationPlayer.play("Activate");
	InputEventHandler.connect("pressed_attack", self, "QTE_input_handler", [], CONNECT_ONESHOT)
	yield(self, "QTE_input");

	
	visible = false;
	
	return QTE_Result;


func QTE_anim_handler(anim_name):
	QTE_Result = false;
	
	#Release connections
	InputEventHandler.disconnect("pressed_attack", self, "QTE_input_handler");
	emit_signal("QTE_input");
	
func QTE_input_handler():
	print("HELLO WORLD")
	
	var amount = $AnimationPlayer.current_animation_position;
	if ($AnimationPlayer.current_animation_length-0.1 - $AnimationPlayer.current_animation_position < 0.2):
		QTE_Result = true;
	else:
		QTE_Result = false;
	$AnimationPlayer.stop();
	emit_signal("QTE_input");