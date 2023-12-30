class_name Walker extends AutonomousAgent

# states
const WALKING_TO_ELEVATOR = 0
const WAITING_FOR_ELEVATOR = 1
const INSIDE_ELEVATOR = 2
const LEAVING_BUILDING = 3

# signals
signal entered_waiting_queue

const SPEED = 20000
const LEFT = -1
const RIGHT = 1

var alpha = 0.9

var state = WALKING_TO_ELEVATOR
var spawn_floor
var desired_floor

func _ready():
	pass

func _process(delta):
	var velocity = Vector2(LEFT, 100)
	
#	print(state)
	if is_on_wall() and state != WAITING_FOR_ELEVATOR and state != LEAVING_BUILDING:
		emit_signal("entered_waiting_queue")
		state = WAITING_FOR_ELEVATOR
		
	if state == WALKING_TO_ELEVATOR:
		velocity = Vector2(SPEED * LEFT * delta, 100)
	elif state == WAITING_FOR_ELEVATOR:
		if not is_on_wall():
			velocity = Vector2(SPEED * LEFT * delta, 100)
	elif state == INSIDE_ELEVATOR:
		pass
	elif state == LEAVING_BUILDING:
		velocity = Vector2(SPEED * RIGHT * delta, 0)
		
	if position.x > 2300:
		queue_free()
		
# warning-ignore:return_value_discarded
	move_and_slide(velocity, Vector2.UP)

func set_random_desired_floor():
	desired_floor = randi() % 5
	while spawn_floor == desired_floor:
		desired_floor = randi() % 5
		
func set_random_color():
	var r = randf() + 0.4
	var g = randf() + 0.4
	var b = randf() + 0.4
	
	set_color(Color(r, g, b, alpha))
	
func set_color(color: Color):
	set_modulate(color)
	
func set_color_alpha(value):
	var color = get_modulate()
	color.a = value
	set_color(color)
	
func _on_Walker_exited_elevator(walker: Walker):
	walker.state = LEAVING_BUILDING
	walker.z_index = -1
	set_color_alpha(alpha)
