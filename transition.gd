extends Control

onready var arrow_node = $arrow
onready var sceneLabel = $arrow/scene_arrow/Label
onready var sceneLabelTxt = $arrow/scene_arrow/Label
onready var animation = $arrow/AnimationPlayer
onready var sprite_anim = $arrow/Control/Sprite/AnimationPlayer
onready var sprite = $arrow/Control
onready var mask = $effect

onready var wipe = preload("res://VisualNovel/textures/wipe.png")
onready var default = preload("res://VisualNovel/textures/gradient_lr.png")

signal transition_completed

func _ready():
#	clean up our mess
	sprite.hide();
	arrow_node.hide();
	mask.hide();
	arrow_node.modulate = Color(0,0,0,0);
	sceneLabelTxt.text = ""
#	transition_out()
#	yield(self, "transition_completed")
#	transition_in("asdf");

#note: I was really lazy here. It would be best if we had an array of filters
func transition_out():
	$effect.material.set_shader_param("filter",default)
	_transition_out()
	
func _transition_out():
	mask.show();
	$Tween.interpolate_property(mask, "cutoff", 0.0, 1.0, 1.5, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
	$Tween.start()
	
	yield($Tween, "tween_completed")
	emit_signal("transition_completed");
	
func transition_out2():
	$effect.material.set_shader_param("filter",wipe)
	_transition_out()
	
func transition_in(new_text:String):
	sprite_anim.stop(true)
	sprite.show()
	arrow_node.show();
	
	animation.play("old label");
	yield(animation, "animation_finished")
	
	sceneLabelTxt.text = new_text
	animation.play("new label")	
	sprite_anim.play("Flip")
	yield(animation, "animation_finished")
	
	$Tween.interpolate_property($"effect", "cutoff", 1.0, 0.0, 1.5, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	
	animation.play("fade_away")
	yield(animation, "animation_finished")
	
#	Cleanup
	mask.hide();
	sprite.hide();
	arrow_node.hide();
	
	emit_signal("transition_completed");
	
	
func transition_entrance(new_text:String):
	arrow_node.show();
	
	sceneLabelTxt.text = new_text
	animation.play("new label")	
	yield(animation, "animation_finished")
	
	$Tween.interpolate_property($"effect", "cutoff", 1.0, 0.0, 1.5, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	
	animation.play("fade_away")
	yield(animation, "animation_finished")
	
#	cleanup
	arrow_node.hide();
	mask.hide();
	
	emit_signal("transition_completed");
