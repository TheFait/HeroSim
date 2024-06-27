extends Node2D
class_name Level

@onready var team_1_positions := $Team1Positions
@onready var team_2_positions := $Team2Positions
@onready var heroes := $Heroes
@onready var team_1_attacker := $Team1Attacker
@onready var team_2_attacker := $Team2Attacker
@onready var attack_name = $CanvasLayer/AttackNameControl/Panel/CenterContainer/AttackName
@onready var ticker = $CanvasLayer/TickerControl/Panel/Ticker
@onready var background = $Background
@onready var turn_order = $CanvasLayer/TurnOrderControl/TurnOrder
@onready var time_slider = $CanvasLayer/TimeSlider
@onready var teams_label = $CanvasLayer/TeamsPanelContainer/TeamsLabel


var backgrounds:Array = []
var current_background:int = 0
var level_name

func _ready():
	time_slider.value = GameManager.time_modifier

func sort_heroes_by_speed(a:Hero, b:Hero):
	var speed1 = a.stat_block.speed
	var speed2 = b.stat_block.speed
	return speed1 > speed2

func update_ticker_message(hero:Hero, target:Hero):
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

func set_ticker_message(message:String):
	ticker.clear()
	ticker.append_text(message)
	
func set_ticker_for_winner(winner:Team):
	ticker.clear()
	ticker.append_text("[center]")
	ticker.append_text("The winner is: ")
	ticker.push_color(winner.team_color)
	ticker.append_text(winner.team_name)
	ticker.pop()

func _on_swap_level_pressed():
	#print("swapping level: ", level_name)
	match level_name:
		"training":
			#get_tree().paused = true
			empty_heroes()
			SceneManager.swap_scenes(SceneRegistry.levels["boss_rush"],get_tree().root,self,"fade_to_black")
		"boss_rush":
			#get_tree().paused = true
			print("Swapping to training")
			empty_heroes()
			SceneManager.swap_scenes(SceneRegistry.levels["training"],get_tree().root,self,"fade_to_black")

func empty_heroes():
	for child in heroes.get_children():
		heroes.remove_child(child)


func _on_time_slider_value_changed(value):
	GameManager.time_modifier = value
	if GameManager.time_modifier == 10:
		GameManager.skip_animations = true
	else:
		GameManager.skip_animations = false
