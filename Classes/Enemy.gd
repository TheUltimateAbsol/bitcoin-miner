extends Node2D

export (int) var health = 100
onready var sprite = $Sprite
onready var anim = $AnimationPlayer

func _on_EnemyHurtbox_damaged(damage):
	$AnimationPlayer.play("damage");
	health-=damage
	Global.update_header(Global.numremaining, Global.numtotal, Global.numcoin + 100);