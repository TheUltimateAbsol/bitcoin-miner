extends Control

const SENTENCE_SPEEDS = {
	VNGlobal.SentenceSpeeds.DEFAULT : 1.0,
	VNGlobal.SentenceSpeeds.FAST : 2.0,
	VNGlobal.SentenceSpeeds.SLOW : 0.5
}

const DELAY_LENGTHS = {
	VNGlobal.DelayLengths.DEFAULT : 0.3,
	VNGlobal.DelayLengths.SHORT : .1,
	VNGlobal.DelayLengths.LONG : 1,
	VNGlobal.DelayLengths.NONE : 0.0
}

const CHAR_WAIT = 1.0/25

export (bool) var autoplay = false;

onready var dialogue_label = $Control/Control/Dialogue/Text
onready var name_label = $Control/Control/Dialogue/Name
onready var thought_label = $Control/Control/Thought/Text
# Control/Panel/MarginContainer/Control/TextLabel
onready var npc = $Control/NPC
onready var transition_player = get_node("Control/NPC/AnimationPlayer")
onready var answerBox = $Control/AnswerBox
onready var background = $Control/Background
onready var popup_image = $PopupImage
onready var	popup_image_panel = $PopupImage/Background/Panel

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

var id = 0;
var btn_pressed = ""
#SAME":"SAME", "NONE":"NONE", "CLASSROOMA":"CLASSROOMA", "CLASSROOMB":"CLASSROOMB", "HALLWAY":"HALLWAY", "GYMlOCKER":"GYMLOCKER", "BUS":"BUS", "BEACH":"BEACH", "CAFETERIA":"CAFETERIA", "BEDROOM":"BEDROOM"}

var expressions = {}
const backgrounds = {}
const images = {}

var data_json

func _ready():
	dialogue_label.text = ""
	name_label.text = ""
	thought_label.text = ""
	npc.texture = null
	answerBox.visible = false
	
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

func play():
#	for page in save_data:
#		if page is ContentPage or page is QuestionPage:
#			skipped = false;
#			var func_pointer = display_page(page)
#
#			if func_pointer:
#				yield(func_pointer, "completed");
#
#			state = WAITING;
#			yield(self, "goto_next_page");
#
#		elif page is MetaPage:
#			display_page(page)
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
				
				yield(self, "goto_next_page")
				
			elif page is QuestionPage:
				var func_pointer = display_page(page)
				
				if func_pointer:
					yield(func_pointer, "completed")
					
				state = WAITING
				
#				No yielding because we already do so waiting for an answer
#				yield(self, "goto_next_page")
			elif page is EndPage:
				display_page(page)
				endPage = true
			elif page is TransitionPage:
				display_page(page);
				yield(self, "transition_finished")
			else:
				display_page(page)
			
#			Because we already handled it
			if not page is QuestionPage:
				id = page.next_id;
			break



func play_json(json_data : Dictionary):
	display_page(VNGlobal.deserialize(json_data));


func display_page(page:Page):
	if state == PLAYING: return;
	
	state = PLAYING;
	if page is ContentPage:
		npc.hide()
		
		if page.character_image == VNGlobal.Characters.NONE: 
			npc.texture = null;
		else:
			npc.texture = expressions[page.character_image][page.character_expression]
		
		#var file2Check = File.new()
		#var doFileExists = file2Check.file_exists(PATH_2_FILE):
		npc.show()
		match page.character_transition:
			VNGlobal.CharacterTransitions.NONE:
				pass;
			VNGlobal.CharacterTransitions.FLASH: #think ace attorny
				# MAKE TRANSITION
				transition_player.play("appear")
				yield(transition_player, "animation_finished")
			VNGlobal.CharacterTransitions.FADE:
				$Control/NPC.modulate = Color(0,0,0,0); #Prevents flashing of sprite
				#transition.add_animation("fade in", transition.get_animation("fade in")) #wHAT IS THIS LINE?
				transition_player.play("fade in")
				yield(transition_player, "animation_finished")
	#			yield(transition, "animation_finished")
			VNGlobal.CharacterTransitions.SLIDE_RIGHT:
				#transition.add_animation("slide_from_right", transition.get_animation("slide_from_right"))
				transition_player.play("slide_from_right")
				yield(transition_player, "animation_finished")
	#			pass
			VNGlobal.CharacterTransitions.SLIDE_LEFT:
				# MAKE TRANSITION
				transition_player.play("slide_from_left")
				yield(transition_player, "animation_finished")
		
		var target_label:Label
		if (page.is_thought):
			target_label = thought_label;
			dialogue_label.text = "" # This is so we can check for sequential speakers
			name_label.text = ""
			thought_label.text = ""
			$Control/Control/Dialogue.hide();
			
#			If we weren't already thinking
			if not $Control/Control/Thought.visible:
				$Control/Control/Thought.show();
				$Control/Control/Thought/AnimationPlayer.play("Entrance")
				yield($Control/Control/Thought/AnimationPlayer, "animation_finished")
				

		else:
			target_label = dialogue_label;
			thought_label.text = "" # This is so we can check for sequential speakers
			dialogue_label.text =""
#			If we weren't talking or there's a new speaker
			print(not $Control/Control/Dialogue.visible);
			if not $Control/Control/Dialogue.visible or name_label.text != page.speaker_name:
				$Control/Control/Dialogue.modulate = Color(0,0,0,0)
				name_label.text = page.speaker_name
				$Control/Control/Thought.hide();
				$Control/Control/Dialogue.show();
				$Control/Control/Dialogue/AnimationPlayer.play("Entrance")
				yield($Control/Control/Dialogue/AnimationPlayer, "animation_finished")
				
			
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
		$Conclusion/AnimationPlayer.play("Activate");
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

		emit_signal("transition_finished")
	elif page is ImageTogglePage:
		if page.show:
			popup_image.get_node("Background/Panel").texture = images[page.image];
			popup_image.get_node("AnimationPlayer").play("Entrance");
		else:
			popup_image.get_node("AnimationPlayer").play_backwards("Entrance");
	
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

	print(sentence.speed, CHAR_WAIT/speed);
	letter_timer.set_time(CHAR_WAIT/speed);
	letter_timer.start();
	
	for i in range(count_printable(sentence.content)):
		if (skipped == false):
			target_label.visible_characters+=1;
			yield(letter_timer, "timeout");
	letter_timer.stop();

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
