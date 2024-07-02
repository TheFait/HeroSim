extends Node2D

func _ready():
	var file = FileAccess.open("res://Resources/CSVs/backstory.csv", FileAccess.READ)
	
	print(file)
