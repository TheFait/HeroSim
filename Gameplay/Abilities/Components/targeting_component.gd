extends Node
class_name TargetingComponent

enum TARGET_TYPE {SELF, ENEMY, FRIENDLY, ALLIES}

# target number of -1 means all 
@export var target_number:int = 0
@export var target_type:TARGET_TYPE = TARGET_TYPE.SELF
