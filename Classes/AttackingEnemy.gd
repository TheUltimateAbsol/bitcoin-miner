extends Enemy

class_name AttackingEnemy

export (int) var miner_damage = 1;
var num_damage = 0;
	
	
func start_attack():
	$HitBox.set_monitoring(true)
	num_damage = 0;

func stop_attack():
	$HitBox.set_monitoring(false);

func _on_HitBox_body_entered(area):
	if num_damage>=miner_damage: return;
	if area.is_in_group("player"):
		var result = area.damage();
		if result:
			print("DAMAGED PLAYER");
			#LOCK THIS
			num_damage+=1;
			#END LOCK
