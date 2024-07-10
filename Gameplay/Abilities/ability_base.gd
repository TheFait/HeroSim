extends Node2D
class_name AbilityBase

func perform(caster:Hero, target:Hero):
	print("Caster: ", caster, " ---- Target: ", target)

func get_ability_name() -> String:
	var ability_name = find_child("AbilityDisplay").ability_name
	if (name):
		return ability_name
	else:
		return ""
