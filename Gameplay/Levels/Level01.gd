extends Node2D

var team1:Array[Hero] = []
@export var team1_color:Color = Color.INDIAN_RED
var team2:Array[Hero] = []
@export var team2_color:Color = Color.DODGER_BLUE
var combatants:Array[Hero] = []

var game_over:bool = false

@onready var team_1_positions := $Team1Positions
@onready var team_2_positions := $Team2Positions
@onready var heroes := $Heroes
@onready var team_1_attacker := $Team1Attacker
@onready var team_2_attacker := $Team2Attacker
@onready var attack_name = $CanvasLayer/AttackNameControl/Panel/CenterContainer/AttackName
@onready var ticker = $CanvasLayer/TickerControl/Panel/Ticker
@onready var background = $Background
@onready var turn_order = $CanvasLayer/TurnOrderControl/TurnOrder


var backgrounds:Array = []
var bodies:Array = []
var heads:Array = []
var current_background:int = 0

var round_number:int = 0

func _ready():
	# Load all backgrounds	
	var background_path = "res://Assets/Images/Backgrounds/"
	var background_folder = DirAccess.open(background_path)
	if background_folder:
		for file in background_folder.get_files():
			if (file.get_extension() == "png"):
				var background_file = load(background_path + "/" + file)
				backgrounds.push_back(background_file)
	
	# Choose random background and set it to scene
	current_background = randi_range(0,backgrounds.size()-1)
	background.texture = backgrounds[current_background]
	
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
	var stat_blocks:Array = []
	var stat_block_path = "res://Resources/HeroStatBlocks/"
	var stat_block_folder = DirAccess.open(stat_block_path)
	if stat_block_folder:
		for file in stat_block_folder.get_files():
			var stat_block = load(stat_block_path + "/" + file)
			stat_blocks.push_back(stat_block)
			
	
	# Load all backstories
	var backstories = []
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

	# Generate 2 teams of 8 Heroes
	for i in 2:
		for j in 4:
			var hero:Hero = preload("res://Gameplay/Heroes/hero.tscn").instantiate()
			var hero_color:Color
			hero.stat_block = stat_blocks.pick_random()
			hero.backstory = backstories.pick_random()
			
			if i % 2 == 0:
				team1.push_back(hero)
				hero_color = team1_color
			else:
				team2.push_back(hero)
				hero_color = team2_color
			#print("Created team", i, " hero ", hero.get_hero_name(), " with ability: ", hero.stat_block.abilities[0].name, " and speed ", hero.stat_block.speed)
			heroes.add_child(hero)
			hero.setup(i+1,j+1, hero_color)
			hero.load_graphics(bodies.pick_random(), heads.pick_random())
			
	# Create turn order
	combatants = team1 + team2
	combatants.sort_custom(sort_heroes_by_speed)
	print("Sorted Heroes")
	for hero in combatants:
		print("Hero ", hero.get_hero_name(), " on team ", hero.team, " with ability: ", hero.stat_block.abilities[0].name, " and speed ", hero.stat_block.speed)
	
	var startingPosition:Vector2
	# Place heroes on markers based on turn order
	for i in team1.size():
		startingPosition = team_1_positions.get_child(i).global_position
		team1[i].global_position = startingPosition
		team1[i].starting_position = startingPosition
		
	for i in team2.size():
		startingPosition = team_2_positions.get_child(i).global_position
		team2[i].global_position = startingPosition
		team2[i].starting_position = startingPosition
	
	display_turn_order()
	
	# TODO while loop until gameover flag, go through all heroes in list
	while (!game_over):
		# Fight battle
		round_number += 1
		for hero in combatants:
			if hero.alive:
				
				print("Turn: Hero ", hero.get_hero_name())
				display_turn_order(hero.char_name)
				
				# Move hero to the front
				var tween = create_tween()
				if (hero.team == 1):
					tween.tween_property(hero, "position", team_1_attacker.position,.5)
				else:
					tween.tween_property(hero, "position", team_2_attacker.position,.5)
				hero.play_animation_player("run")
				await tween.finished
				
				# choose random target			
				var target:Hero
				# Loop until we find valid target
				var valid_target_selected:bool = false
				while (!valid_target_selected):
					
					target = combatants.pick_random()
					if hero.team != target.team and target.alive:
						valid_target_selected = true
				
				# Choose a random ability
				var ability = hero.stat_block.abilities.pick_random() as Ability
				var ability_name = ability.name
				#var ability_name = hero.stat_block.abilities[0].name
				
				attack_name.text = ability_name
				
				# Use ability on target
				print("Hero ", hero.get_hero_name(), " using ability ", ability_name, " on: ", target.get_hero_name())
				set_ticker_message(hero,target)
				#ticker.text = str("Hero ", hero.get_hero_name(), " targets ", target.get_hero_name())
				
				target.take_damage(hero.stat_block.abilities[0].damage)
				#target.update_display()
				#print("New health for ", target.get_hero_name(), " is ", target.current_health)
				
				await get_tree().create_timer(1).timeout
				
				if target.alive == false:
					## TODO check if match has ended
					game_over = true
					attack_name.text = ("Match over, winning team is: " + str(hero.team))
					return
				
				
				tween.kill()
				tween = create_tween()
				hero.play_animation_player("walk")
				await tween.tween_property(hero, "position", hero.starting_position,1.0).finished
				attack_name.text = ""
			
		# TODO re-evaluate the speed after every round and repeat
		

func sort_heroes_by_speed(a:Hero, b:Hero):
	var speed1 = a.stat_block.speed
	var speed2 = b.stat_block.speed
	return speed1 > speed2

func set_ticker_message(hero:Hero, target:Hero):
	ticker.clear()
	ticker.append_text("[center]")
	ticker.append_text("Hero ")
	ticker.push_color(hero.team_color)
	ticker.append_text(hero.get_hero_name())
	ticker.pop()
	ticker.append_text(" targets ")
	ticker.push_color(target.team_color)
	ticker.append_text(target.get_hero_name())
	ticker.pop()


func _on_button_pressed():
	current_background = (current_background + 1) % backgrounds.size()
	background.texture = backgrounds[current_background]


func _on_random_outfit_button_pressed():
	for combatant in combatants:
		combatant.load_graphics(bodies.pick_random(), heads.pick_random())

func display_turn_order(current_turn:String=""):
	turn_order.clear()
	turn_order.append_text("[right]")
	if round_number > 0:
		turn_order.append_text(str("Round: ", round_number))
		turn_order.newline()
	for hero in combatants:
		if hero.char_name == current_turn:
			turn_order.push_color(Color.YELLOW)
			turn_order.append_text("> ")
			turn_order.pop()
		turn_order.push_color(hero.team_color)
		turn_order.append_text(hero.get_hero_name())
		turn_order.pop()
		turn_order.newline()
