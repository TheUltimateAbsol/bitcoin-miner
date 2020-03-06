extends Control

export (bool) var autoplay = false;

onready var textlabel = get_node("Control/Control/Control/TextLabel")
onready var nameLabel = get_node("Control/Control/Control/NameLabel")
# Control/Panel/MarginContainer/Control/TextLabel
onready var npc = $Control/NPC
onready var transition = get_node("Control/NPC/AnimationPlayer")

onready var letter_timer : TimerRequest = TimerRequest.new($LetterTimer);
onready var delay_timer : TimerRequest = TimerRequest.new($DelayTimer);

enum {PLAYING, WAITING, UNSET}

signal start_game
signal end_game
signal goto_next_page

var save_data : Array;
var tap_skip = true;
var skipped = false;
var state = UNSET;

var expressions = {
	VNGlobal.Characters.SIMON : {
		VNGlobal.Expressions.DEFAULT :  preload("Characters/BoyeNeutral.png")
	},
	VNGlobal.Characters.ANNA : {
		VNGlobal.Expressions.DEFAULT :  preload("res://VisualNovel/Characters/anna fina_.png")
	},
	VNGlobal.Characters.CLAIRE : {
		VNGlobal.Expressions.DEFAULT :  preload("res://VisualNovel/Characters/Claire final.png")
	},
	VNGlobal.Characters.JACK : {
		VNGlobal.Expressions.DEFAULT :  preload("res://VisualNovel/Characters/Jack Final.png")
	},
	VNGlobal.Characters.CHAD : {
		VNGlobal.Expressions.DEFAULT :  preload("res://VisualNovel/Characters/Chad final.png")
	},
	VNGlobal.Characters.JUNE : {
		VNGlobal.Expressions.DEFAULT :  preload("res://VisualNovel/Characters/nannndkkad.png")
	},
	VNGlobal.Characters.SHAUN : {
		VNGlobal.Expressions.DEFAULT :  preload("res://VisualNovel/Characters/shaun finalll.png")
	}
}

var backgrounds = {
	VNGlobal.Backgrounds.CLASSROOM : preload("Backgrounds/classroom_angle.png"),
	VNGlobal.Backgrounds.NONE : preload("Backgrounds/none.png")
}
		
	
var CHAR_WAIT = 1.0/20
var data_json

func _ready():
	textlabel.text = ""
	nameLabel.text = ""
	npc.texture = null
	
	VNGlobal.connect("user_input", self, "attempt_skip");
	load_data("res://VisualNovel/data.json");
	if autoplay:
		play();

func play():
	for page in save_data:
		if page is ContentPage:
			skipped = false;
			var func_pointer = display_page(page)
			
			if func_pointer:
				yield(func_pointer, "completed");
				
			state = WAITING;
			yield(self, "goto_next_page");
			
		elif page is MetaPage:
			display_page(page)
			

func play_json(json_data : Dictionary):
	display_page(VNGlobal.deserialize(json_data));


func display_page(page:Page):
	if state == PLAYING: return;
	
	state = PLAYING;
	if page is ContentPage:
		npc.hide()
		textlabel.text = ""
		nameLabel.text = ""
		textlabel.set_visible_characters(0);
		
		if page.character == VNGlobal.Characters.NONE: 
			npc.texture = null;
		else:
			if expressions[page.character][VNGlobal.Expressions.DEFAULT] == null:
				npc.texture = "";
			else:
				npc.texture = expressions[page.character][VNGlobal.Expressions.DEFAULT]
				var nameID = page.character
				nameLabel.text = VNGlobal.CharacterNames[nameID]
		
		
		#var file2Check = File.new()
		#var doFileExists = file2Check.file_exists(PATH_2_FILE):
		npc.show()
		match page.transition:
			VNGlobal.Transitions.NONE:
				transition.play("appear")
				yield(transition, "animation_finished")
			VNGlobal.Transitions.FLASH: #think ace attorny
				# MAKE TRANSITION
				transition.play("appear")
				yield(transition, "animation_finished")
			VNGlobal.Transitions.FADE:
				$Control/NPC.modulate = Color(0,0,0,0); #Prevents flashing of sprite
				#transition.add_animation("fade in", transition.get_animation("fade in")) #wHAT IS THIS LINE?
				transition.play("fade in")
				yield(transition, "animation_finished")
	#			yield(transition, "animation_finished")
			VNGlobal.Transitions.SLIDE_RIGHT:
				#transition.add_animation("slide_from_right", transition.get_animation("slide_from_right"))
				transition.play("slide_from_right")
				yield(transition, "animation_finished")
	#			pass
			VNGlobal.Transitions.SLIDE_LEFT:
				# MAKE TRANSITION
				transition.play("slide_from_left")
				yield(transition, "animation_finished")
			
		if page.background != VNGlobal.Backgrounds.SAME:
			if backgrounds[page.background] == null:
				$Control/Background.texture = backgrounds[VNGlobal.Backgrounds.CLASSROOM];
			else:
				$Control/Background.texture = backgrounds[page.background];
	# else involves being able to reference previous pages
	
		for sentence in page.content:
			prepend_sentence(sentence);
		textlabel.set_visible_characters(0);
		
		for sentence in page.content:
			var func_pointer = write_sentence(sentence)
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
		npc.hide()
		textlabel.text = ""
		textlabel.set_visible_characters(0);
		
		if page.character == VNGlobal.Characters.NONE: 
			npc.texture = null;
		else:
			if expressions[page.character][page.expression] == null:
				npc.texture = expressions[VNGlobal.SIMON]["DEFAULT"]
			else:
				npc.texture = expressions[page.character][page.expression]
				var nameID = page.character
				nameLabel.text = VNGlobal.CharacterNames[nameID]
		
		
		#var file2Check = File.new()
		#var doFileExists = file2Check.file_exists(PATH_2_FILE):
		if page.background != VNGlobal.Backgrounds.SAME:
			if backgrounds[page.background] == null:
				$Control/Background.texture = backgrounds[VNGlobal.Backgrounds.CLASSROOM];
			else:
				$Control/Background.texture = backgrounds[page.background];
		
		npc.show()
		match page.transition:
			VNGlobal.Transitions.NONE:
				transition.play("appear")
			VNGlobal.Transitions.FLASH: #think ace attorny
				# MAKE TRANSITION
				transition.play("appear")
			VNGlobal.Transitions.FADE:
				$Control/NPC.modulate = Color(0,0,0,0); #Prevents flashing of sprite
				#transition.add_animation("fade in", transition.get_animation("fade in")) #wHAT IS THIS LINE?
				transition.play("fade in")
	#			yield(transition, "animation_finished")
			VNGlobal.Transitions.SLIDE_RIGHT:
				#transition.add_animation("slide_from_right", transition.get_animation("slide_from_right"))
				transition.play("slide_from_right")
	#			pass
			VNGlobal.Transitions.SLIDE_LEFT:
				# MAKE TRANSITION
				transition.play("slide_from_left")
			
	# else involves being able to reference previous pages
	
		for sentence in page.content:
			prepend_sentence(sentence);
		textlabel.set_visible_characters(0);
		
		for sentence in page.content:
			var func_pointer = write_sentence(sentence)
			if func_pointer:
				yield(func_pointer, "completed"); #tells program to wait on everything until this function finishes/this happens
		
		
		
		
	state = WAITING


func prepend_sentence (sentence):
	textlabel.text += sentence.content + " ";
	
func count_printable(string:String):
	string = string.replace(" ", "");
	string = string.replace("\n", "");
	string = string.replace("\r", "");
	return string.length();

func write_sentence (sentence):
	var target = textlabel.get_visible_characters() + count_printable(sentence.content);

	letter_timer.set_time(CHAR_WAIT/sentence.speed);
	letter_timer.start();
	
	for i in range(count_printable(sentence.content)):
		if (skipped == false):
			textlabel.visible_characters+=1;
			yield(letter_timer, "timeout");
	letter_timer.stop();

	if (skipped == false):
		delay_timer.set_time(VNGlobal.DEFAULT_SENTENCE_DELAY); 
		delay_timer.start();
		yield(delay_timer, "timeout");
		delay_timer.stop();

	if (skipped):
		textlabel.visible_characters = target;
	
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