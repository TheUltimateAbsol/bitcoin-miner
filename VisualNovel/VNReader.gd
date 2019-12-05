extends Control

onready var textlabel = get_node("Control/Panel/MarginContainer/Control/TextLabel")
onready var letter_timer = $LetterTimer;
onready var delay_timer = $DelayTimer;
onready var npc = $Control/NPC
onready var transition = get_node("Control/NPC/AnimationPlayer")

var expressions = {
	VNGlobal.Characters.BOY : {
		VNGlobal.Expressions.DEFAULT :  preload("Characters/BoyeNeutral.png"),
		VNGlobal.Expressions.HAPPY : preload("Characters/BoyeSmile.png"),
		VNGlobal.Expressions.SAD : preload("Characters/BoyeFrown.png")
	},
	VNGlobal.Characters.GIRL : {
		VNGlobal.Expressions.DEFAULT :  preload("Characters/verylegit.png")
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
	npc.texture = null
 

func play_page(input:Dictionary): # parsed form JSON
	#take data from JSON
	#make content page
	var sentences = [];
	for sentence in input["content"] :
		sentences.push_back(Sentence.new(sentence["content"], sentence["speed"], sentence["sound"]));
		
	var page = ContentPage.new(
		input["id"],
		input["next_id"], 
		sentences, 
		input["character"], 
		input["expression"], 
		input["transition"], 
		input["background"], 
		input["music"]
		)
	#display page through VNEditor
	print(page.character)
	yield(display_page(page), "completed")

func display_page(page : Page):
	npc.hide()
	textlabel.text = ""
	print("PATH" + self.get_path())
#	print("CHARACTER: " + str(page.character));
	#print("RESULT" + str(expressions[page.character][page.expression]));
	
	if page.character == VNGlobal.Characters.NONE: 
		npc.texture = null;
	else:
		if expressions[page.character][page.expression] == null:
			npc.texture = expressions["BOY"]["DEFAULT"]
		else:
			npc.texture = expressions[page.character][page.expression]
	
	
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
	# else incolves being able to reference previous pages
	
	for sentence in page.content:
		yield(write_sentence(sentence), "completed"); #tells program to wait on everything until this function finishes/this happens
		
func write_sentence (sentence):
	for c in sentence.content:
		textlabel.text += str(c)
		letter_timer.wait_time = CHAR_WAIT*sentence.speed;
		letter_timer.start();
		yield(letter_timer, "timeout");
		
	delay_timer.wait_time = sentence.delay*sentence.speed + 0.0001; #so it shuts up
	delay_timer.start();
	yield(delay_timer, "timeout");

func load_data(file_path):
	#retrieves the json file
	var file = File.new()
	file.open(file_path, 3)
	#converts the json file to a text file
	var text_json = file.get_as_text()
#	print(text_json)
	#parses tect file to dictionary
	data_json = JSON.parse(text_json)
	#checks to make sure it parsed correctly
	if data_json.error == OK:
		print("All is good")
	else:
		print("something is wrong")
		print(typeof(data_json.result))
		print(data_json.get_error_line())
	print("checkpoint 1")
	print(typeof(data_json.result))
	print(data_json)
	file.close()
