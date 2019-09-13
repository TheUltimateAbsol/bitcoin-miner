extends Node

var num_bots = 0;
enum NavPointTypes {NONE, PLATFORM, LEFT_EDGE, RIGHT_EDGE, SOLO}

var numremaining = 1
var numtotal = 10
var numcoin = 100000

enum NavLinkTypes {NONE, FLOOR, JUMP}

func update_header(input_remaining, input_total, input_coin):
	emit_signal("header_update", input_remaining, input_total, input_coin);
	
signal header_update
