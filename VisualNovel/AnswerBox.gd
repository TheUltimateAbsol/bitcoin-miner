extends VBoxContainer

var result;
signal has_result

func get_answer():
	GlobalFX.play_sound(GlobalFX.ARROW_ENTRANCE)
	for b in get_children():
		b.entrance_animation();

func _on_Button_pressed(button):
	for b in get_children():		
		if b == button:
			GlobalFX.play_sound(GlobalFX.CHOICE_SELECTION)
			GlobalFX.delay_sound(GlobalFX.CHOICE_JUMP, 0.1)
			b.selected_animation()
			result = b.next_id
			b.connect("animation_finished", self, "end", [], CONNECT_ONESHOT)
		else:
			b.not_selected_animation()

#wakes up the process
func end():
	emit_signal("has_result")

func add_answer(text, next_id):
	for b in get_children():
		if not b.visible:
			b.set_data(text, next_id)
			break
	
func reset():
	for b in get_children():
		b.hide();
