extends ForemanState
## El capataz embiste en línea recta hacia donde estaba Cantuña al empezar.

var _direction: Vector2 = Vector2.ZERO


func enter() -> void:
	_time_left = foreman.charge_duration
	_direction = foreman.get_direction_to_target()


func physics_update(delta: float) -> void:
	foreman.move_in_direction(_direction, foreman.charge_speed, delta)
	_time_left -= delta
	if _time_left <= 0.0:
		transition_requested.emit(CHASE)
