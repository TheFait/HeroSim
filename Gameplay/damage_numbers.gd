extends Node2D

@export var display_position:Marker2D
const BOUNCE_HEIGHT:int = 150
const BOUNCE_EXPLOSION_HEIGHT:int = 50
const BOUNCE_VARIANCE:int = 10

func display_number(value: int, is_critical:bool=false, p_position:Vector2=Vector2.ZERO):
	var number = Label.new()
	
	if(display_position):
		number.global_position = display_position.global_position
	else:
		number.global_position = p_position
	
	number.text = str(value)
	number.z_index = 10
	number.label_settings = LabelSettings.new()
	
	var color = "#FFF"
	if is_critical:
		color = "#B22"
	if value == 0:
		color = "#FFF8"
	
	number.label_settings.font_color = color
	number.label_settings.font_size = 50
	number.label_settings.outline_color = "#000"
	number.label_settings.outline_size = 8

	call_deferred("add_child", number)
	
	await number.resized
	number.pivot_offset = Vector2(number.size/2)
	
	# Choose random amount left or right to offset
	var damage_x_offset:int = randi_range(-BOUNCE_VARIANCE, BOUNCE_VARIANCE)
	
	var tween = get_tree().create_tween()
	#tween.set_parallel(true)
	tween.tween_property(number, "position", Vector2(damage_x_offset, number.position.y - BOUNCE_HEIGHT), .5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(number, "modulate:a", 0, .5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(number, "scale", Vector2(2,2), .25).set_ease(Tween.EASE_IN)
	
	tween.finished.connect(func(): number.queue_free())
