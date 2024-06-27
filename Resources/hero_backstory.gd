extends Resource
class_name HeroBackstory

@export var first_name:String
@export var last_name:String
@export var color:Color
@export var home_town:String

func get_full_name():
	return str(first_name, " ", last_name)
