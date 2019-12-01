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
	
	
#	var asdf = Timer.new()
#	asdf.wait_time = 0.25;
#	add_child(asdf) #to process
#	asdf.start() #to start
#	yield(asdf, "timeout");
		
		
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
	
	print('Command completed for real');
	#LOCK THIS OPERATION
	num_completed+=1
	#END LOCK
	
	if (num_completed >= Global.num_bots): 
		emit_signal("command_completed");
	
	if actor.dead: return null;

	return next.perform_command(bot);


#precondition: is linked to another node
func force_end():
	if next == null:
		push_error("Command is not linked to next instruction but is ended!");
		
	must_wait = false;
	emit_signal("force_end_signal");

	
func link(command : Command):
	next = command;
	
	