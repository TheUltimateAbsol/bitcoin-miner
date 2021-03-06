extends Node2D

onready var remaining = $remaining
onready var total = $total
onready var coin = $coin
onready var normal_style = load("res://Style/DEFAULT_TEXT.tres")
onready var impact_style = load("res://Style/IMPACT_TEXT.tres")

signal add_miner
signal revive

var levels = [300, 1000, 2000, 4000, 6000, 9000, 12000, 15000, 20000, 25000, 30000, 40000, 100000000]
var level = 0;
var num_countdowns = 0;

func update_data(input_remaining, input_total, input_coin):
	Global.numremaining = input_remaining
	Global.numtotal = input_total
	Global.numcoin = input_coin
	
	if Global.numcoin >= levels[level]:
		level = level +1
		emit_signal("add_miner");
		Global.numremaining += 1
		Global.numtotal += 1
	
	remaining.text = str(Global.numremaining)
	total.text = str(Global.numtotal)
	coin.text = str(Global.numcoin)
	
	
	
	if (Global.numremaining == Global.numtotal and not Global.numremaining == 1):
		remaining.theme = impact_style
	else:
		remaining.theme = normal_style
	
	$remaining.visible = true;
	if (Global.numremaining < float(Global.numtotal)/4 or Global.numremaining == 1 and not Global.numremaining == 0):
		$flash.play("flash");
	else:
		$remaining.visible = true;
		$flash.stop();

		
func _ready():
	update_data(Global.numremaining, Global.numtotal, Global.numcoin)
	Global.connect("header_update", self, "update_data");
	
func initiate_countdown():
	$Countdown.stop(true);
	num_countdowns+=1;
	$ProgressBar.visible = true;
#	$Countdown.play("Countdown", -1, 1.0+((num_countdowns-1)*.5));
	$Countdown.play("Countdown", -1, 1.0);
	
func on_Countdown_End(anim_name):
	num_countdowns = 0;
	$ProgressBar.visible = false;
	emit_signal("revive");
	
func stop_countdown():
	$Countdown.stop();
	
func increment_timer():
	var num_seconds = Global.numseconds
	num_seconds += 1;
	$time.text = str(num_seconds/60).pad_zeros(2) + ":" + str(num_seconds%60).pad_zeros(2);
	Global.numseconds = num_seconds
