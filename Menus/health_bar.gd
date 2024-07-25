extends ProgressBar

@onready var damage_bar:ProgressBar = $DamageBar
@onready var value_display := $ValueDisplay
@onready var shield_bar: ProgressBar = $ShieldBar

var health:int = 0 :
	set(p_health):
		if p_health != health:
			# Split logic if we're healing or taking damage
			if (p_health > health): #healing
				health = p_health
				#set the underlying health, tween the actual
				damage_bar.value = health
				if (is_inside_tree()):
					var tween = get_tree().create_tween()
					tween.set_ease(Tween.EASE_IN)
					tween.set_trans(Tween.TRANS_QUAD)
					tween.tween_property(self,"value",p_health,(1.0/GameManager.time_modifier))
			else: #taking damage
				health = p_health
				#set the actual health, tween the underlying
				value = health
				if (is_inside_tree()):
					var tween = get_tree().create_tween()
					tween.set_ease(Tween.EASE_IN)
					tween.set_trans(Tween.TRANS_QUAD)
					tween.tween_property(damage_bar,"value",p_health,(1.0/GameManager.time_modifier))
			set_value_display()

var shield:int = 0 :
	set(p_shield):
		if p_shield != shield:
			# Split logic if we're healing or taking damage
			if (p_shield > shield): #healing
				shield = min(shield_bar.max_value, p_shield)
				#set the underlying health, tween the actual
				if (is_inside_tree()):
					var tween = get_tree().create_tween()
					tween.set_ease(Tween.EASE_IN)
					tween.set_trans(Tween.TRANS_QUAD)
					tween.tween_property(shield_bar,"value",p_shield,(1.0/GameManager.time_modifier))
			else: #taking damage
				shield = max(0, p_shield)
				if (is_inside_tree()):
					var tween = get_tree().create_tween()
					tween.set_ease(Tween.EASE_IN)
					tween.set_trans(Tween.TRANS_QUAD)
					tween.tween_property(shield_bar,"value",p_shield,(1.0/GameManager.time_modifier))
			set_value_display()

func init_health(_health):
	health = _health
	set_health(self)
	set_health(damage_bar)
	shield = 0
	shield_bar.value = 0
	
func set_health(bar:ProgressBar):
	bar.max_value = health
	bar.value = health

func set_color(p_color:Color):
	#damage_bar.get("theme_override_styles/fill").bg_color = p_color
	#get("theme_override_styles/fill").bg_color = p_color
	var style_box:StyleBoxFlat = StyleBoxFlat.new()
	add_theme_stylebox_override("fill",style_box)
	style_box.bg_color = p_color
	
	#var damage_bar_style:StyleBoxFlat = StyleBoxFlat.new()
	#damage_bar.add_theme_stylebox_override("fill", damage_bar_style)
	#damage_bar_style.bg_color = p_color.darkened(.55)

func set_value_display():
	value_display.text = str(health,"/",shield)
