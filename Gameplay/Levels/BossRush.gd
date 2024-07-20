extends Level
class_name BossRush

var team1:Array[Hero]
@export var team1_color:Color = Color.INDIAN_RED
var team2:Array[Hero]
@export var team2_color:Color = Color.DODGER_BLUE
var combatants:Array[Hero] = []
var game_over:bool = false
var round_number:int = 0

func _ready():
	$CanvasLayer/RandomOutfitButton.connect("pressed", _on_random_outfit_button_pressed)
	$CanvasLayer/RandomBGButton.connect("pressed", _on_change_bg_pressed)
	$CanvasLayer/SwapLevel.connect("pressed", _on_swap_level_pressed)
	time_slider.value = GameManager.time_modifier
	time_slider.value_changed.connect(_on_time_slider_value_changed)

func init_scene():
	get_tree().paused = false
	# Set level id
	level_name = "boss_rush"
	print("Loaded level --- ", level_name)
	
	# Load all backgrounds	
	var background_path = "res://Assets/Images/Backgrounds/"
	var background_folder = DirAccess.open(background_path)
	if background_folder:
		for file in background_folder.get_files():
			if (file.get_extension() == "import"):
				file = file.replace('.import', '')
			if (file.get_extension() == "png"):
				var background_file = load(background_path + "/" + file)
				backgrounds.push_back(background_file)
	
	# Choose random background and set it to scene
	current_background = randi_range(0,backgrounds.size()-1)
	background.texture = backgrounds[current_background]
	
	
	# get the league from the league manager
	#var full_league = GameManager.get_full_league()
	#print(full_league[1])
	
func start_scene():
	#var players:Array[Hero] = full_league[1].players + full_league[2].players
	var monster:Array[Hero] = [GameManager.generate_monster()]
	prepare_match(team1, monster)
	await playMatch()
	
	attack_name.text = "Returning to training mode with new league"
	await get_tree().create_timer(3).timeout
	empty_heroes()
	SceneManager.swap_scenes(SceneRegistry.levels["training"],get_tree().root,self,"fade_to_black")

func receive_data(p_team1:Array[Hero]):
	team1 = p_team1.duplicate()
	print("Received team1 data: ", team1)
	
func get_data():
	return true

func prepare_match(p_team1:Array[Hero], p_team2:Array[Hero]):
	team1 = p_team1
	team2 = p_team2
	
	var startingPosition:Vector2
	# Place heroes on markers based on turn order
	for i in team1.size():
		startingPosition = team_1_positions.get_child(0).get_child(i).global_position
		team1[i].global_position = startingPosition
		team1[i].starting_position = startingPosition		
		heroes.add_child(team1[i])
		team1[i].team = 1
		team1[i].setup_for_battle(team1_color)
		
	for i in team2.size():
		startingPosition = team_2_positions.get_child(i).global_position
		team2[i].global_position = startingPosition
		team2[i].starting_position = startingPosition
		heroes.add_child(team2[i])
		team2[i].team = 2
		team2[i].setup_for_battle(team2_color, 10)
		team2[i].scale *= 2
	
	# Make list of all heroes so we can loop through
	combatants = team1 + team2
	combatants.sort_custom(sort_heroes_by_speed)
	display_turn_order(combatants[0])

func playMatch():
	round_number = 0
	# TODO while loop until gameover flag, go through all heroes in list
	while (!game_over):
		# Fight battle
		round_number += 1
		for hero in combatants:
			if hero.alive:
				
				print("Turn: Hero ", hero.get_hero_name())
				display_turn_order(hero)
				var tween
				if (!GameManager.skip_animations):
					# Move hero to the front
					tween = create_tween()
					if (hero.team == 1):
						tween.tween_property(hero, "position", team_1_attacker.position,(.5/GameManager.time_modifier))
					else:
						tween.tween_property(hero, "position", team_2_attacker.position,(.5/GameManager.time_modifier))
					hero.play_animation("run")
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
				var ability = hero.use_ability()
				var ability_name = ability.name
				#var ability_name = hero.stat_block.abilities[0].name
				
				attack_name.text = ability_name
				
				# Use ability on target
				print("Hero ", hero.get_hero_name(), " using ability ", ability_name, " on: ", target.get_hero_name())
				update_ticker_message(hero,[target])
				#ticker.text = str("Hero ", hero.get_hero_name(), " targets ", target.get_hero_name())
				
				target.take_damage(hero.stat_block.abilities[0].damage)
				
				if (!GameManager.skip_animations):
					await get_tree().create_timer((1.0/GameManager.time_modifier)).timeout
				
				if target.alive == false:
					var team = target.team
					var anyone_alive:bool = false
					if team == 1:
						# anyone in team1 alive?
						for hero_target in team1:
							if hero_target.alive:
								anyone_alive = true
					if team == 2:
						# anyone in team2 alive?
						for hero_target in team2:
							if hero_target.alive:
								anyone_alive = true
					if !anyone_alive:
						game_over = true
						attack_name.text = ("Match over, winning team is: " + str(hero.team))
						return
				
				
				
				if (!GameManager.skip_animations):
					tween.kill()
					tween = create_tween()
					hero.play_animation("walk")
					await tween.tween_property(hero, "position", hero.starting_position,(1.0/GameManager.time_modifier)).finished
				attack_name.text = ""
			
		# TODO re-evaluate the speed after every round and repeat
		combatants.sort_custom(sort_heroes_by_speed)

func _on_change_bg_pressed():
	current_background = (current_background + 1) % backgrounds.size()
	background.texture = backgrounds[current_background]


func _on_random_outfit_button_pressed():
	for combatant in combatants:
		GameManager.randomize_hero_visual(combatant)
		combatant.update_sprites()

func display_turn_order(current_hero:Hero):
	turn_order.clear()
	turn_order.append_text("[right]")
	if round_number > 0:
		turn_order.append_text(str("Round: ", round_number))
		turn_order.newline()
	for hero in combatants:
		if hero == current_hero:
			turn_order.push_color(Color.YELLOW)
			turn_order.append_text("> ")
			turn_order.pop()
		turn_order.append_text(hero.get_display_hero_name())
		turn_order.newline()
