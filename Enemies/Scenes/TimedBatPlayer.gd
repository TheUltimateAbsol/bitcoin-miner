extends Node2D

export (float) var interval = 3.0;
export (float) var speed = 1.0;
var is_left = true;

func _ready():
	$Timer.wait_time = interval;
	$Timer.start();

func cycle():
	if is_left:
		$AnimationPlayer.play("Forward", -1, speed);
		is_left = false;
	else:
		$AnimationPlayer.play("Back", -1, speed);
		is_left = true;
	yield($AnimationPlayer, "animation_finished");
	$Timer.start();
	
func _on_Timer_timeout():
	cycle();
