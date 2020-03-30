extends Node

const COMMENT = "//"
const QUESTION_ANS = "##"
const GAME_ACTION = "@@"
const filePath = "da1V2.txt"
const CHAR_LIMIT = 100
const SENTENCE_SPLITTERS = "[,\\.!?…\\-\\n]\\s"

var pages:Array = [] #Every page held in a JSON format
var question_mode:bool = false;
var answers:Array = [];
var current_question_index:int= -1;
var question_num:int = 0; #counts 1, 2, ... not 0, 1, 2...
var answer_num:int = 0; #counts 1, 2, ... not 0, 1, 2...
var line_number = 0;
var LABEL_ids = {}

var errors= []; #This is evaluated in the end

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
	if not LABEL_ids.keys().has(id):
		LABEL_ids[id] = -(LABEL_ids.size() +1)
	return LABEL_ids[id];
	
func check_args(args, num, func_name):
	if args.size() != num:
		return error_message("Logic", line_number, func_name + " expected " 
			+ String(num) + " argument(s), got " + String(args.size()));
	return null;

func parse_action(line:String):
	var action : String = line.substr(2);
	var parameters : Array = []
	
#	Find parameters, if any
	if (action.find("(") > -1):
		if (action.find(")") > -1):
			parameters = action.substr(action.find("(") + 1, action.find(")")).split(",");
			action = action.substr(0, action.find("("))
			for i in range(parameters.size()):
				parameters[i] = parameters[i].strip_edges();
		else:
			error_message("Syntax", line_number, "Unmatched parentheses")
	
#	Match the commmand up to what we want
	action = action.strip_edges().to_upper();
	match(action):
		"GOTO":
			var error = check_args(parameters, 1, "GOTO")
			if error: return error;
			pages.push_back(new_GOTO(parameters[0]));
		"LABEL":
			var error = check_args(parameters, 1, "LABEL")
			if error: return error;
			pages.push_back(new_LABEL(parameters[0]));
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
#	Get the name
	if line.find(":") < 0:
		return error_message("Syntax", line_number, "Dialogue line missing a colon");
	var name:String = line.substr(0, line.find(":")).strip_edges();
	line = line.substr(line.find(":") + 1).strip_edges()
	
#	Get the expression, if there is one
	var expression:String = ""
	if (name.find("[") > -1):
		if (name.find("]") > -1):
			expression = name.substr(name.find("(") + 1, name.find(")")).strip_edges();
		else:
			return error_message("Syntax", line_number, "Unmatched bracket")
	
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
			var result = fragment_searcher.search(line)
			
			var next_splitter_location = line.length() - 1;
			if result:
				next_splitter_location = result.get_start();
			
	#		Error if the sentence fragment is too big
			if next_splitter_location + 1 > CHAR_LIMIT:
				return error_message("Content", line_number, "Sentence fragment exceeds " 
					+ String(CHAR_LIMIT) + " character limit: " + line);
			
			var fragment = line.substr(0, next_splitter_location + 1)
			line = line.substr(next_splitter_location + 1).strip_edges();
			
			page_length+= fragment.length() + 1; # So we account for the added space
			if fragment.ends_with("\n"):
				page_length-=1 #We have no need for a hypothetical space if it's a newline
				
			sentences.push_back(Sentence.new(fragment).serialize());
		
#		TODO: save more character info here
		to_save.push_back(ContentPage.new(0, 0, sentences).serialize())
	
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
	 
