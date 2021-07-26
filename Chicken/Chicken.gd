extends KinematicBody2D

var direction = Vector2(0,0)
onready var screen_size = get_viewport_rect().size
var rng = RandomNumberGenerator.new()
var chicken_speed = 200
var current_direction = Vector2(0,0)
func _ready():
	rng.randomize()
	
	# initialize a random direction to start movement in that direction
	var random_direction2 = rng.randf_range(0, 2 * PI)
	current_direction.x = cos(random_direction2)
	current_direction.y = sin(random_direction2)
	$ChangeDirTimer.wait_time += rng.randf_range(-0.5, 0.5)
	# intitialize random direction to turn to
	_on_ChangeDirTimer_timeout()
	chickenColorize()

func chickenColorize():
	
	var random_brighten_percent = rng.randf_range(0.3,0.5)
# apply color randomness
	$AnimatedSprite.modulate = $AnimatedSprite.modulate.blend(Color(1.0,1.0,1.0,random_brighten_percent))
	
func _process(delta):
	
	# slowly change directions to the new direction
	current_direction = lerp(current_direction, direction, 0.01)
	# apply the direction
	position += delta * current_direction * chicken_speed 
	screenWrap()
	# point the chicken in the right direction
	$AnimatedSprite.flip_h = (current_direction.dot(Vector2(1,0)) > 0)
	z_index = position.y

func _on_ChangeDirTimer_timeout():
	# generate a new random direction to head
	var random_direction = rng.randf_range(0, 2 * PI)
	direction.x = cos(random_direction)
	direction.y = sin(random_direction)
	# start a time till change the direction again
	$ChangeDirTimer.start()

func screenWrap():
	if (position.x > screen_size.x):
		position.x = 0
	if position.x < 0:
		position.x = screen_size.x
	if position.y > screen_size.y:
		position.y = 0
	if position.y < 0:
		position.y = screen_size.y
