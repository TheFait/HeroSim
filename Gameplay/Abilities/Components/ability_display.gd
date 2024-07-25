@tool

extends Node
class_name AbilityDisplay

@export var ability_name:String = "":
	set(p_name):
		if p_name != ability_name:
			print("Ability name changed")
			ability_name = p_name
			update_configuration_warnings()
@export var ability_description:String = ""
@export var ability_icon:Texture2D:
	set(p_icon):
		if p_icon != ability_icon:
			ability_icon = p_icon
			update_configuration_warnings()

func _get_configuration_warnings():
	var warnings = []
	
	if ability_name == "":
		warnings.append("Please set a name for the ability")
	
	if ability_icon == null:
		warnings.append("Set an icon for the ability")
	
	return warnings
