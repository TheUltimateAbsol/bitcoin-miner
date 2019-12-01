extends Node2D

export (float) var interval = 3.0;
export (float) var speed = 1.0;

const NUM_ATTACKS = 3;
enum {LEFT=0, RIGHT=1, CRAZY=2}
var attack = LEFT;

func _ready():
	$Timer.wait_time = interval;
	$Timer.start();

func cycle():
	match attack:
		LEFT:
			yield(attack_left(), "completed");
		RIGHT:
			yield(attack_right(), "completed");
		CRAZY:
			yield(crazy_attack(), "completed");
			
	attack = (attack+1)%NUM_ATTACKS;
	print("ATTACK + " + str(attack));
	$Timer.start()
	
func attack_left():
	$AttackLeft/PathFollow2D/RemoteTransform2D.set_remote_node($Enemy.get_path());
	$AnimationPlayer.play("AttackLeft");
	yield($AnimationPlayer, "animation_finished"); 
	$AttackLeft/PathFollow2D/RemoteTransform2D.set_remote_node(NodePath());
	
func attack_right():
	$AttackRight/PathFollow2D/RemoteTransform2D.set_remote_node($Enemy.get_path());
	$AnimationPlayer.play("AttackRight");
	yield($AnimationPlayer, "animation_finished"); 
	$AttackRight/PathFollow2D/RemoteTransform2D.set_remote_node(NodePath());
	
func crazy_attack():
	$CrazyAttack/PathFollow2D/RemoteTransform2D.set_remote_node($Enemy.get_path());
	$AnimationPlayer.play("CrazyAttack");
	yield($AnimationPlayer, "animation_finished"); 
	$CrazyAttack/PathFollow2D/RemoteTransform2D.set_remote_node(NodePath());