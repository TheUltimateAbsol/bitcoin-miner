extends Node

var num_bots = 0;
enum NavPointTypes {NONE, PLATFORM, LEFT_EDGE, RIGHT_EDGE, SOLO}


var numremaining = 1
var numtotal = 10
var numcoin = 100000

enum NavLinkTypes {NONE, FLOOR, JUMP, FALL}

func update_header(input_remaining, input_total, input_coin):
	emit_signal("header_update", input_remaining, input_total, input_coin);
	
	
enum Characters {NONE, swagmaster, cool_boi, bad_boi}
enum Transitions{NONE, FLASH, FADE, SLIDE_RIGHT, SLIDE_LEFT}
enum Expressions{DEFAULT, HAPPY, SCARED}
enum Music{SAME, NONE, SIMPLE, SAD}
enum Background{SAME, NONE, CLASSROOM}
enum SoundEffect{NONE, DING, THWACK, WHACK}

signal header_update
