extends Control
class_name AnswerButton

signal pressed(button)
signal animation_finished

var next_id = -1

#Populates data and also validates the button
func set_data(xtext, xnext_id):
	$Arrow/Label.text = xtext
	next_id = xnext_id
	visible = true

func _on_Button_pressed():
	emit_signal("pressed", self)
	


func entrance_animation():
	$AnimationPlayer.play("arrow")
	
func selected_animation():
	$AnimationPlayer.play("selected")
	
func not_selected_animation():
	$AnimationPlayer.play("notSelected")


func _on_AnimationPlayer_animation_finished(_anim_name):
	emit_signal("animation_finished")
