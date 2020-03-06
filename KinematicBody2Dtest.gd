extends KinematicBody2D

var first = true;

func _physics_process(delta):
	if first:
		move_and_slide(Vector2(0, 20), Vector2(0, -1))
		first = false;
	move_and_slide(Vector2(3, 0), Vector2(0, -1));
	
	print(is_on_floor());
