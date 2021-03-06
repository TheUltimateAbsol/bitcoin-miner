extends Control

const SENTENCE_SPEEDS = {
	VNGlobal.SentenceSpeeds.DEFAULT : 1.5,
	VNGlobal.SentenceSpeeds.FAST : 2.0,
	VNGlobal.SentenceSpeeds.SLOW : 1.0
}

const DELAY_LENGTHS = {
	VNGlobal.DelayLengths.DEFAULT : 0.3,
	VNGlobal.DelayLengths.SHORT : .1,
	VNGlobal.DelayLengths.LONG : .5,
	VNGlobal.DelayLengths.NONE : 0.0
}

const HEAD_HEIGHTS = {
	VNGlobal.Characters.NONE: 0.0,
	VNGlobal.Characters.ALFRED: 0.14215,
	VNGlobal.Characters.ANNA: 0.29396,
	VNGlobal.Characters.CHAD: 0.14563,
	VNGlobal.Characters.CHRISTOPHER: 0.11611,
	VNGlobal.Characters.COACH: 0.13729,
	VNGlobal.Characters.ELIZABETH: 0.21646,
	VNGlobal.Characters.JACK: 0.25646,
	VNGlobal.Characters.JUNE: 0.20451,
	VNGlobal.Characters.SHAUN: 0.14278,
	VNGlobal.Characters.SIMON: 0.21646,
	VNGlobal.Characters.CLAIRE: 0.21646
}

const CHAR_WAIT = 1.0/25

export (bool) var autoplay = false;

onready var dialogue_label = $Control/TextBoxes/Dialogue/Text
onready var name_label = $Control/TextBoxes/Dialogue/Node2D/Name
onready var thought_label = $Control/TextBoxes/Thought/Text
onready var text_boxes = $Control/TextBoxes
# Control/Panel/MarginContainer/Control/TextLabel
onready var npc = $Control/NPC
onready var NPCTransitionPlayer = $Control/NPC/AnimationPlayer
onready var answerBox = $Control/AnswerBox
onready var background = $BackgroundContainer/Background
onready var popup_image = $PopupImage
onready var	popup_image_panel = $PopupImage/Background/MarginContainer/Panel
onready var transition_mask = $TransitionMask;

onready var textbox_dialogue = $Control/TextBoxes/Dialogue
onready var textbox_nextArrow = $Control/TextBoxes/NextArrow
onready var textbox_thought = $Control/TextBoxes/Thought
onready var textbox_thought_animation = $Control/TextBoxes/Thought/AnimationPlayer
onready var textbox_dialogue_animation = $Control/TextBoxes/Dialogue/Node2D/AnimationPlayer

onready var conclusion_animation = $Conclusion/AnimationPlayer

onready var flashyflashyanim = $FlashyFlashy/AnimationPlayer
onready var effect_player_container = $Control/NPC/EffectPlayerContainer
onready var effect_player = $Control/NPC/EffectPlayerContainer/EffectPlayer

#timer stuff
onready var letter_timer : TimerRequest = TimerRequest.new($LetterTimer);
onready var delay_timer : TimerRequest = TimerRequest.new($DelayTimer);

enum {PLAYING, WAITING, UNSET}

signal start_game
signal end_game
signal goto_next_page
signal transition_finished

var save_data : Array;
var tap_skip = true;
var skipped = false;
var state = UNSET;
var current_character = VNGlobal.Characters.NONE;

var id = 0;
var btn_pressed = ""
#SAME":"SAME", "NONE":"NONE", "CLASSROOMA":"CLASSROOMA", "CLASSROOMB":"CLASSROOMB", "HALLWAY":"HALLWAY", "GYMlOCKER":"GYMLOCKER", "BUS":"BUS", "BEACH":"BEACH", "CAFETERIA":"CAFETERIA", "BEDROOM":"BEDROOM"}

var expressions = {}
const backgrounds = {}
const images = {}

var data_json

func reset_dialogue():
	dialogue_label.text = ""
	name_label.text = ""
	thought_label.text = ""
	npc.texture = null
	answerBox.visible = false
	current_character = VNGlobal.Characters.NONE;
	$Control/TextBoxes/Thought.hide();
	$Control/TextBoxes/Dialogue.hide();

func _ready():
	reset_dialogue()
	
	for key in VNGlobal.Characters.keys():
		if key != VNGlobal.Characters.NONE:
			expressions[key] = {}
			for expression in VNGlobal.Expressions.keys():
				expressions[key][expression] = load("res://VisualNovel/Characters/Expressions/"+String(key).to_lower()+ "/" + String(expression).to_lower()+".png")	
	
	for image in VNGlobal.Images.keys():
		images[image] = load("res://VisualNovel/Images/"+String(image).to_lower()+".png")	
	
	for background in VNGlobal.Backgrounds.keys():
		if background != VNGlobal.Backgrounds.SAME:
			backgrounds[background] = load("res://VisualNovel/Backgrounds/"+String(background).to_lower()+".png")	
	
	
	VNGlobal.connect("user_input", self, "attempt_skip");
	load_data("res://VisualNovel/data.json");
	if autoplay:
		play();

func find_save_data_page(id):
	for page in save_data:
		if page.id == id:
			return page;
	return null;

func play():
#
	var endPage = false
	while !endPage:
		skipped = false
		for page in save_data:
			if page.id != id: continue
			
			if page is ContentPage:
				var func_pointer = display_page(page)
				
				if func_pointer:
					yield(func_pointer, "completed")
					
				state = WAITING
				
#				We don't need to wait if the next page is a questionpage
				var next_page = find_save_data_page(page.next_id) 
				if next_page != null and next_page is QuestionPage:
					pass #skip question page waiting
				elif page.rant:
					pass #we keep going when ranting
				else:
					textbox_nextArrow.visible = true;
					yield(self, "goto_next_page")
					GlobalFX.play_sound(GlobalFX.PAGE_SWITCH)
				
			elif page is QuestionPage:
				var func_pointer = display_page(page)
				
				if func_pointer:
					yield(func_pointer, "completed")
					
				state = WAITING
				
#			No yielding because we already do so waiting for an answer
#			yield(self, "goto_next_page")
			elif page is EndPage:
				display_page(page)
				endPage = true
			elif page is TransitionPage:
				var func_pointer = display_page(page);
				if func_pointer:
					yield(func_pointer, "completed")
			else:
				display_page(page)
			
#			Because we already handled it
			if not page is QuestionPage:
				id = page.next_id;
			
			
			if page is ConditionalBranchPage:
				if page.should_branch():
					id = page.target_id;
					
			break



func play_json(json_data : Dictionary):
	display_page(VNGlobal.deserialize(json_data));


func display_page(page:Page):
	if state == PLAYING: return;
	
	textbox_nextArrow.visible = false;
	
	state = PLAYING;
	if page is ContentPage:
		
#		Find the target character
#		If it's not the same as last time, we transition into it
		var is_new_character = false;
		var target_image;
		
		if page.use_last_character:
			target_image = npc.texture;
		elif page.character_image == VNGlobal.Characters.NONE: 
			target_image = null;
		else:
			target_image = expressions[page.character_image][page.character_expression]
		
		if not page.use_last_character and current_character != page.character_image and npc.visible:
			is_new_character = true;
#		if npc.texture != target_image and npc.visible:
#			is_new_character = true;
		
		npc.show()
		effect_player_container.anchor_top = HEAD_HEIGHTS[page.character_image]
		
		if not is_new_character:
			npc.texture = target_image;
		else:
			current_character = page.character_image;
			match page.character_transition:
				VNGlobal.CharacterTransitions.DEFAULT:
					NPCTransitionPlayer.queue_out_in("Fade In", "Fade In", target_image, true, false);
		
		var target_label:Label
		if (page.is_thought):
			target_label = thought_label;
			dialogue_label.text = "" # This is so we can check for sequential speakers
			name_label.text = ""
			thought_label.text = ""
			textbox_dialogue.hide();
			
#			If we weren't already thinking
			if not textbox_thought.visible:
				textbox_thought.show();
				textbox_thought_animation.play("Entrance")
				yield(textbox_thought_animation, "animation_finished")
				

		else:
			target_label = dialogue_label;
			thought_label.text = "" # This is so we can check for sequential speakers
			dialogue_label.text =""
#			If we weren't talking or there's a new speaker
			print(not textbox_dialogue.visible);
			if not textbox_dialogue.visible or name_label.text != page.speaker_name:
				textbox_dialogue.modulate = Color(0,0,0,0)
				name_label.text = page.speaker_name
				textbox_thought.hide();
				textbox_dialogue.show();
				textbox_dialogue_animation.play("Entrance")
				yield(textbox_dialogue_animation, "animation_finished")
				
			
		for sentence in page.content:
			prepend_sentence(sentence, target_label);
		target_label.set_visible_characters(0);
		
		for sentence in page.content:
			var func_pointer = write_sentence(sentence, target_label)
			if func_pointer:
				yield(func_pointer, "completed"); #tells program to wait on everything until this function finishes/this happens
		
	elif page is GameStartPage:
		emit_signal("start_game", page.game_dir);
		tap_skip = false;
	elif page is GameEndPage:
		emit_signal("end_game");
		tap_skip = true;
	elif page is EndPage:
		print("ENDING");
		conclusion_animation.play("Activate");
	elif page is QuestionPage:
		answerBox.visible = true
		answerBox.reset()
		for answer in page.answers:
			answerBox.add_answer(answer.content, answer.next_id)
			
		answerBox.get_answer()
		yield(answerBox, "has_result")
		print(answerBox.result);
		id = answerBox.result
		
		answerBox.visible = false
		print(id)
	elif page is TransitionPage:
		match (page.transition_type):
			VNGlobal.SceneTransitions.NONE:
				if page.next_background != VNGlobal.Backgrounds.SAME:
					background.texture = backgrounds[page.next_background];
				if page.next_music != VNGlobal.Music.SAME:
					GlobalMusic.play_track(page.next_music);
			VNGlobal.SceneTransitions.SCENESWITCH:
				if page.next_music != VNGlobal.Music.SAME:
					GlobalMusic.fade_out()
				transition_mask.transition_out();
				yield(transition_mask, "transition_completed")
				
				if page.next_background != VNGlobal.Backgrounds.SAME:
					background.texture = backgrounds[page.next_background];
				if page.next_music != VNGlobal.Music.SAME:
					GlobalMusic.queue_track(page.next_music);
				reset_dialogue();
				
				npc.texture = null
					
				transition_mask.transition_in(page.next_name);
				yield(transition_mask, "transition_completed");
				
			VNGlobal.SceneTransitions.ENTRANCE:
				if page.next_music != VNGlobal.Music.SAME:
					GlobalMusic.fade_out()
				transition_mask.transition_out();
				yield(transition_mask, "transition_completed")
				
				if page.next_background != VNGlobal.Backgrounds.SAME:
					background.texture = backgrounds[page.next_background];
				if page.next_music != VNGlobal.Music.SAME:
					GlobalMusic.queue_track(page.next_music);
				reset_dialogue()
				
				npc.texture = null
					
				transition_mask.transition_entrance(page.next_name)
				yield(transition_mask, "transition_completed");
			VNGlobal.SceneTransitions.MUSICFADE:
				if page.next_music != VNGlobal.Music.SAME:
					GlobalMusic.fade_into_track(page.next_music);	
				if page.next_background != VNGlobal.Backgrounds.SAME:
					background.texture = backgrounds[page.next_background];
					
	elif page is ImageTogglePage:
		if page.show:
			popup_image_panel.texture = images[page.image];
			popup_image.get_node("AnimationPlayer").play("Entrance");
		else:
			popup_image.get_node("AnimationPlayer").play_backwards("Entrance");
			
	elif page is SetFlagPage or page is IncrementRelationshipPage:
		page.activate();
	
	state = WAITING


func prepend_sentence (sentence, target_label:Label):
	target_label.text += sentence.content + " ";
	
func count_printable(string:String):
	string = string.replace(" ", "");
	string = string.replace("\n", "");
	string = string.replace("\r", "");
	return string.length();

func write_sentence (sentence, target_label:Label):
	var target = target_label.get_visible_characters() + count_printable(sentence.content);
	var speed = SENTENCE_SPEEDS[sentence.speed];

	var wait_time = (CHAR_WAIT/speed) * count_printable(sentence.content);
	text_boxes.set_target(target_label);
	
	if (skipped == false):
		match(sentence.effect):
			VNGlobal.Effects.SHAKE:
				$Control/TextBoxes/Dialogue/Node2D/Screenshake.start()
				$BackgroundContainer/Background/Screenshake.start()
				GlobalFX.play_sound(GlobalFX.SLAM)
			VNGlobal.Effects.FLASH:
				flashyflashyanim.play("Activate")
			VNGlobal.Effects.FLASH_SHAKE:
				GlobalFX.play_sound(GlobalFX.SLAM)
				flashyflashyanim.play("Activate")
				$Control/TextBoxes/Dialogue/Node2D/Screenshake.start()
				$BackgroundContainer/Background/Screenshake.start()
			VNGlobal.Effects.MUSIC_NOTE:
				effect_player.music_note()
			VNGlobal.Effects.ANGRY:
				effect_player.angry()
			VNGlobal.Effects.EXCLAMATION:
				effect_player.exclamation()
			VNGlobal.Effects.FLOWERY:
				GlobalFX.play_sound(GlobalFX.FLOWERY)
				$Control/flowers.emitting = true
			VNGlobal.Effects.FRUSTRATED:
				effect_player.frustrated()
			VNGlobal.Effects.SWEAT:
				effect_player.sweat()
		
		text_boxes.play(target, wait_time)
		yield(text_boxes, "completed");

	if (skipped == false):
		delay_timer.set_time(DELAY_LENGTHS[sentence.delay]); 
		delay_timer.start();
		yield(delay_timer, "timeout");
		delay_timer.stop();

	if (skipped):
		target_label.visible_characters = target;
	
	print("SENTENCE END");

func skip():
	skipped = true;
	letter_timer.force_end();
	delay_timer.force_end();
	text_boxes.force_end();
	effect_player.reset();

func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)

	dir.list_dir_end()

	return files

func load_data(file_path):	
	var file = File.new()
#	for filename in list_files_in_directory("res://VisualNovel/"):
#		print(filename);
#	print("File exists: ");
#	print(file.file_exists("res://VisualNovel/data.json"));
	var err = file.open("res://VisualNovel/data.json", 1)
	if err:
		push_error("Error " + str(err))
	#converts the json file to a text file
	var text_json = file.get_as_text()
	file.close()
#	print(text_json)
	#parses tect file to dictionary
	var data_json = JSON.parse(text_json)
	#checks to make sure it parsed correctly
#	print(data_json)
	if data_json.error == OK:
#		print("All is good")
		pass
	else:
		print("Error parsing JSON from file");
#		print(typeof(data_json.result))
#		print(data_json.get_error_line())
	if typeof(data_json.result) == TYPE_ARRAY:
#    	print("Array") # prints 'hello'
		pass
	else:
		print("JSON data is not an array")
		
	save_data = data_json.result
		
	#Parse it into pages
	var page_table = []
	for item in save_data:
		page_table.push_back(VNGlobal.deserialize(item));
	save_data = page_table;

func next_page():
	emit_signal("goto_next_page");

func attempt_skip():
	
	if tap_skip == false: return;
	
	match state:
		PLAYING:
			skip();
		WAITING:
			next_page();
		UNSET:
			pass;
