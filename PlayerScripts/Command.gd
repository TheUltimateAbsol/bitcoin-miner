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
signal next_set

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
	
	var actor = CommandActor.new(bot, self);
	#Wait if it needs waiting for completion
	var func_pointer = actor.do_command(type, must_wait, path);
	
	if func_pointer != null:
		yield(actor, "finished_command") #Even if the miner dies, this will still activate
	
	#LOCK THIS OPERATION
	num_completed+=1
	#END LOCK
	
	if (num_completed >= Global.num_bots): 
		emit_signal("command_completed");
	
	if actor.dead: return null;
	
	if next == null:
		return delay_next(bot);
	else:
		return next.perform_command(bot);


#precondition: is linked to another node
func force_end():
	if next == null:
		push_error("Command is not linked to next instruction but is ended!");
		
	must_wait = false;
	emit_signal("force_end_signal");

	
func link(command : Command):
	next = command;
	emit_signal("next_set");
	
func delay_next(bot):
	print("NOTE: BOT GOT AHEAD OF PLAYER");
	yield(self, "next_set");
	return next.perform_command(bot);
	