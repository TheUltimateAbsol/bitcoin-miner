"""
Author: Brandon
Description: 
"""
extends Node2D

signal health_updated(health)
signal died

export (int) var health = 100
export (int) var max_health = 100
onready var sprite = $Sprite
onready var anim = $AnimationPlayer

func _ready():
	$Health.update_health(health)
	$Health.update_max_health(max_health)

func _on_EnemyHurtbox_damaged(damage):
	$AnimationPlayer.play("damage");
	_set_health(health-damage)
	
	#cheap score mechanism
	Global.update_header(Global.numremaining, Global.numtotal, Global.numcoin + 100);
	
func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, health)
	if health != prev_health:
		$Health.update_health(health)
		
func on_death():
	emit_signal("died")	
	