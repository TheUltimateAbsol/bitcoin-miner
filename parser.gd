extends Control

var filePath = "da1V2.txt"


func _ready():
	var info = load_text_file(filePath)
#	print(info)
#	for line in info:
#		var item = line.find("#")
#		# comments
#		if (line.substr(0, 2) == "//"):
#			continue
#		#question answer choice
#		elif (item != -1 && line.substr(item, 2) == "##"):
#			print(line)
#		elif(line.substr(0,2) == "@@"):
#			continue
#		else:
##			print(line)
#			continue;

	var COMMENT = "//"
	var QUESTION_ANS = "##"
	var GAME_ACTION = "@@"
	var answerSets = []
	var content = []

	for i in range(info.size()):
		var item = info[i].find("#")
		if (info[i].substr(0, 2) == COMMENT):
			continue
		elif (item != -1 && info[i].substr(item, 2) == QUESTION_ANS):
#			print(line)
			var answers = []
			var x = 0
			var isQuestion = true
			while (isQuestion):
				if(info[i+x].substr(item, 2) == QUESTION_ANS):
					
					answers.push_back(info[i+x])
					x += 1
				elif(info[i+x].substr(item, 2) == GAME_ACTION):
					isQuestion = false;
				elif(info[i+x].substr(item, 2) == COMMENT):
					content.push_back(info[i+x])
				else:
					pass
			answerSets.push_back(answers);
			i += x
			continue
		else:
#			print(line)
			continue;

	print (answerSets)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass\

func load_text_file(path):
	var f = File.new()
	var err = f.open(path, File.READ)
	if err != OK:
		printerr("Could not open file, error code ", err)
		return ""
	var text = f.get_as_text()
	f.close()
	
	text = text.split("\n")
	var newText = [];
	
	for item in text:
		newText.push_back(item.strip_edges());
#		print(item)
	
	return newText
	