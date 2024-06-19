extends Node2D

var team1:Array[Hero] = []
var team2:Array[Hero] = []
var combatants:Array[Hero] = []

var game_over:bool = false

func _ready():
		
	# Load all stat blocks
	var stat_blocks:Array = []
	var stat_block_path = "res://Resources/HeroStatBlocks/"
	var stat_block_folder = DirAccess.open(stat_block_path)
	if stat_block_folder:
		for file in stat_block_folder.get_files():
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

	# Generate 2 teams of 8 Heroes
	for i in 2:
		for j in 4:
			var hero:Hero = Hero.new()
			hero.stat_block = stat_blocks.pick_random()
			hero.team = i
			if i % 2 == 1:
				team1.push_back(hero)
			else:
				team2.push_back(hero)
			print("Created team", i, " hero ", hero.stat_block.name, " with ability: ", hero.stat_block.abilities[0].name, " and speed ", hero.stat_block.speed)
			
	# Create turn order
	combatants = team1 + team2
	combatants.sort_custom(sort_heroes_by_speed)
	print("Sorted Heroes")
	for hero in combatants:
		print("Hero ", hero.stat_block.name, " on team ", hero.team, " with ability: ", hero.stat_block.abilities[0].name, " and speed ", hero.stat_block.speed)
	
	# TODO while loop until gameover flag, go through all heroes in list
	while (!game_over):
		# Fight battle
		for hero in combatants:
			print("Turn: Hero ", hero.stat_block.name)
			# TODO for each hero choose a random living target on the other team. Use ability on target. Update stats of target
			# TODO if other team has no targets, game is over
			
			# choose random target			
			var target:Hero
			# Loop until we find valid target
			var valid_target_selected:bool = false
			while (!valid_target_selected):
				target = combatants.pick_random()
				if hero.team != target.team and target.alive:
					valid_target_selected = true
					
			
			# Use ability on target
			print("Hero ", hero.stat_block.name, " using ability ", hero.stat_block.abilities[0].name, " on: ", target.stat_block.name)
			target.stat_block.health = maxi(0, target.stat_block.health - hero.stat_block.abilities[0].damage)
			print("New health for ", target.stat_block.name, " is ", target.stat_block.health)
			
			if target.stat_block.health == 0:
				target.alive = false
				# TODO check if match has ended
				game_over = true
				return

func sort_heroes_by_speed(a:Hero, b:Hero):
	var speed1 = a.stat_block.speed
	var speed2 = b.stat_block.speed
	return speed1 > speed2
