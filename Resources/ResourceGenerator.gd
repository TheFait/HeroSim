extends Node2D

var backstories:Dictionary = {}
var first_names:Array = []
var last_names:Array = []
var players:Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _on_backstory_pressed():
	pass
	#for story_index in backstories:
		#var story_data = backstories[story_index]
		#var story:HeroBackstory = HeroBackstory.new()
		#story.first_name = story_data[0]
		#story.last_name = story_data[1]
		#if (story_data.size() > 2):
			#if story_data[2] == "":
				#story.home_town = story_data[2]
			#else:
				#story.home_town = "Unset"
		#else:
			#story.home_town = "Unset"
		#
		#var file_name = str("res://Resources/HeroBackstory/",story.first_name,"_",story.last_name,".tres").to_lower()
		#print("Saving ", file_name)
		#ResourceSaver.save(story,file_name)
	
	
func _on_first_name_pressed():
	var file = FileAccess.open("res://Resources/CSVs/first_names.csv", FileAccess.READ)
	
	while !file.eof_reached():
		var data_set = Array(file.get_csv_line())
		print(data_set)
		for first_name in data_set:
			first_names.push_back(first_name)
			print("Pushing firstname: ", first_name)	 
	file.close()
	print("File read in:")
	print(first_names)

func _on_last_name_pressed():
	var file = FileAccess.open("res://Resources/CSVs/first_names.csv", FileAccess.READ)
	
	while !file.eof_reached():
		var data_set = Array(file.get_csv_line())
		print(data_set)
		for last_name in data_set:
			last_names.push_back(last_name)
			print("Pushing lastname: ", last_name)	 
	file.close()
	print("File read in:")
	print(last_names)


func _on_heroes_pressed():
	for i in 32:
		var hero_name:String
		while(true):
			hero_name = str(first_names.pick_random(), " ", last_names.pick_random())
			print("Tried to create: ", hero_name)
			if !players.has(hero_name):
				print("Successfully added name: ", hero_name)
				break
			print("Failed to add name: ", hero_name)
		players.push_back(hero_name)
		
