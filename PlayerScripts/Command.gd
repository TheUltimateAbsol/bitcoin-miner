extends Object

class_name Command

var num_started = 0;
var num_completed = 0;
#signal event_completed
signal command_completed

func init():
	pass;

func perform_command(bot, world):
	var temp;
	#LOCK THIS OPERATION
	num_started+=1
	temp = num_started;
	#END LOCK
	yield(_do_command(bot, world), "completed")
	#LOCK THIS OPERATION
	num_completed+=1
	if (num_completed >= Global.num_bots):
		emit_signal("command_completed");
	#END LOCK

func _do_command(bot, world):
	pass;