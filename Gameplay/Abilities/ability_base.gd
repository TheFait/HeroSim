extends Node2D
class_name AbilityBase

func perform(caster:Hero, target:Hero):
	print("Caster: ", caster, " ---- Target: ", target)

func get_ability_name() -> String:
	var ability_name = get_node("AbilityDisplay").ability_name
	
	if (ability_name):
		return ability_name
	else:
		return ""

func get_icon():
	var ability_icon = get_node("AbilityDisplay").ability_icon
	if (ability_icon):
		return ability_icon
	else:
		return ""
