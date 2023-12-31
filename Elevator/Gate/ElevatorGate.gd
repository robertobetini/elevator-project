extends KinematicBody2D

# states
const CLOSED : int = 0
const OPEN : int = 1

var state : int = CLOSED

signal elevator_button_pressed
	
func _on_Area2D_body_entered(_body):
	state = CLOSED
	emit_signal("elevator_button_pressed")
		
func _on_Floor_elevator_arrived_on_floor():
	state = OPEN
	visible = false

func _on_Floor_elevator_called(_id):
	state = CLOSED

func _on_Floor_elevator_left_floor():
	state = CLOSED
	visible = true
