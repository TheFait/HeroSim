extends Node
class_name Team

var team_name:String = ""
var heroes:Array[Hero]
var team_color:Color = Color.BLACK
var team_logo:Sprite2D
var wins:int
var knocked_out:bool = false

func heal_to_full():
	for hero in heroes:
		hero.heal_to_full()
