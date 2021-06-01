extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var sheep_speed = 1
onready var screen_size = get_viewport_rect().size
var direction = Vector2(0,0)
var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	$AnimatedSprite.frame = rng.randi_range(0,5)
	var start_angle = rng.randf_range(0.0, 2 * PI)
	direction.x = 1000 * cos(start_angle)
	direction.y = 1000 * sin(start_angle)
	sheepColorize()


func sheepColorize():
	
	var random_color_percent = rng.randf_range(0.0,0.5)
	var random_darken_percent = rng.randf_range(0.0,0.5)
	$AnimatedSprite.modulate = Color("#F2AF29")
	$AnimatedSprite.modulate = $AnimatedSprite.modulate.blend(Color(1.0,1.0,1.0,random_color_percent))
	$AnimatedSprite.modulate = $AnimatedSprite.modulate.blend(Color(0.0,0.0,0.0,random_darken_percent))


func cohesion():
	var neighbor_sheep = $CohesionArea.get_overlapping_bodies()
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
	var neighbor_sheep = $SeparationArea.get_overlapping_bodies()
	for sheep in neighbor_sheep:
		if sheep == self || !sheep.is_in_group("Sheep"):
			continue
		move_away -= (sheep.position - position)
	return move_away

func adhesion():
	var neighbor_sheep = $AdhesionArea.get_overlapping_bodies()
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
	var neighbor_sheep = $TargetArea.get_overlapping_bodies()
	var total_position = Vector2(0,0)
	var number_of_sheep = 0
	for sheep in neighbor_sheep:
		if (sheep == self) || sheep.is_in_group("Sheep"):
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
	direction += cohesion()
	direction += separation()
	direction += adhesion()
	direction += target()
	direction = direction.clamped(200) 
#	direction /= 1.01
	position += direction * delta 
	$AnimatedSprite.flip_h = !(direction.dot(Vector2(1,0)) > 0)
	screenWrap()
	z_index = position.y
	
func screenWrap():
	if (position.x > screen_size.x):
		position.x = 0
	if position.x < 0:
		position.x = screen_size.x
	if position.y > screen_size.y:
		position.y = 0
	if position.y < 0:
		position.y = screen_size.y

