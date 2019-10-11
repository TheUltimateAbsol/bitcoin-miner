extends Node

class_name Command

var must_wait = true
var type
var path
var next = null;

var num_waiting = 0;
var num_started = 0;
var num_completed = 0;
#signal event_completed
signal command_completed
signal force_end_signal

func _init(xtype, xpath=[]):
	type = xtype
	path = xpath

func perform_command(bot):
	#LOCK THIS OPERATION
	num_waiting+=1
	var temp = num_waiting;
	#END LOCK
	

	#Start timer
	#Start countdown using temp
	if type == Global.CommandTypes.MOVE:
		var timer = Timer.new()
		timer.wait_time = temp*(0.1);
		add_child(timer) #to process
		timer.start() #to start
		yield(timer, "timeout");
	
	#LOCK THIS OPERATION
	num_waiting-=1
	num_started+=1
	#END LOCK
	
	#Wait if it needs waiting for completion
	var func_pointer = _do_command(bot);
	if func_pointer != null:
		yield(func_pointer, "completed")
	
	#LOCK THIS OPERATION
	num_completed+=1
	#END LOCK
	
	if (num_completed >= Global.num_bots): #How will this account for lost miners?
		emit_signal("command_completed");
		
	return next.perform_command(bot);


#precondition: is linked to another node
func force_end():
	if next == null:
		push_error("Command is not linked to next instruction but is ended!");
		
	must_wait = false;
	emit_signal("force_end_signal");

	
func _do_command(bot):
	match type:
		Global.CommandTypes.IDLE:
			if not must_wait: return null;
			yield(self, "force_end_signal");
		Global.CommandTypes.DUCK:
			if not must_wait: 
				yield(bot.quick_duck(), "completed");
			else:
				bot.duck_action(self, "force_end_signal")
				yield(self, "force_end_signal")
		Global.CommandTypes.MOVE:
			bot.follow_path(path);
			yield(bot, "path_traversed");
		Global.CommandTypes.MINE:
			if not must_wait: return null;
			bot.attack(self, "force_end_signal")
			yield(self, "force_end_signal");
	
func link(command : Command):
	next = command;
	
	
	
	
	