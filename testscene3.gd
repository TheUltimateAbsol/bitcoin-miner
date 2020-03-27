extends Node2D

func _ready():
	pass


func _on_Timer_timeout():
	print("reset")
	$Timer2.start(2)

func _on_Timer2_timeout():
	print("oh no")
