extends KinematicBody2D




onready var screen_size = get_viewport_rect().size
var direction = Vector2(0,0)
var rng = RandomNumberGenerator.new()
onready var anispr = $AnimatedSprite
onready var carea = $CohesionArea
onready var sarea = $SeparationArea
onready var aarea = $AdhesionArea
onready var tarea = $TargetArea
export var MAX_SPEED = 200
# initialize
func _ready():
	rng.randomize()
	
	# randomize starting frames
	anispr.frame = rng.randi_range(0,5)
	
	# randomize starting direction
	var start_angle = rng.randf_range(0.0, 2 * PI)
	direction.x = 1000 * cos(start_angle)
	direction.y = 1000 * sin(start_angle)
	
	# randomize colors
	sheepColorize()

# color the sheep different colors
func sheepColorize():
	
	var random_brighten_percent = rng.randf_range(0.0,0.5)
	var random_darken_percent = rng.randf_range(0.0,0.5)
# set the default color to gold
	anispr.modulate = Color("#F2AF29") 
# apply color randomness
	anispr.modulate = anispr.modulate.blend(Color(1.0,1.0,1.0,random_brighten_percent))
	anispr.modulate = anispr.modulate.blend(Color(0.0,0.0,0.0,random_darken_percent))

# all sheep move towards center of mass of nearby sheep
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
# all sheep move out of the way of other very nearby sheep
func separation():
	var move_away = Vector2(0,0)
	var neighbor_sheep = sarea.get_overlapping_bodies()
	for sheep in neighbor_sheep:
		if sheep == self || (!sheep.is_in_group("Sheep") && !sheep.is_in_group("Chicken")):
			continue
		move_away -= (sheep.position - position)
	return move_away
# all sheep point in the general direction of nearby sheep
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
# all sheep move toward the target
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

# collect all the cohesion, separation, adhesion, and target rules together
func run():
	# FLOCKING RULES
	direction += cohesion()
	direction += separation()
	direction += adhesion()
	direction += target()
	# direction /= 1.01
	# makes sure that the sheep don't go lightspeed
	direction = direction.clamped(MAX_SPEED)

# apply position changes and manage states
func _process(delta):
	# if the state == run
	if anispr.animation == "run":
		run()
		# condition to go to rolling
		if (rng.randf_range(1.0, 500.0) < 2.0):
			anispr.play("roll")
			anispr.speed_scale = 2
	
	# if the sheep is going in a different direction, change which way the sprite is facing
	anispr.flip_h = !(direction.dot(Vector2(1,0)) > 0)
	# make sure that sheep appear in the right order on the screen
	z_index = position.y
	# delta ensures that the sheep move at the same speed on different devices
	position += direction * delta 
	screenWrap()

# if the sheep is off the screen move it to the other side of the screen
func screenWrap():
	if (position.x > screen_size.x):
		position.x = 0
	if position.x < 0:
		position.x = screen_size.x
	if position.y > screen_size.y:
		position.y = 0
	if position.y < 0:
		position.y = screen_size.y

# condition to go back to running from rolling
func _on_AnimatedSprite_animation_finished():
	if anispr.animation == "roll":
		anispr.play("run")
		anispr.speed_scale = 2.888
