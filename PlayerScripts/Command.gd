extends Node

class_name Command

var SpawnPath = preload("res://SpawnPath.tscn")
var must_wait = true
var time_to_execute = 4096
var type
var path
var next = null;
var last = false;
var start_position:Vector2
var start_facing_right:bool

var num_spawning = 0;
var num_waiting = 0;
var num_started = 0;
var num_completed = 0;
#signal event_completed
signal command_completed
signal force_end_signal
signal next_set

enum {WAIT, ADVANCE, DEAD}

func _init(xtype, xpath, model:Miner):
	type = xtype
	path = xpath	
	name = "Command"	
	
	start_position = model.position
	start_facing_right = model.is_facing_right
	
	var tempSprite = Sprite.new()
	tempSprite.texture = model.get_node("Sprite").texture
	tempSprite.hframes = model.get_node("Sprite").hframes
	tempSprite.vframes = model.get_node("Sprite").vframes
	tempSprite.offset = model.get_node("Sprite").offset
	tempSprite.frame = model.get_node("Sprite").frame
	tempSprite.flip_h = not start_facing_right;
	tempSprite.position = start_position;
	tempSprite.modulate = Color(1, 1, 1, 0.3);
	tempSprite.z_index = -1
	add_child(tempSprite)
	
func spawn_at_beginning(bot:Miner, animate=true):
	bot.position = start_position
	bot.is_facing_right = start_facing_right
	
	if animate:
#		lock this operation
		num_spawning +=1
		
		bot.freeze()
		var path = SpawnPath.instance()
		add_child(path);
		path.load_params(start_position, start_facing_right)
		path.play(bot)
		
		# In case we force a respawn during the antimation
		var end = MultiSignal.new()
		end.attach(bot, "died")
		end.attach(path, "path_completed")
		yield(end, "fired")
		end.detach_all()
		
		path.queue_free();
		bot.unfreeze()
		
#		lock this operation
		num_spawning -=1
	
	return;

#Returns 1 if it should continue, 0 if it exceeded the pace, and -1 if it's dead
func perform_command(bot:Miner)->int:	
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
		
		var end = MultiSignal.new()
		end.attach(bot, "died")
		end.attach(timer, "timeout")
		yield(end, "fired")
		end.detach_all()
	
	#LOCK THIS OPERATION
	num_waiting-=1
	num_started+=1
	#END LOCK
	
	if bot.death_state == Miner.DeathState.NONE:
		var actor = CommandActor.new(bot, self);
		#Wait if it needs waiting for completion
		var func_pointer = actor.do_command(type, must_wait, path, time_to_execute);
		
		if func_pointer != null:
			yield(actor, "finished_command") #Even if the miner dies, this will still activate
	
	#LOCK THIS OPERATION
	num_completed+=1
	#END LOCK
	
	check_completion()
	
	if not bot.death_state == Miner.DeathState.NONE:
		return DEAD
	
	if next == null:
		return WAIT;
	else:
		return ADVANCE;

func check_completion()->bool:
	if (num_completed == num_started and num_waiting == 0 and num_spawning == 0 and last): 
		emit_signal("command_completed")
		return true;
	return false;

#precondition: is linked to another node
func force_end(new_time_to_execute):
	if next == null:
		push_error("Command is not linked to next instruction but is ended!");
		
	must_wait = false;
	#We use negative values to simply say
	#"Please just let the command go all the way through
	#No force ending"
	if new_time_to_execute >= 0:
		time_to_execute = new_time_to_execute
	emit_signal("force_end_signal", time_to_execute);
	
func link(command : Command):
	next = command;
	emit_signal("next_set");
	
#func delay_next(bot):
##	print("NOTE: BOT GOT AHEAD OF PLAYER");
#	yield(self, "next_set");
#	return ADVANCE;
	
