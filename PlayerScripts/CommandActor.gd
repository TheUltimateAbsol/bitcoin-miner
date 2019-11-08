extends Node

class_name CommandActor

var bot;
var command;

signal finished_command;

func _init(xbot, xcommand):
	bot = xbot;
	command = xcommand;
	bot.connect("died", self, "finished_command");
	

func do_command(type, must_wait, path):
	if not not(bot): #as long as we have a valid bot :)	
		match type:
			Global.CommandTypes.IDLE:
				if not must_wait: return null;
				yield(command, "force_end_signal");
			Global.CommandTypes.DUCK:
				if not must_wait: 
					yield(bot.quick_duck(), "completed");
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
			
	emit_signal("finished_command");