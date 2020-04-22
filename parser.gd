extends Node

const COMMENT = "//"
const QUESTION_ANS = "##"
const GAME_ACTION = "@@"
const filePath = "da1V2.txt"
const CHAR_LIMIT = 105
const SENTENCE_SPLITTERS = "[,\\.!?…\\-\\n] "
const SENTENCE_ENDERS = [".", "!", "?", "…", "-"]

var pages:Array = [] #Every page held in a JSON format
var question_mode:bool = false;
var answers:Array = [];
var current_question_index:int= -1;
var question_num:int = 0; #counts 1, 2, ... not 0, 1, 2...
var answer_num:int = 0; #counts 1, 2, ... not 0, 1, 2...
var line_number = 0;
var LABEL_ids = {}
var last_character_image = "";


var errors= []; #This is evaluated in the end

func count_string_instances(line:String, target:String):
	var searcher = RegEx.new();
	searcher.compile(target);
	return searcher.search_all(line).size()
	
	
func string_to_bool(param:String)->bool:
	param = param.to_upper().strip_edges();
	if param == "TRUE":
		return true;
	return false;
#
#func find_all(line:String, target:String)->Array:
#	var instances = [];
#	var next_index = line.find(target);
#	while (next_index != 1):
#		instances.push_back(next_index);
#		next_index = line.find(target, next_index+1);
#	return instances

# Assumes all left and right instances are properly matched
func contained_within(line:String, index:int, left:String, right:String)->bool:
	var char_stack = [];
	for i in range(line.length()):
		if i == index:
			if char_stack.size() > 0:
				return true
			else:
				return false;
				
		var letter = line[i];
		if letter==left:
			char_stack.push_back(letter);
		if letter==right:
			char_stack.pop_back();
			
#	default return
	return false;

func is_properly_matched(line:String, left:String, right:String):
	var char_stack = [];
	for letter in line:
		if letter==left:
			char_stack.push_back(letter);
		if letter==right:
			char_stack.pop_back();
	if char_stack.size() > 0: return false;
	return true;

func find_and_replace(list:Array, key:String, match_value, value):
	for item in list:
		if item.has(key) and String(item[key]) == String(match_value):
			item[key] = value
		for v in item.values():
			if v is Array:
				find_and_replace(v, key, match_value, value)

func error_message(type, line, reason):
	return {"line": line, "message": type + " error: " + reason}
	
func new_GOTO(next_id: String):
	var temp = Page.new().serialize()
	temp.next_id = LABEL_to_int(next_id);
	return temp;
	
func new_LABEL(id: String):
	var temp = Page.new().serialize()
	temp.id = LABEL_to_int(id);
	return temp;
	
func LABEL_to_int(id: String) -> int:
	id = id.to_upper();
	if not LABEL_ids.keys().has(id):
		LABEL_ids[id] = -(LABEL_ids.size() +1)
	return LABEL_ids[id];
	
func check_args(args, num, func_name):
	if args.size() != num:
		return error_message("Logic", line_number, func_name + " expected " 
			+ String(num) + " argument(s), got " + String(args.size()));
	return null;
	
func check_value(value, list, func_name):
	var valid = false;
	for i in list:
		if i == value:
			valid =true;
			break;
	if not valid:
		return error_message("Logic", line_number, "Invalid value " + value);
	return null;
		
		
func parse_action(line:String):
	var action : String = line.substr(2);
	var parameters : Array = []
	
#	Find parameters, if any
	if (action.find("(") > -1):
		if (action.find(")") > -1):
			parameters = action.substr(action.find("(") + 1, action.find(")") - action.find("(") - 1).split(",");
			action = action.substr(0, action.find("("))
			for i in range(parameters.size()):
				parameters[i] = parameters[i].strip_edges();
		else:
			error_message("Syntax", line_number, "Unmatched parentheses")
	
#	Match the commmand up to what we want
	action = action.strip_edges().to_upper();
	match(action):
		"SHOW IMAGE":
			var error = check_args(parameters, 1, "SHOW IMAGE")
			if error: return error;
			
			var image = parameters[0].to_upper();
			error = check_value(image, VNGlobal.Images.values(), "SHOW IMAGE")
			if error: return error;
						
			pages.push_back(ImageTogglePage.new(0, 0, image, true).serialize());
		"HIDE IMAGE":
			var error = check_args(parameters, 0, "HIDE IMAGE")
			if error: return error;
			pages.push_back(ImageTogglePage.new(0, 0, VNGlobal.Images.LETTER, false).serialize());		
		"GOTO":
			var error = check_args(parameters, 1, "GOTO")
			if error: return error;
			pages.push_back(new_GOTO(parameters[0]));
		"LABEL":
			var error = check_args(parameters, 1, "LABEL")
			if error: return error;
			pages.push_back(new_LABEL(parameters[0]));
		"BRANCH ON FLAG":
			var error = check_args(parameters, 2, "BRANCH ON FLAG")
			if error: return error;
			
			var page:FlagBranchPage = FlagBranchPage.new();
			page.target_id = LABEL_to_int(parameters[0]);
			page.flag = parameters[1]
			pages.push_back(page.serialize());
		"BRANCH ON RELATIONSHIP":
			var error = check_args(parameters, 4, "BRANCH ON RELATIONSHIP")
			if error: return error;
			
			var page:RelationshipBranchPage = RelationshipBranchPage.new();
			var target_id = LABEL_to_int(parameters[0]);
			var character = parameters[1].to_upper();
			var check_type = parameters[2].to_upper();
			var value = int(parameters[3]);
			
			error = check_value(character, VNGlobal.Characters.values(), "BRANCH ON RELATIONSHIP")
			if error: return error;
			error = check_value(check_type, VNGlobal.CheckTypeSymbols.values(), "BRANCH ON RELATIONSHIP")
			if error: return error;
			
			page.target_id = target_id;
			page.character = character;
			page.check_type = VNGlobal.ReverseCheckTypeSymbols[check_type];
			page.value = value;
			
			pages.push_back(page.serialize());
		"SET FLAG":
			var error1 = check_args(parameters, 1, "SET FLAG")
			var error2 = check_args(parameters, 2, "SET FLAG")
			if error1: if error2: return error2;
			
			var page:SetFlagPage = SetFlagPage.new();
			page.flag = parameters[0];
			if not error2: page.value = string_to_bool(parameters[1]);
			pages.push_back(page.serialize());
		"INCREMENT RELATIONSHIP":
			var error1 = check_args(parameters, 1, "INCREMENT RELATIONSHIP")
			var error2 = check_args(parameters, 2, "INCREMENT RELATIONSHIP")
			if error1: if error2: return error2;
			
			var page:IncrementRelationshipPage = IncrementRelationshipPage.new();
			var character = parameters[0].to_upper()
			var value = page.value;
			
			if not error2:
				value = int(parameters[1])
			
			var error = check_value(character, VNGlobal.Characters.values(), "INCREMENT RELATIONSHIP")
			if error: return error;
			
			page.character = character;
			page.value = value;
			pages.push_back(page.serialize());
		"TRANSITION":
			var error3 = check_args(parameters, 3, "TRANSITION")
			var error4 = check_args(parameters, 4, "TRANSITION")
			if error3: if error4: return error4;
			
			var page:TransitionPage = TransitionPage.new()
			var next_background:String = parameters[0].to_upper()
			var next_music:String = parameters[1].to_upper()
			var transition_type:String = parameters[2].to_upper()
			var next_name:String = page.next_name
			
			if not error4:
				next_name = parameters[3];
			
			var error = check_value(next_background, VNGlobal.Backgrounds.values(), "TRANSITION")
			if error: return error;
			error = check_value(next_music, VNGlobal.Music.values(), "TRANSITION")
			if error: return error;
			error = check_value(transition_type, VNGlobal.SceneTransitions.values(), "TRANSITION")
			if error: return error;
			
			page.next_background = next_background;
			page.next_music = next_music;
			page.transition_type = transition_type;
			page.next_name = next_name;
			
			pages.push_back(page.serialize());
		"SET MUSIC":
			var error = check_args(parameters, 1, "SET MUSIC")
			if error: return error;
			
			var page:TransitionPage = TransitionPage.new()
			var next_background:String = VNGlobal.Backgrounds.SAME;
			var next_music:String = parameters[0].to_upper()
			var transition_type:String = VNGlobal.SceneTransitions.NONE;
			var next_name:String = page.next_name
			
			
			error = check_value(next_music, VNGlobal.Music.values(), "SET MUSIC")
			if error: return error;

			page.next_background = next_background;
			page.next_music = next_music;
			page.transition_type = transition_type;
			page.next_name = next_name;
			
			pages.push_back(page.serialize());
		"SET BACKGROUND":
			var error = check_args(parameters, 1, "SET BACKGROUND")
			if error: return error;
			
			var page:TransitionPage = TransitionPage.new()
			var next_background:String = parameters[0].to_upper()
			var next_music:String = VNGlobal.Music.SAME;
			var transition_type:String = VNGlobal.SceneTransitions.NONE;
			var next_name:String = page.next_name
			
			
			error = check_value(next_background, VNGlobal.Backgrounds.values(), "SET BACKGROUND")
			if error: return error;

			page.next_background = next_background;
			page.next_music = next_music;
			page.transition_type = transition_type;
			page.next_name = next_name;
			
			pages.push_back(page.serialize());
		"FADE IN MUSIC":
			var error = check_args(parameters, 1, "FADE IN MUSIC")
			if error: return error;
			
			var page:TransitionPage = TransitionPage.new()
			var next_background:String = VNGlobal.Backgrounds.SAME;
			var next_music:String = parameters[0].to_upper()
			var transition_type:String = VNGlobal.SceneTransitions.MUSICFADE;
			var next_name:String = page.next_name
			
			
			error = check_value(next_music, VNGlobal.Music.values(), "FADE IN MUSIC")
			if error: return error;

			page.next_background = next_background;
			page.next_music = next_music;
			page.transition_type = transition_type;
			page.next_name = next_name;
			
			pages.push_back(page.serialize());
		"MINING START":
			var error = check_args(parameters, 0, "BEGIN MINING")
			if error: return error;
			pages.push_back(GameStartPage.new().serialize());
		"MINING END":
			var error = check_args(parameters, 0, "GOTO")
			if error: return error;
			pages.push_back(GameEndPage.new().serialize());
		"END CHOICES":
			var error = check_args(parameters, 0, "END CHOICES")
			if error: return error;
			
			pages.push_back(new_LABEL("Question" + String(question_num) + "END"));
			pages[current_question_index].answers = answers;
			question_mode = false;
		_:
			return error_message("Token", line_number, "Unrecognized Action: " + action);
			
	return null
			
func parse_content(line:String):
	var is_thought = false;
	var speaker_name = "SIMON"
	var character_image = VNGlobal.Characters.NONE;
	var character_transition = VNGlobal.CharacterTransitions.DEFAULT;
	var character_expression = VNGlobal.Expressions.NORMAL;
	var current_speed = VNGlobal.SentenceSpeeds.DEFAULT;
	var current_delay = VNGlobal.DelayLengths.DEFAULT;
	var current_effect = VNGlobal.Effects.NONE;
	
#	Syntax check
	if not is_properly_matched(line, "[", "]"):
		return error_message("Syntax", line_number, "Unmatched brackets")
	
	var parameters = []
#	Get the name
	if line.find(":") < 0:
		is_thought = true;
	else:
		var name_line = line.substr(0, line.find(":")).strip_edges();
		line = line.substr(line.find(":") + 1).strip_edges()
	
	#	Find character parameters, if any
		if (name_line.find("[") > -1):
			parameters = name_line.substr(name_line.find("[") + 1, name_line.find("]") - name_line.find("[") - 1).split(",");
			name_line = name_line.substr(0, name_line.find("[")).strip_edges();
			for i in range(parameters.size()):
				parameters[i] = parameters[i].strip_edges();
#				TODO: FIX ERROR THAT WOULD RESULT IF "INTERNAL" WAS USED, CAUSING A SELF-SPEAKER IMAGE
		
		speaker_name = name_line.strip_edges();
				
#		If possible, match up the speaker to a character image 
#		(since it's more likely that there will be a correlation between speaker and image)
		for character in VNGlobal.Characters.values():
			if character == speaker_name.to_upper():
				character_image = character;

	speaker_name = speaker_name.capitalize();

#	Since simon doesn't appear on the screen
	if speaker_name.to_upper() == "SIMON":
		character_image = last_character_image
	
#	Handle the parameters
	for parameter in parameters:
		parameter = parameter.to_upper().strip_edges()
		var sub_parameters = parameter.split(" ");
		for i in range(sub_parameters.size()):
			sub_parameters[i] = sub_parameters[i].to_upper().strip_edges();
		match(sub_parameters[0]):
			"NORMAL":
				character_expression = VNGlobal.Expressions.NORMAL;
			"SAD":
				character_expression = VNGlobal.Expressions.SAD
			"SHOCKED":
				character_expression = VNGlobal.Expressions.SHOCKED
			"HAPPY":
				character_expression = VNGlobal.Expressions.HAPPY
			"ANGRY":
				character_expression = VNGlobal.Expressions.ANGRY
			"EMBARRASSED":
				character_expression = VNGlobal.Expressions.EMBARRASSED
			"TO":
				var target_character = sub_parameters[1]
				var char_found = false
				for character in VNGlobal.Characters.values():
					if character == target_character:
						character_image = character;
						char_found = true;
						break
				if not char_found:
						return error_message("Logic", line_number, "Character " + target_character + " does not exist!")
			"ALONE":
				character_image = VNGlobal.Characters.NONE
			"INTERNAL":
				is_thought = true;
			_:
				return error_message("Content", line_number, "Invalid Character Parameter " + parameter)
		
#	TODO: RESET THIS WHEN A TRANSITION PAGE COMES UP
	last_character_image = character_image
	
#	Get each sentence and make a page
#	Error if it's too long
#	Keep going until the line has been eaten
	var to_save = [] #We buffer the good pages in case there's a line error
	while (line != ""):
		
		var page_length = 0;
		var sentences = [];
					
#		The -1 accounts for the hypothetical space at the end
		while page_length - 1 < CHAR_LIMIT and line != "":
			
#			Find location to split line
			var fragment_searcher = RegEx.new();
			fragment_searcher.compile(SENTENCE_SPLITTERS);
			var result = fragment_searcher.search_all(line)
			
			var next_splitter_location = line.length() - 1;
			if result.size() > 0:
				var i = 0;
				
#				We want to make sure the splitter location isn't a false lead
				while (i <result.size()):
					var result_fragment = line.substr(0, result[i].get_start() + 1);
					var last_word = result_fragment.substr(result_fragment.find_last(" ") +1);
					
					last_word = last_word.to_upper();#					
					
#					Ignore all Abreviations and common titles
					if (count_string_instances(last_word, "\\.") == count_string_instances(last_word, "[a-zA-Z]")
						or last_word == "MRS." or last_word == "MR."
						or last_word == "DR." or last_word == "JR." 
						or last_word == "SR."):
						i+=1
						continue
						
#					Ignore splitters that are inside of a bracket
					if (line.find("[") > -1):
						if contained_within(line, result[i].get_start(), "[", "]"):
							i+=1
							continue;
						
#					At this point, we give up
					next_splitter_location = result[i].get_start();
					break;
			
			var fragment:String
			var sentence_parameters = [];
			
#			Remove parameters in the bracket
			if (line.find("[") > -1 and line.find("[") <  next_splitter_location):
				var parameter_fragment = line.substr(line.find("[") + 1, line.find("]")  - line.find("[") - 1);
				sentence_parameters = parameter_fragment.split(",");
				fragment = line.substr(line.find("]") + 1, next_splitter_location + 1 - (line.find("]") + 1)).strip_edges(true, false); #don't remove \n!
			else:
				fragment = line.substr(0, next_splitter_location + 1)
			
	#		Error if the sentence fragment is too big
			if fragment.length() + 1 > CHAR_LIMIT:
				return error_message("Content", line_number, "Sentence fragment exceeds " 
					+ String(CHAR_LIMIT) + " character limit at " + String(fragment.length() + 1) + " characters");
			
			line = line.substr(next_splitter_location + 1).strip_edges();
			
#			Parse the parameters
			for parameter in sentence_parameters:
				parameter = parameter.to_upper().strip_edges()
				var sub_parameters = parameter.split("=");
				for i in range(sub_parameters.size()):
					sub_parameters[i] = sub_parameters[i].to_upper().strip_edges();
				if sub_parameters.size() != 2:
					return error_message("Content", line_number, "Sentence Parameters must be two words separated by an equal sign!");
				match(sub_parameters[0]):
					"SPEED":
						var is_recognized = false;
						for value in VNGlobal.SentenceSpeeds.values():
							if value == sub_parameters[1]:
								current_speed = value
								is_recognized = true;
								break
						if not is_recognized:
							return error_message("Content", line_number, "Unrecognized Speed " + sub_parameters[1])
					"DELAY":
						var is_recognized = false;
						for value in VNGlobal.DelayLengths.values():
							if value == sub_parameters[1]:
								current_delay = value
								is_recognized = true;
								break
						if not is_recognized:
							return error_message("Content", line_number, "Unrecognized Delay " + sub_parameters[1])
					"EFFECT":
						var is_recognized = false;
						for value in VNGlobal.Effects.values():
							if value == sub_parameters[1]:
								current_effect = value
								is_recognized = true;
								break
						if not is_recognized:
							return error_message("Content", line_number, "Unrecognized Effect " + sub_parameters[1])
					_:
						return error_message("Content", line_number, "Invalid Sentence Parameter " + parameter)
						
			
			page_length+= fragment.length() + 1; # So we account for the added space
			if fragment.ends_with("\n"):
				page_length-=1 #We have no need for a hypothetical space if it's a newline
				
			sentences.push_back(Sentence.new(fragment, current_speed, current_delay, current_effect).serialize());
		
#		Make sure that it ends with a proper punctuation mark
#		We need to make sure that there is still content remaining
		if sentences.size() > 0 and line != "":
			var i = sentences.size() - 1;
			while (i > -1):
				var checked_sentence:String = sentences[i].content;
				var does_sentence_end = false;
				for punctuation_mark in SENTENCE_ENDERS:
					if checked_sentence.ends_with(punctuation_mark):
						does_sentence_end = true;
						break;
				
				if does_sentence_end:
					break
				
#				Add it back to the line
				line = ("[SPEED=" +sentences[i].speed + ", "
					+ "DELAY=" + sentences[i].delay + ", "
					+ "EFFECT=" + sentences[i].effect + "] "
					+ checked_sentence + " " + line);
				
#				Trim off nonending sentence
				sentences.remove(i);
				i = i-1;
				
			if sentences.size() == 0:
				return error_message("Content", line_number, "Run on sentence")
		
		to_save.push_back(ContentPage.new(0, 0, sentences, character_image, character_expression, character_transition, speaker_name, is_thought).serialize())
	
#	Save the good pages
	for page in to_save:
		pages.push_back(page)
		
	return null
	
func parse_answer(line):
	if not question_mode:
#			Reset buffers and begin a new question
		question_mode = true
		answers = []
		question_num+=1
		answer_num = 0
		pages.push_back(QuestionPage.new().serialize());
		current_question_index = pages.size() - 1;
	else:
#			Add a goto to the end of questions
		pages.push_back(new_GOTO("Question" + String(question_num) + "END"));
	
#		Add the jump point
	answer_num+=1
	var answer_id = "Question" + String(question_num) + "Answer" + String(answer_num);
	pages.push_back(new_LABEL(answer_id));
	answers.push_back({
		"content": line.substr(2).strip_edges(), 
		"next_id" : LABEL_to_int(answer_id)
		});
	
	return null

func parse(text):
#	var info = load_text_file(filePath)
	var info = prepare_text(text);
	pages = [] #Every page held in a JSON format
	question_mode = false;
	answers = [];
	current_question_index= -1;
	question_num = 0; #counts 1, 2, ... not 0, 1, 2...
	answer_num = 0; #counts 1, 2, ... not 0, 1, 2...
	line_number = 0;
	errors= []
	LABEL_ids = {}
	last_character_image = VNGlobal.Characters.NONE;

	for ln in range(info.size()):
		var line:String = info[ln].c_unescape();
		line_number = ln;
		var error = null;
		
#		Stop doing anything if its an empty line
		if (line == ""):
			continue
#		Stop doing anything if it's a comment line
		elif (line.substr(0, 2) == COMMENT):
			continue
			
#		If it's an action command, parse the command
		elif (line.substr(0, 2) == GAME_ACTION):
			error = parse_action(line)
			
#		If it's an answer choice, handle the question segments differently
		elif (line.substr(0, 2) == QUESTION_ANS):
			error = parse_answer(line)

#		Otherwise, treat it as a regular Content page
		else:
			error = parse_content(line);
			
		if (error):
			errors.push_back(error);
			
#	Trim all GOTOs and LABELs
	var to_delete:Array = []
	for i in range(pages.size()):
		var page = pages[i];
		if page.type == "Page":
	#		If it is a GOTO
			if page.id >= 0 and page.next_id < 0 and i > 0:
				var previous_page = pages[i-1];
				if not previous_page.next_id < 0:
					previous_page.next_id = page.next_id;
				to_delete.push_back(i)
#			If it is a LABEL
			elif page.id < 0 and page.next_id >= 0 and i < pages.size() - 1:
				var next_page = pages[i+1];
				if not next_page.id < 0:
					next_page.id  = page.id;
				else:
					find_and_replace(pages, "next_id", page.id, next_page.id)
				to_delete.push_back(i)
#			If it is a redundant link
			elif page.id < 0 and page.next_id < 0:
				find_and_replace(pages, "next_id", page.id, page.next_id)
				to_delete.push_back(i)
	
#	Loop backwards to apply deletes correctly
	for i in range(to_delete.size()-1, -1, -1):
		pages.remove(to_delete[i]);
	
#	Apply ids to all pages
	var id_map = {}
	for i in range(pages.size()):
		if pages[i].id < 0:
			id_map[pages[i].id] = i;
		pages[i].id = i;
	
#	Link sequentially
	for i in range(pages.size()):
		if not pages[i].next_id < 0:
			pages[i].next_id = i+1;
	
#	Resolve all symbolic links
	for key in id_map.keys():
		find_and_replace(pages, "next_id", key, id_map[key])
	for key in id_map.keys():
		find_and_replace(pages, "target_id", key, id_map[key])

func load_text_file(path):
	var f = File.new()
	var err = f.open(path, File.READ)
	if err != OK:
		printerr("Could not open file, error code ", err)
		return ""
	var text = f.get_as_text()
	f.close()
	
	return prepare_text(text);
	
func prepare_text(text):
	text = text.replace("’", "'");
	text = text.replace('“', '"');
	text = text.replace('”', '"');
	text = text.split("\n")
	var newText = [];
	
	for item in text:
		newText.push_back(item.strip_edges());
	
	return newText
	
# Writes save_data to a json file, and creates a backup too
func save_json():
	var dir = Directory.new()
	var file = File.new()
	
	var new_file = File.new()
	new_file.open("res://parser_data.json", 2)
	new_file.store_line(to_json(pages))
	new_file.close()
	 
