extends Node

var num_bots = 0;
enum NavPointTypes {NONE, PLATFORM, LEFT_EDGE, RIGHT_EDGE, SOLO}
enum PlayerNames {Simon, Anna, June, Chad, Shaun, Claire, Sophia, Jack}
enum CommandTypes {IDLE, MOVE, MINE, DUCK, JUMP}

var numremaining = 1
var numtotal = 1
var numcoin = 0
var numseconds = 0;
var numenemies = 0;

enum NavLinkTypes {NONE, FLOOR, JUMP, FALL}

func update_header(input_remaining, input_total, input_coin):
	emit_signal("header_update", input_remaining, input_total, input_coin);

signal header_update
