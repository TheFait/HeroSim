extends Node
class_name HealComponent

enum ELEMENTS {LITORIA, VESPERTILIO, ACCLIMA, CYBROSIA, MU,
PERIMBAL, LACRIMOSE, WEMBERLY, IXDAL, KETERIN, GOCHA, 
OVALVER}

@export var amount:float = 0.0
@export var element:ELEMENTS = ELEMENTS.LITORIA

func perform(_target:Hero):
	pass
