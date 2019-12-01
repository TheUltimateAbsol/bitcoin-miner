extends Node

var num_bots = 0;
enum NavPointTypes {NONE, PLATFORM, LEFT_EDGE, RIGHT_EDGE, SOLO}
enum CommandTypes {IDLE, MOVE, MINE, DUCK}

var numremaining = 1
var numtotal = 1
var numcoin = 0
var numseconds = 0;

enum NavLinkTypes {NONE, FLOOR, JUMP, FALL}

func update_header(input_remaining, input_total, input_coin):
	emit_signal("header_update", input_remaining, input_total, input_coin);
	
	
enum Characters {NONE, BOY, GIRL}
enum Transitions{NONE, FLASH, FADE, SLIDE_RIGHT, SLIDE_LEFT}
enum Expressions{DEFAULT, HAPPY, SAD}
enum Music{SAME, NONE, SIMPLE, SAD}
enum Backgrounds{SAME, NONE, CLASSROOM}
enum SoundEffect{NONE, DING, THWACK, WHACK}

signal header_update
