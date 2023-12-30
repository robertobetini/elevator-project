extends AutonomousAgent

# states
const STOPPED = 0
const MOVING = 1
const BUSY = 2

# emmited signals
signal elevator_arrived(floor_id)
signal elevator_left(floor_id)
signal walker_failed_entering_elevator(walker)
signal walker_exited_elevator(walker)

export var CAPACITY = 1

var state = STOPPED

var current_floor = 0
var next_floor = 0

var locked = false
var dispatching = false

const BUSY_TIME_IN_SECONDS = 2
const COLOR_ALPHA_INSIDE_ELEVATOR = 0.5

const queue = []
const elevator_slots = []
var elevator_waypoints = []
var last_waypoint = position

func _ready():
	var building_node : Node2D = get_parent().get_node("Building")
	
	for child in building_node.get_children():
		# setup signal connections
		child.connect("elevator_called", self, "_on_Elevator_called")
		child.connect("walker_tried_to_enter_elevator", self, "_on_Walker_tried_to_enter_elevator")
		self.connect("elevator_arrived", child, "_on_Elevator_arrived")
		self.connect("elevator_left", child, "_on_Elevator_left")
		self.connect("walker_failed_entering_elevator", child, "_on_Walker_failed_entering_elevator")
		
		# setup waypoints
		var waypoint = child.get_node("ElevatorWaypoint").global_position
		elevator_waypoints.append(waypoint)
		
	# setup slots
	var slots = get_node("Slots")
	if  CAPACITY > len(slots.get_children()):
		print("[WARNING] Elevator capacity higher than the number of available slots.")
	
	var i = 0
	for child in slots.get_children():
		if i >= CAPACITY:
			break
			
		elevator_slots.append({
			"occupier": null,
			"reference": child
		})
		
		i += 1

func _process(delta):
#	print(state, " ", current_floor, " ", next_floor," ", queue)
	update_occupiers_position()
	
	if locked:
		return
		
	if len(queue) < 1 and current_floor == next_floor and state != BUSY:
		state = STOPPED
		return
	
	if state == BUSY:
		locked = true
		dispatching = true
		dispatch_slots()
		var timer = get_tree().create_timer(BUSY_TIME_IN_SECONDS)
		timer.connect("timeout", self, "_on_closing_elevator")
		
	elif state == STOPPED:
		if current_floor == next_floor:
			next_floor = queue[0]

		state = MOVING
		
	elif state == MOVING:
		move_to_next_floor(delta)
		
func update_occupiers_position():
	for slot in elevator_slots:
		if slot.occupier:
			slot.occupier.global_position = slot.reference.global_position
	
func move_to_next_floor(delta):
	if abs(position.y - elevator_waypoints[next_floor].y) < 2:
		current_floor = next_floor
		state = BUSY
		emit_signal("elevator_arrived", current_floor)
		last_waypoint = elevator_waypoints[next_floor]
		return
		
	var force = arrive(last_waypoint, elevator_waypoints[next_floor])
	force.x = 0
	
	apply_force(force)
	update()
	move_and_slide(velocity, Vector2.UP)
		
func add_floor_to_queue(floor_id: int):
	if not floor_id in queue:
		queue.append(floor_id)
		
func dispatch_slots():
	for slot in elevator_slots:
		if not slot.occupier:
			continue
			
		if current_floor == slot.occupier.desired_floor:
			slot.occupier.global_position.x += 200
			emit_signal("walker_exited_elevator", slot.occupier)
#			slot.occupier.queue_free()
			slot.occupier = null
			
	dispatching = false

# signal handling
func _on_Elevator_called(id: int):
	add_floor_to_queue(id)
	
func _on_closing_elevator():
	queue.pop_front()
	emit_signal("elevator_left", current_floor)
	state = STOPPED
	locked = false
	
func _on_Walker_tried_to_enter_elevator(walker: Walker):
	for slot in elevator_slots:
		if slot.occupier:
			continue
			
		self.connect("walker_exited_elevator", walker, "_on_Walker_exited_elevator")
		
		slot.occupier = walker
		print("entering elevator: ", walker)
		walker.get_node("CollisionShape2D").disabled = true
		walker.set_color_alpha(COLOR_ALPHA_INSIDE_ELEVATOR)
		add_floor_to_queue(walker.desired_floor)
		return
			
	emit_signal("walker_failed_entering_elevator", walker, current_floor)
