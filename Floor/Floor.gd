extends Node2D

export var id : int = 0

export var waiting_queues = {
	0: [],
	1: [],
	2: [],
	3: [],
	4: []
}

var elevator_is_on_floor : bool = false
var locked : bool = false

const PROCESSING_DELAY_IN_SECONDS : float = 0.5

# emitted signals
signal elevator_called(id)
signal elevator_arrived_on_floor
signal elevator_left_floor
signal walker_tried_to_enter_elevator(walker)

func _process(_delta):
	if locked:
		return
		
	locked = true
	var timer = get_tree().create_timer(PROCESSING_DELAY_IN_SECONDS)
	timer.connect("timeout", self, "_on_timer_timeout")
		
	if not elevator_is_on_floor:
		return
		
	var walker = waiting_queues[id].pop_front()
	if walker:
		print("trying to enter elevator: ",walker)
		emit_signal("walker_tried_to_enter_elevator", walker)
	
# signal handling
func _on_ElevatorGate_elevator_button_pressed():
	emit_signal("elevator_called", id)

func _on_Walker_entered_waiting_queue(walker: Walker):
	waiting_queues[id].append(walker)
	emit_signal("elevator_called", id)

func _on_Elevator_arrived(floor_id):
	if floor_id != id:
		return
		
	elevator_is_on_floor = true
	emit_signal("elevator_arrived_on_floor")
	
func _on_Elevator_left(floor_id):
	if floor_id != id:
		return
		
	elevator_is_on_floor = false
	emit_signal("elevator_left_floor")
	
func _on_Walker_failed_entering_elevator(walker: Walker, floor_id):
	if floor_id != id:
		return
		
	print("returning to queue: ",walker)
	waiting_queues[id].insert(0, walker)
	
func _on_timer_timeout():
	locked = false
