extends Node

class_name CommandActor

var bot;
var command;
var dead = false;
var timer:TimerRequest = null;

signal finished_command;

func _init(xbot, xcommand):
	bot = xbot;
	command = xcommand;
	var real_timer = Timer.new();
	command.add_child(real_timer);
	timer = TimerRequest.new(real_timer);
	bot.connect("died", self, "escape_command");
	
func escape_command():
	dead = true;
	emit_signal("finished_command");

func do_command(type, must_wait, path, time_to_execute):
	command.connect("force_end_signal", self, "set_timer");
					
	if not not(bot): #as long as we have a valid bot :)	
		match type:
			Global.CommandTypes.IDLE:
				if not must_wait: return null;
				yield(command, "force_end_signal");
			Global.CommandTypes.DUCK:
				if not must_wait: 
					#yield(bot.quick_duck(), "completed");
					yield(bot.quick_duck(), "completed")
				else:
					bot.duck_action(command, "force_end_signal")
					yield(command, "force_end_signal")
			Global.CommandTypes.MOVE:
				bot.follow_path(path);
				yield(bot, "path_traversed");
			Global.CommandTypes.MINE:
				if not must_wait: return null;
				bot.attack(command, "force_end_signal")
				yield(command, "force_end_signal");
			Global.CommandTypes.JUMP:
				bot.connect("jump_ended", self, "stop_timer")
				timer.start(time_to_execute); #some bogus value
				bot.do_jump();
				yield(timer, "timeout");
				bot.disconnect("jump_ended", self, "stop_timer")
			Global.CommandTypes.SUPER_JUMP:
				bot.connect("jump_ended", self, "stop_timer")
				timer.start(time_to_execute); #some bogus value
				bot.do_super_jump();
				yield(timer, "timeout");
				bot.disconnect("jump_ended", self, "stop_timer")
			Global.CommandTypes.MIDAIR_ATTACK:
				bot.do_midair_attack();
				yield(bot, "midair_attack_ended");
			Global.CommandTypes.GROUND_POUND:
				bot.do_ground_pound();
				yield(bot, "ground_pound_ended");
			Global.CommandTypes.HANG:
				if not must_wait: 
					pass
#					yield(bot.quick_duck(), "completed")
				else:
					bot.hang_action(command, "force_end_signal")
					yield(command, "force_end_signal")
			Global.CommandTypes.FALL:
				bot.connect("jump_ended", self, "stop_timer")
				timer.start(time_to_execute); #some bogus value
				bot.do_fall();
				yield(timer, "timeout");
				bot.disconnect("jump_ended", self, "stop_timer")

#	print("finished_command")
	command.disconnect("force_end_signal", self, "set_timer");
	emit_signal("finished_command");
	timer.delete(); #Deletes both the real timer and the wrapper
	
func set_timer(time):
	if time < 0: return
	var time_elapsed = timer.time_elapsed()
	var new_time = time - time_elapsed
#	print("new time", new_time)
	if new_time > 0:
		timer.start(new_time)
	else:
		timer.force_end()
		
func stop_timer():
	timer.force_end()
	
	
