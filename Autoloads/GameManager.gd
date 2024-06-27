extends Node

const LEAGUE_PLAYERS = 32
const LEAGUE_TEAMS = 8
const POSSIBLE_COLORS = 18
var all_heroes:Array[Hero] = []
var full_league:Array[Team] = []
var heads = []
var bodies = []
var stat_blocks:Array = []
var backstories = []
var time_modifier:int = 1
var skip_animations:bool = false

func generate_league() -> Array[Team]:
	var available_backstories = backstories.duplicate()
	available_backstories.shuffle()
	full_league.clear()
	
	var team_colors = []
	#Create all possible colors
	var float_increment = 1.0 / POSSIBLE_COLORS
	for i in POSSIBLE_COLORS:
		team_colors.push_front(i*float_increment)
	#shuffle random colors
	team_colors.shuffle()
	
	for team_number in LEAGUE_TEAMS:
		var team = Team.new()
		team.team_name = str(team_number, "'s Heroes")
		var player_array:Array[Hero] = []
		team.heroes = player_array
		team.wins = 0
		
			
		team.team_color = Color.from_hsv(team_colors[team_number], 1, 1)
		
		for i in int(LEAGUE_PLAYERS / LEAGUE_TEAMS):
			var hero:Hero = preload("res://Gameplay/Heroes/hero.tscn").instantiate()
			hero.stat_block = stat_blocks.pick_random()
			#TODO Make this unique when you have enough backstories
			#hero.backstory = available_backstories.pop_back()
			hero.backstory = backstories.pick_random()
			hero.team = (i % LEAGUE_TEAMS) + 1
			hero.setup()
			#print("generate_league: ", hero.get_hero_name(), " the ", hero.stat_block.class_title, ", speed ", hero.stat_block.speed)
			hero.load_graphics(bodies.pick_random(), heads.pick_random())
			team.heroes.push_back(hero)
			all_heroes.push_back(hero)
		
		
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
	hero.backstory = backstories.pick_random()
	hero.team = -1
	hero.setup()
	return hero

func _ready():
	# Load all heads
	var heads_path = "res://Assets/Images/Hero/sheets/head/"
	var heads_folder = DirAccess.open(heads_path)
	if heads_folder:
		for file in heads_folder.get_files():
			if (file.get_extension() == "png"):
				var head = load(heads_path + "/" + file)
				heads.push_back(head)
	
	# Load all Bodies
	var bodies_path = "res://Assets/Images/Hero/sheets/body"
	var bodies_folder = DirAccess.open(bodies_path)
	if bodies_folder:
		for file in bodies_folder.get_files():
			if (file.get_extension() == "png"):
				var body = load(bodies_path + "/" + file)
				bodies.push_back(body)
	
	
	# Load all stat blocks
	var stat_block_path = "res://Resources/HeroStatBlocks/"
	var stat_block_folder = DirAccess.open(stat_block_path)
	if stat_block_folder:
		for file in stat_block_folder.get_files():
			var stat_block = load(stat_block_path + "/" + file)
			stat_blocks.push_back(stat_block)
			
	
	# Load all backstories
	var backstory_path = "res://Resources/HeroBackstory/"
	var backstory_folder = DirAccess.open(backstory_path)
	if backstory_folder:
		for file in backstory_folder.get_files():
			var backstory = load(backstory_path + "/" + file)
			backstories.push_back(backstory)
	
	# Load all abilities
	#var abilities = []
	#var ability_path = "res://Resources/Abilities/"
	#var ability_folder = DirAccess.open(ability_path)
	#if ability_folder:
		#for file in ability_folder.get_files():
			#var ability = load(ability_path + "/" + file)
			#abilities.push_back(ability)

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
