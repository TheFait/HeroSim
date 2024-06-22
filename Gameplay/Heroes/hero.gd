extends Node2D
class_name Hero

var stat_block : HeroStatBlock
var backstory: HeroBackstory
var team:int
var alive:bool = true
var current_health:int
var max_health:int
@onready var name_label = $NameLabel
@onready var hero_icon = $HeroIcon
@onready var sprites = $Sprites
@onready var animation_player = $AnimationPlayer
@onready var static_sprites = $StaticSprites

@onready var health_bar := $HealthBar
var starting_position:Vector2
var team_color:Color
var char_name:String



func _ready():
	pass


func _process(_delta):
	pass

func setup(p_team:int, p_position:int, p_color:Color):
	if backstory:
		char_name = backstory.name + str(p_team) + str(p_position) 
		name_label.text = char_name
		name_label.modulate = p_color
		hero_icon.modulate = backstory.color
		sprites.modulate = backstory.color
		#static_sprites.modulate = backstory.color
	health_bar.max_value = stat_block.health
	max_health = stat_block.health
	current_health = max_health
	health_bar.value = stat_block.health
	health_bar.tint_progress = p_color
	team_color = p_color
	team = p_team
	if team == 2:
		sprites.scale.x *= -1
		static_sprites.scale.x *= -1
	

func get_hero_name():
	if backstory:
		return char_name
	else:
		return "Unnamed Hero"

func update_display():
	health_bar.value = stat_block.health	

func take_damage(damage:int):
	current_health = maxi(0, current_health - damage)
	var tween = create_tween()
	tween.tween_property(health_bar,"value", current_health, 1)
	health_bar.get_child(0).text = str(current_health)
	if current_health == 0:
		alive = false

func play_animation(animation_name:String):
	for animation:AnimatedSprite2D in sprites.get_children():
		animation.play(animation_name)

func play_animation_player(animation_name:String):
	animation_player.play(animation_name)

func load_graphics(body:Texture2D, head:Texture2D):
	static_sprites.get_node("Outfit").texture = body
	static_sprites.get_node("Hair").texture = head
