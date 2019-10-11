"""
Author: Brandon
Description: 
"""
extends Node2D

signal health_updated(health)
signal died

export (int) var health = 10
export (int) var max_health = 100
export (int) var damage_points = 100
export (int) var destruction_points = 500;

onready var sprite = $Sprite
onready var anim = $AnimationPlayer

func _ready():
	print(health, max_health);
	$Health.update_max_health(max_health)
	$Health.update_health(health)


func _on_EnemyHurtbox_damaged(damage):
	$AnimationPlayer.play("damage");
	_set_health(health-damage)
	
	#cheap score mechanism
	Global.update_header(Global.numremaining, Global.numtotal, Global.numcoin + damage_points);
	
func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, health)
	if health != prev_health:
		$Health.update_health(health)
		if health == 0:
			on_death()
	
		
func on_death():
	Global.update_header(Global.numremaining, Global.numtotal, Global.numcoin + damage_points);
	emit_signal("died", self)	
	