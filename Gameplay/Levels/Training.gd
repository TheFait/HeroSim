extends Level
class_name Training

var team1:Team
var team2:Team
@onready var match_label = $CanvasLayer/MatchLabel
@onready var tournament_round_label = $CanvasLayer/PanelContainer/TournamentRoundLabel


var teams:Dictionary = {}

var combatants:Array[Hero] = []
var league:Array[Team] = []
var game_over:bool = false
var round_number:int = 0

var winning_heroes:Array[Hero]

# From BossRush, should we shuffle the players up or make new players
var shuffle_teams:bool = false

func init_scene():
	empty_heroes()
	
	get_tree().paused = false
	# Set level id
	level_name = "training"
	print("Loaded level --- ", level_name)
	
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
	
	if !shuffle_teams:
		# generate a new league from the league manager
		league = GameManager.generate_league()
	else:
		# ask the league to shuffle players
		league = GameManager.shuffle_heroes()
	
	reset_tournament()
	update_teams_label(league)
	
	
	tournament_round_label.text = "Quarterfinals"
	# Run matches in tournament format	
	# playMatch function returns the winner, assign to variable
	var results1:Array = await playMatch(league[0],league[1])
	print_matches_results(results1)
	attack_name.text = "Next match coming up soon"
	await game_timeout()
	var results2:Array = await playMatch(league[2],league[3])
	print_matches_results(results2)
	set_ticker_message("Next match coming up soon")
	await game_timeout()
	var results3:Array = await playMatch(league[4],league[5])
	print_matches_results(results3)
	set_ticker_message("Next match coming up soon")
	await game_timeout()
	var results4:Array = await playMatch(league[6],league[7])
	print_matches_results(results4)
	set_ticker_message("Next match coming up soon")
	await game_timeout()
	tournament_round_label.text = "Semifinals"
	var results5:Array = await playMatch(results1[0], results2[0])
	print_matches_results(results5)
	set_ticker_message("Next match coming up soon")
	await game_timeout()
	var results6:Array = await playMatch(results3[0], results4[0])
	print_matches_results(results6)
	set_ticker_message("Next match coming up soon")
	await game_timeout()
	tournament_round_label.text = "Finals"
	var results7:Array = await playMatch(results5[0], results6[0])
	print_matches_results(results7)
	
	ticker.clear()
	ticker.append_text(str("[center]The tournament winner is: ", results7[0].team_name))
	attack_name.text = str("Sending ", results7[0].team_name, " and ", results7[1].team_name, " to the boss rush!")
	await get_tree().create_timer(3).timeout
	winning_heroes = results7[0].heroes + results7[1].heroes
	empty_heroes()
	SceneManager.swap_scenes(SceneRegistry.levels["boss_rush"],get_tree().root,self,"fade_to_black")


func game_timeout():
	update_teams_label(league)
	if (!GameManager.skip_animations):
		await get_tree().create_timer(3).timeout
	else:
		await get_tree().create_timer(1).timeout

func prepare_match(p_team1:Team, p_team2:Team):
	var team1_players = p_team1.heroes
	var team2_players = p_team2.heroes
	empty_heroes()
	
	display_match_label(p_team1.team_name, p_team1.team_color, p_team2.team_name, p_team2.team_color)
	
	var startingPosition:Vector2
	# Place heroes on markers based on turn order
	for i in team1_players.size():
		startingPosition = team_1_positions.get_child(i).global_position
		team1_players[i].global_position = startingPosition
		team1_players[i].starting_position = startingPosition		
		heroes.add_child(team1_players[i])
		team1_players[i].team = 1
		team1_players[i].setup_for_battle(p_team1.team_color)
		
	for i in team2_players.size():
		startingPosition = team_2_positions.get_child(i).global_position
		team2_players[i].global_position = startingPosition
		team2_players[i].starting_position = startingPosition
		heroes.add_child(team2_players[i])
		team2_players[i].team = 2
		team2_players[i].setup_for_battle(p_team2.team_color)
	
	# Make list of all heroes so we can loop through
	combatants = team1_players + team2_players
	combatants.sort_custom(sort_heroes_by_speed)
	display_turn_order(combatants[0])

func playMatch(p_team1:Team, p_team2:Team):
	team1 = p_team1
	team2 = p_team2
	prepare_match(p_team1,p_team2)
	round_number = 0
	game_over = false
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
				var ability = hero.use_ability()
				var ability_name = ability.name
				#var ability_name = hero.stat_block.abilities[0].name
				
				attack_name.text = ability_name
				
				# Use ability on target
				print("Hero ", hero.get_hero_name(), " using ability ", ability_name, " on: ", target.get_hero_name())
				update_ticker_message(hero,target)
				#ticker.text = str("Hero ", hero.get_hero_name(), " targets ", target.get_hero_name())
				
				target.take_damage(hero.stat_block.abilities[0].damage)
				
				if (!GameManager.skip_animations):
					await get_tree().create_timer((1.0/GameManager.time_modifier)).timeout
				
				if target.alive == false:
					var target_team = target.team
					var anyone_alive:bool = false
					if target_team == 1:
						# anyone in team1 alive?
						for hero_target in team1.heroes:
							if hero_target.alive:
								anyone_alive = true
					if target_team == 2:
						# anyone in team2 alive?
						for hero_target in team2.heroes:
							if hero_target.alive:
								anyone_alive = true
					if !anyone_alive:
						game_over = true
						var winning_team:Team
						var losing_team:Team
						if (hero.team == 1):
							winning_team = team1
							losing_team = team2
						else:
							winning_team = team2
							losing_team = team1
						set_ticker_for_winner(winning_team)
						winning_team.wins += 1
						losing_team.knocked_out = true
						for member in winning_team.heroes:
							member.wins += 1
						return [winning_team, losing_team]
				
				
				if (!GameManager.skip_animations):
					tween.kill()
					tween = create_tween()
					hero.play_animation_player("walk")
					await tween.tween_property(hero, "position", hero.starting_position,(1.0/GameManager.time_modifier)).finished
				attack_name.text = ""
			
		# TODO re-evaluate the speed after every round and repeat
		combatants.sort_custom(sort_heroes_by_speed)

func display_match_label(team1_name:String, team1_color:Color, team2_name:String, team2_color:Color):
	match_label.clear()
	match_label.append_text("[center]")
	match_label.push_color(team1_color)
	match_label.append_text(team1_name)
	match_label.pop()
	match_label.append_text(" vs ")
	match_label.push_color(team2_color)
	match_label.append_text(team2_name)
	match_label.pop()
	#match_label.append_text("[/center]")

func _on_button_pressed():
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

func get_data() -> Array[Hero]:
	if (winning_heroes):
		return winning_heroes
	else:
		return league[3].heroes + league[5].heroes

func receive_data(p_shuffle_teams:bool):
	shuffle_teams = p_shuffle_teams

func update_teams_label(p_league:Array[Team]):
	teams_label.clear()
	for team in p_league:
		teams_label.push_color(team.team_color)
		if team.knocked_out:
			teams_label.append_text("[s]")
		teams_label.append_text(team.team_name)
		teams_label.pop()
		teams_label.newline()

func print_matches_results(results:Array):
	print("Winner: ", results[0].team_name, " --- Loser: ", results[1].team_name)

func reset_tournament():
	for team in league:
		team.knocked_out = false
