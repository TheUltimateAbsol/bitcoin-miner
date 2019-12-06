extends Node

const CYCLE_TIME = 1.0;
const CYCLE_INTERVAL = 0.01
const NUM_DIGITS = 15;

var skip = false;

func activate(miner: Miner):
	$Background.visible = true;
	
	#Set scores
	var bonus = Global.numenemies*1000
	
	var multiplier = 1.0;
	if Global.numseconds > 60:
		multiplier = 1;
	elif Global.numseconds > 45:
		multiplier = 1.2;
	elif Global.numseconds > 40:
		multiplier = 1.3;
	elif Global.numseconds > 35:
		multiplier = 1.5;
	else:
		multiplier = 2;
		
	var total = (Global.numcoin+bonus)*multiplier;
	
		
	$HBoxContainer2/VBoxContainer3/Enemy.text = str(bonus)
	$HBoxContainer2/VBoxContainer3/Time.text = "x" + str(multiplier).pad_decimals(1)
	$HBoxContainer2/VBoxContainer3/Total.text = str(total)
	$HBoxContainer2/VBoxContainer3/Inventory.text = str(total);
	
	miner.flip_towards($Path2D.curve.get_point_position(0));
	miner.freeze();
	miner.walk();
	
	$Path2D.curve.add_point(miner.position, Vector2(0,0), Vector2(0,0), 0);
	$Path2D/PathFollow2D/RemoteTransform2D.set_remote_node(miner.get_path());

	$AnimationPlayer.play("Activate");
	yield($AnimationPlayer, "animation_finished");
	miner.flip(true);
	miner.level_complete();
	$AnimationPlayer.play("FlashText");
	yield($AnimationPlayer, "animation_finished")
	
	InputEventHandler.connect("released_attack", self, "skip", [], CONNECT_ONESHOT);
	$AnimationPlayer.play("DisplayScores");
	yield($AnimationPlayer, "animation_finished")
	
	yield(InputEventHandler, "released_attack")
	get_parent().emit_signal("room_cleared");
	
func skip():
	print("SKIP");
	skip = true;
	$AnimationPlayer.seek($AnimationPlayer.current_animation_length, true);
	$AnimationPlayer.stop();
	
func roll(path : NodePath):
	var label : Label = get_node(path);
	var to_display = label.get_text();
	var timer = Timer.new()
	timer.wait_time = CYCLE_INTERVAL;
	add_child(timer);
	timer.start();
	
	for i in range(CYCLE_TIME/CYCLE_INTERVAL):
		if not skip:	
			randomize();
			var my_string = str(randf());
			my_string.pad_decimals(NUM_DIGITS);
			my_string = my_string.right(2);
			
			label.text=my_string;
			yield(timer, "timeout");
		
	timer.stop();
	timer.queue_free();
	
	label.set_text(to_display);