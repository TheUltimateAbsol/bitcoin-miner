extends Control

onready var target = $Dialogue/Text
var target_value = 0;
signal completed

func set_target(xtarget):
	target = xtarget
	
func play(xtarget_value, time):
	target_value = xtarget_value;
	
	$CharacterTween.interpolate_property(target, "visible_characters", 
	target.visible_characters, target_value, time, Tween.TRANS_LINEAR, 
	Tween.EASE_IN_OUT)
	
	$CharacterTween.start();
	
func stop():
	$CharacterTween.stop();
	
func force_end():
	$CharacterTween.stop();
	target.visible_characters = target_value;
	emit_signal("completed")

func _on_CharacterTween_tween_completed(object, key):
	emit_signal("completed");
