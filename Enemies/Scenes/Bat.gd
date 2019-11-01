extends AttackingEnemy

func start_attack():
	.start_attack();
	$AttackPlayer.play("Flap");
	
func stop_attack():
	.stop_attack();
	$AttackPlayer.stop();
	