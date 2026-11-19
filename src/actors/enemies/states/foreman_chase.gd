extends ForemanState
## El capataz camina hacia Cantuña durante un tiempo y luego prepara una embestida.


func enter() -> void:
	_time_left = foreman.chase_duration


func physics_update(delta: float) -> void:
	foreman.move_in_direction(foreman.get_direction_to_target(), foreman.chase_speed, delta)
	_time_left -= delta
	if _time_left <= 0.0:
		transition_requested.emit(WINDUP)
