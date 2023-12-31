class_name AutonomousAgent extends KinematicBody2D

export(float) var max_speed = 5
export(float) var max_force = 2
export(float) var arrival_radius_squared = 500

var velocity : Vector2 = Vector2.ZERO
var acceleration : Vector2 = Vector2.ZERO

# STEERING = DESIRED VELOCITY - CURRENT VELOCITY

func seek(target: Vector2) -> Vector2:
	var desired : Vector2 = target - position
	desired = desired.limit_length(max_speed)
	
	var steering = desired - velocity
	return steering.limit_length(max_force)

func arrive(origin: Vector2, target: Vector2) -> Vector2:
	var distance_to_target_squared = position.distance_squared_to(target)
	var distance_to_origin_squared = position.distance_squared_to(origin)
	
	if distance_to_target_squared < arrival_radius_squared or distance_to_origin_squared < arrival_radius_squared:
		var steering : Vector2 = seek(target) * (distance_to_origin_squared + 0.0001 / arrival_radius_squared)
		return steering.limit_length(max_force)

	return seek(target)

func apply_force(force: Vector2):
	acceleration += force
	acceleration = acceleration.limit_length(max_force)
	
func update():
	velocity += acceleration
	velocity *= 0.99 # Add some "friction" to smooth elevator movement
	velocity = velocity.limit_length(max_speed)
	acceleration = Vector2.ZERO
