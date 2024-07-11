extends Node2D
class_name Hero

var stat_block : HeroStatBlock
var backstory: HeroBackstory
var team:int
var alive:bool = true
var current_health:int
var max_health:int
var health_mult:int
var wins:int = 0
var skip_turn:bool = false
var current_ability:Ability

@onready var name_label = $NameLabel
@onready var hero_icon = $HeroIcon
@onready var sprites = $Sprites
@onready var animation_player = $AnimationPlayer
@onready var static_sprites = $StaticSprites
@onready var health_bar := $HeroHealth
@onready var abilities = $Abilities
@onready var attack_effect = $StaticSprites/AttackEffect


var starting_position:Vector2
var team_color:Color
var char_name:String
var body_texture:Texture2D
var head_texture:Texture2D


func setup():
	if backstory:
		char_name = backstory.get_full_name()

func set_color(p_color:Color):
	name_label.modulate = p_color
	#health_bar.set_color(p_color)
	team_color = p_color

func setup_for_battle(p_color:Color, p_healthMult:int=1):
	health_mult = p_healthMult
	max_health = stat_block.health * health_mult
	current_health = max_health
	health_bar.init_health(max_health)
	set_color(p_color)
	name_label.text = char_name
	update_sprites()
	alive = true
	animation_player.play("walk")
	
	# reset sprite scale
	reset_sprite()
	# TODO move this to the Training Class and not in the sprite itself
	if team % 2 == 0:
		flip_sprite()

func set_team(p_team:int):
	team = p_team

func flip_sprite():
	sprites.scale.x *= -1
	static_sprites.scale.x *= -1

func reset_sprite():
	sprites.scale.x = abs(sprites.scale.x)
	static_sprites.scale.x = abs(static_sprites.scale.x)

func get_hero_name():
	if backstory:
		return char_name
	else:
		return "Unnamed Hero"
	
func get_display_hero_name() -> String:
	var return_string = ""
	if !alive:
		return_string += "[s]"
	return_string += str("[color=#",team_color.to_html(),"]")
	
	return_string += get_hero_name()
	return_string += str("[/color]")
	if !alive:
		return_string += "[/s]"
	#print(return_string)
	return return_string

func take_damage(damage:int):
	current_health = maxi(0, current_health - damage)
	health_bar.health = current_health
	if current_health == 0:
		alive = false
		animation_player.play("die")
		
func heal_damage(amount:int):
	print(get_hero_name(), " healing for ", amount)
	if current_health > 0:
		current_health = mini(max_health, current_health + amount)
		health_bar.health = current_health

func use_ability() -> Ability:
	
	# Grab first child ability -- hard coded
	var ability = abilities.get_children().pick_random()
	
	# Get targeting type from ability
	var target_comp = ability.find_child("TargetingComponent")
	print(target_comp)
	
	current_ability = stat_block.abilities.pick_random()
	return current_ability

func choose_ability() -> AbilityBase:
	return abilities.get_children().pick_random()

func perform_ability(_target:Hero):
	pass

func play_animation(animation_name:String):
	for animation:AnimatedSprite2D in sprites.get_children():
		animation.play(animation_name)

func play_animation_player(animation_name:String):
	animation_player.play(animation_name)

func update_sprites():
	static_sprites.get_node("Outfit").texture = body_texture
	static_sprites.get_node("Hair").texture = head_texture

func load_graphics(body:Texture2D, head:Texture2D):
	body_texture = body
	head_texture = head
	
func heal_to_full():
	current_health = max_health
	alive = true
	health_bar.init_health(max_health)
	animation_player.play("walk")

func take_turn(caller:Level) -> Array:
	var return_array = []
	if skip_turn:
		return []
	
	var ability:AbilityBase = choose_ability()
	print("Using ", ability.get_ability_name())
	# Get targeting type from ability
	var target_comp:TargetingComponent = ability.find_child("TargetingComponent") as TargetingComponent
	
	var targets:Array[Hero]
	
	match target_comp.target_type:
		TargetingComponent.TARGET_TYPE.FRIENDLY:
			print("target friend")
			targets = caller.get_targets_friendly(self, target_comp.target_number,true)
		TargetingComponent.TARGET_TYPE.ENEMY:
			print("target enemy")
			targets = caller.get_targets_enemy(self, target_comp.target_number)
		TargetingComponent.TARGET_TYPE.SELF:
			targets = [self]
			print("target self")
		TargetingComponent.TARGET_TYPE.ALLIES:
			print("targeting allies")
			targets = caller.get_targets_friendly(self,target_comp.target_number)
	
	# Loop through effects to use on target
	var damage_comp:DamageComponent = ability.find_child("DamageComponent") as DamageComponent
	if (damage_comp):
		for target in targets:
			target.take_damage(damage_comp.amount)
	
	# Loop through effects to use on target
	var heal_comp:HealComponent = ability.find_child("HealComponent") as HealComponent
	if (heal_comp):
		for target in targets:
			target.heal_damage(heal_comp.amount)
	
	return_array = [self, targets, ability]
	return return_array

# Attacks the target, returns the ability used
func attack(target:Hero):
	if(current_ability.self_effect_path != ""):
		var self_effect:Sprite2D = load(current_ability.self_effect_path).instantiate()
		attack_effect.add_child(self_effect)
	
	animation_player.play("attack")
	await animation_player.animation_finished
	
	target.take_damage(current_ability.damage)
	
	if(current_ability.target_effect_path != ""):
		var target_effect:Sprite2D = load(current_ability.target_effect_path).instantiate()
		target.add_child(target_effect)
		
	
