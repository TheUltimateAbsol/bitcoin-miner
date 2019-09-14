extends Node2D

onready var remaining = $remaining
onready var total = $total
onready var coin = $coin
onready var normal_style = load("res://Style/DEFAULT_TEXT.tres")
onready var impact_style = load("res://Style/IMPACT_TEXT.tres")

func update_data(input_remaining, input_total, input_coin):
	Global.numremaining = input_remaining
	Global.numtotal = input_total
	Global.numcoin = input_coin
	remaining.text = str(Global.numremaining)
	total.text = str(Global.numtotal)
	coin.text = str(Global.numcoin)
	
	if (Global.numremaining == Global.numtotal):
		remaining.theme = impact_style
	else:
		remaining.theme = normal_style
		
	if (Global.numremaining < float(Global.numtotal)/4):
		$flash.play("flash");
	else:
		$flash.stop();
		
func _ready():
	update_data(Global.numremaining, Global.numtotal, Global.numcoin)
	Global.connect("header_update", self, "update_data");
	

	
	