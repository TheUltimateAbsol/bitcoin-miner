extends Area2D

signal damaged

func take_damage(num_damage):
	emit_signal("damaged", num_damage);