extends KinematicBody2D




onready var screen_size = get_viewport_rect().size
var direction = Vector2(0,0)
var rng = RandomNumberGenerator.new()
onready var anispr = $AnimatedSprite
onready var carea = $CohesionArea
onready var sarea = $SeparationArea
onready var aarea = $AdhesionArea
onready var tarea = $TargetArea

func _ready():
	rng.randomize()
	anispr.frame = rng.randi_range(0,5)
	var start_angle = rng.randf_range(0.0, 2 * PI)
	direction.x = 1000 * cos(start_angle)
	direction.y = 1000 * sin(start_angle)
	sheepColorize()


func sheepColorize():
	
	var random_brighten_percent = rng.randf_range(0.0,0.5)
	var random_darken_percent = rng.randf_range(0.0,0.5)
# set the default color to gold
	anispr.modulate = Color("#F2AF29") 
# apply color randomness
	anispr.modulate = anispr.modulate.blend(Color(1.0,1.0,1.0,random_brighten_percent))
	anispr.modulate = anispr.modulate.blend(Color(0.0,0.0,0.0,random_darken_percent))


func cohesion():
	var neighbor_sheep = carea.get_overlapping_bodies()
	var total_position = Vector2(0,0)
	var number_of_sheep = 0
	for sheep in neighbor_sheep:
		if (sheep == self) || !sheep.is_in_group("Sheep"):
			continue
		number_of_sheep += 1
		total_position += sheep.position
	if number_of_sheep != 0:
		var average_position = total_position/number_of_sheep
		
		return (average_position-position)/100
	else:
		return Vector2(0,0)
func separation():
	var move_away = Vector2(0,0)
	var neighbor_sheep = sarea.get_overlapping_bodies()
	for sheep in neighbor_sheep:
		if sheep == self || !sheep.is_in_group("Sheep"):
			continue
		move_away -= (sheep.position - position)
	return move_away

func adhesion():
	var neighbor_sheep = aarea.get_overlapping_bodies()
	var total_velocity = Vector2(0,0)
	var number_of_sheep = 0
	for sheep in neighbor_sheep:
		if sheep == self || !sheep.is_in_group("Sheep"):
			continue
		number_of_sheep += 1
		total_velocity = sheep.direction
	var average_velocity = Vector2(0,0)
	if number_of_sheep != 0:
		average_velocity = total_velocity / number_of_sheep
	return average_velocity / 8
func target():
	var neighbor_sheep = tarea.get_overlapping_bodies()
	var total_position = Vector2(0,0)
	var number_of_sheep = 0
	for sheep in neighbor_sheep:
		if (sheep == self) || !sheep.is_in_group("Target"):
			continue
		number_of_sheep += 1
		total_position += sheep.position
	if number_of_sheep != 0:
		var average_position = total_position/number_of_sheep
		
		return (average_position-position)/30
	else:
		return Vector2(0,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	if anispr.animation == "run":
# FLOCKING RULES
		direction += cohesion()
		direction += separation()
		direction += adhesion()
		direction += target()
# makes sure that the sheep don't go lightspeed
		direction = direction.clamped(200) 
#	direction /= 1.01
# delta ensures that the sheep move at the same speed on different devices
	position += direction * delta 
# if the sheep is going in a different direction, change which way the sprite is facing
	anispr.flip_h = !(direction.dot(Vector2(1,0)) > 0)
	screenWrap()
# make sure that sheep appear in the right order on the screen
	z_index = position.y
	if (rng.randf_range(1.0, 500.0) < 2.0):
		anispr.play("roll")
		anispr.speed_scale = 2
	
	
func screenWrap():
	if (position.x > screen_size.x):
		position.x = 0
	if position.x < 0:
		position.x = screen_size.x
	if position.y > screen_size.y:
		position.y = 0
	if position.y < 0:
		position.y = screen_size.y



func _on_AnimatedSprite_animation_finished():
	if anispr.animation == "roll":
		anispr.play("run")
		anispr.speed_scale = 2.888
