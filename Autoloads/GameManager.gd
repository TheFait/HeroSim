extends Node

const LEAGUE_PLAYERS = 32
const LEAGUE_TEAMS = 8
const POSSIBLE_COLORS = 18
var all_heroes:Array[Hero] = []
var full_league:Array[Team] = []
var heads = []
var bodies = []
var stat_blocks:Array = []
var time_modifier:int = 1
var skip_animations:bool = false
var hero_names:Array[String]
var team_names:Array[String]

func generate_league() -> Array[Team]:
	full_league.clear()
	
	var team_colors = []
	#Create all possible colors
	var float_increment = 1.0 / POSSIBLE_COLORS
	for i in POSSIBLE_COLORS:
		team_colors.push_front(i*float_increment)
	#shuffle random colors
	team_colors.shuffle()
	
	# var to track which player we're on
	var player_number:int = 0
	team_names.shuffle()
	
	for team_number in LEAGUE_TEAMS:
		var team = Team.new()
		team.team_name = str(team_names[team_number])
		var player_array:Array[Hero] = []
		team.heroes = player_array
		team.wins = 0
		
			
		team.team_color = Color.from_hsv(team_colors[team_number], 1, 1)
		
		for i in int(LEAGUE_PLAYERS / LEAGUE_TEAMS):
			
			var hero:Hero = preload("res://Gameplay/Heroes/hero.tscn").instantiate()
			hero.stat_block = stat_blocks.pick_random()
			#TODO Make this unique when you have enough backstories
			#hero.backstory = available_backstories.pop_back()
			var backstory = HeroBackstory.new()
			var full_name:Array = hero_names[player_number].split(" ")			
			backstory.first_name = full_name[0]
			backstory.last_name = full_name[1]
			hero.backstory = backstory
			hero.team = (i % LEAGUE_TEAMS) + 1
			hero.setup()
			#print("generate_league: ", hero.get_hero_name(), " the ", hero.stat_block.class_title, ", speed ", hero.stat_block.speed)
			hero.load_graphics(bodies.pick_random(), heads.pick_random())
			team.heroes.push_back(hero)
			all_heroes.push_back(hero)
			player_number += 1
		
		
		full_league.push_back(team)
		
	print_league()
	
	return full_league

func recreate_hero(p_stats, p_story, p_team, p_body, p_head):
	var hero:Hero = preload("res://Gameplay/Heroes/hero.tscn").instantiate()
	hero.stat_block = p_stats
	hero.backstory = p_story
	hero.team = p_team
	hero.setup()
	hero.load_graphics(p_body, p_head)
	return hero
	
func get_full_league() -> Array[Team]:
	if (!full_league):
		return generate_league()
	return full_league

func randomize_hero_visual(hero:Hero):
	hero.load_graphics(bodies.pick_random(), heads.pick_random())
	
func generate_monster() -> Hero:
	var hero:Hero = preload("res://Gameplay/Heroes/hero.tscn").instantiate()
	hero.stat_block = stat_blocks.pick_random()
	#TODO Make this unique when you have enough backstories
	#hero.backstory = available_backstories.pop_back()
	var backstory = HeroBackstory.new()
	var full_name:Array = hero_names.pick_random().split(" ")			
	backstory.first_name = full_name[0]
	backstory.last_name = full_name[1]
	hero.backstory = backstory
	hero.team = -1
	hero.setup()
	return hero

func _ready():
	# Load all heads
	var heads_path = "res://Assets/Images/Hero/sheets/head/"
	var heads_folder = DirAccess.open(heads_path)
	if heads_folder:
		for file in heads_folder.get_files():
			print("loading file: ", file)
			if (file.get_extension() == "import"):
				file = file.replace('.import', '')
			if (file.get_extension() == "png"):
				var head = load(heads_path + "/" + file)
				heads.push_back(head)
	
	# Load all Bodies
	var bodies_path = "res://Assets/Images/Hero/sheets/body"
	var bodies_folder = DirAccess.open(bodies_path)
	if bodies_folder:
		for file in bodies_folder.get_files():
			print("loading file: ", file)
			if (file.get_extension() == "import"):
				file = file.replace('.import', '')
			if (file.get_extension() == "png"):
				var body = load(bodies_path + "/" + file)
				bodies.push_back(body)
	
	
	# Load all stat blocks
	var stat_block_path = "res://Resources/HeroStatBlocks/"
	var stat_block_folder = DirAccess.open(stat_block_path)
	if stat_block_folder:
		for file in stat_block_folder.get_files():
			if (file.get_extension() == "remap"):
				file = file.replace('.remap', '')
			var stat_block = load(stat_block_path + "/" + file)
			stat_blocks.push_back(stat_block)
	
	# Load all abilities
	#var abilities = []
	#var ability_path = "res://Resources/Abilities/"
	#var ability_folder = DirAccess.open(ability_path)
	#if ability_folder:
		#for file in ability_folder.get_files():
			#var ability = load(ability_path + "/" + file)
			#abilities.push_back(ability)
			
	
	# Load all first names
	var first_names:Array = []
	var first_name_file = FileAccess.open("res://Resources/CSVs/first_names.csv", FileAccess.READ)
	
	while !first_name_file.eof_reached():
		var data_set = Array(first_name_file.get_csv_line())
		print(data_set)
		for first_name in data_set:
			first_names.push_back(first_name)
			print("Pushing firstname: ", first_name)	 
	first_name_file.close()
	
	# Load all last names
	var last_names:Array = []
	var last_name_file = FileAccess.open("res://Resources/CSVs/last_names.csv", FileAccess.READ)
	
	while !last_name_file.eof_reached():
		var data_set = Array(last_name_file.get_csv_line())
		print(data_set)
		for last_name in data_set:
			last_names.push_back(last_name)
			print("Pushing firstname: ", last_name)	 
	last_name_file.close()
	
	# Generate player names with no duplicates
	for i in LEAGUE_PLAYERS:
		var hero_name:String
		# TODO: Add a check here to stop the case where we are generating more players than unique combinations of names and loop infinitely
		# keep generating names while they aren't unique
		while(true):
			hero_name = str(first_names.pick_random(), " ", last_names.pick_random())
			print("Tried to create: ", hero_name)
			if !hero_names.has(hero_name):
				print("Successfully added name: ", hero_name)
				break
			print("Failed to add name: ", hero_name)
		hero_names.push_back(hero_name)
		
	# Generate Team Names
	var team_name_file = FileAccess.open("res://Resources/CSVs/team_names.csv", FileAccess.READ)
	var team_adj:Array
	var team_noun1:Array
	var team_noun2:Array
	
	while !team_name_file.eof_reached():
		team_adj = Array(team_name_file.get_csv_line())
		print(team_adj)
		team_noun1 = Array(team_name_file.get_csv_line())
		print(team_noun1)
		team_noun2 = Array(team_name_file.get_csv_line())
		print(team_noun2)
	team_name_file.close()
	
	for j in LEAGUE_TEAMS:
		var team_name:String
		while(true):
			var name_pattern:int = randi_range(1,3)
			match name_pattern:
				1:
					team_name = str(team_adj.pick_random(), " ", team_noun1.pick_random(), " ", team_noun2.pick_random())
				2:
					team_name = str(team_adj.pick_random(), " ", team_noun1.pick_random())
				3:
					team_name = str(team_adj.pick_random(), " ", team_noun2.pick_random())
			Globals.print_with_timestamp(str("Trying to generate team name: ",team_name))
			if !team_names.has(team_name):
				team_names.push_back(team_name)
				Globals.print_with_timestamp(str("Successfully added name: ", team_name))
				break
			Globals.print_with_timestamp(str("Failed to generate: ", team_name, ". Duplicate found!"))
	
	print (team_names)

func shuffle_heroes() -> Array[Team]:
	# make array of all players
	# shuffle players
	all_heroes.shuffle()
	# set players back on teams
	for team_id in full_league.size():
		full_league[team_id].heroes = []
		for hero_id in all_heroes.size():
			if (hero_id % LEAGUE_TEAMS) == team_id:
				full_league[team_id].heroes.push_back(all_heroes[hero_id])
	return full_league

func print_league():
	for team_index in full_league.size():
		var created_team:Team = full_league[team_index]
		print("Team ", created_team.team_name, ":")
		for hero in created_team.heroes:
			print("--- ",hero.get_hero_name(), " the ", hero.stat_block.class_title, ", speed ", hero.stat_block.speed)
