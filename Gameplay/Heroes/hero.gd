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

@onready var name_label = $NameLabel
@onready var hero_icon = $HeroIcon
@onready var sprites = $Sprites
@onready var animation_player = $AnimationPlayer
@onready var static_sprites = $StaticSprites
@onready var health_bar := $HeroHealth

var starting_position:Vector2
var team_color:Color
var char_name:String
var body_texture:Texture2D
var head_texture:Texture2D


func _ready():
	pass

func _process(_delta):
	pass

func setup():
	if backstory:
		char_name = backstory.get_full_name()

func set_color(p_color:Color):
	name_label.modulate = p_color
	health_bar.set_color(p_color)
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

func use_ability() -> Ability:
	return stat_block.abilities.pick_random()

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
