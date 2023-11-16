extends RigidBody2D
var reset = false
var spawn = Vector2(1720, 238)
var wip = false

# Called when the node enters the scene tree for the first time.
func _integrate_forces(state):
	if reset == true:
		reset = false
		wip = true
		state.linear_velocity = Vector2(0, 0)
		state.angular_velocity = 0
		
	elif wip:
		wip = false
		state.transform = state.transform.translated(-state.transform.get_origin())
		state.transform = state.transform.rotated_local(-rotation)
		state.transform = state.transform.rotated_local(deg_to_rad(-127))
		state.transform = state.transform.translated(spawn)
		

