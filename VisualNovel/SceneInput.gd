extends InputBase


#DEPRECATED


#
#onready var music_list = $GridContainer/musicList
#onready var scene_transition_list = $GridContainer/transition_list
#onready var background_list = $GridContainer/background_list
#
#var background_buttons = ButtonGroup.new()
#var music_buttons = ButtonGroup.new()
#var scene_transition_buttons = ButtonGroup.new()
#
#func _ready():
#	var background_keys = VNGlobal.Backgrounds.keys()
#	for key in background_keys:
#		var new_box = CheckBox.new()
#		new_box.text = key
#		new_box.set_button_group(background_buttons)
#		if new_box.text == "NONE":
##			new_box.set_modulate(Color( 1, 0, 0, 1 ))
#			new_box.pressed = true 
#		background_list.add_child(new_box)
#
#	var music_keys = VNGlobal.Music.keys()
#	for key in music_keys:
#		var new_box = CheckBox.new()
#		new_box.text = key
#		new_box.set_button_group(music_buttons)
#		if new_box.text == "NONE":
#			new_box.pressed = true
#		music_list.add_child(new_box)
#
#	var back_tansition_keys = VNGlobal.Background_transitiosn.keys()
#	for key in back_tansition_keys:
#		var new_box = CheckBox.new()
#		new_box.text = key
#		new_box.set_button_group(scene_transition_buttons)
#		if new_box.text == "NONE":
#			new_box.pressed = true
#		scene_transition_list.add_child(new_box)
#
#
#func get_data():
#	var music
#	var background
#	var scene_transition
#
#	if background_buttons.get_pressed_button() == null:
#		background = VNGlobal.Backgrounds.NONE
#	else:	
#		background = background_buttons.get_pressed_button().text
#
#
#	if scene_transition_buttons.get_pressed_button() == null:
#		scene_transition = VNGlobal.Background_transitiosn.NONE
#	else:
#		scene_transition = scene_transition_buttons.get_pressed_button().text
#
#
#	if music_buttons.get_pressed_button() == null:
#		music = VNGlobal.Music.NONE
#	else:
#		music = music_buttons.get_pressed_button().text
#
#	return {
#		"music": music, 
#		"background":background,
#		"scene_transition": scene_transition
#	};
#
#func load_data(music, background, scene_transition):
#	for button in music_buttons.get_buttons():
#		if music == button.text:
#			button.set_pressed(true);
#	for button in background_buttons.get_buttons():
#		if background == button.text:
#			button.set_pressed(true);
#	for button in scene_transition_buttons.get_buttons():
#		if scene_transition == button.text:
#			button.set_pressed(true);
