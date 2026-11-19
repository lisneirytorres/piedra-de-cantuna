extends ForemanState
## El capataz se detiene y brilla en rojo: avisa al jugador que va a embestir.


func enter() -> void:
	_time_left = foreman.windup_duration
	foreman.set_telegraphing(true)


func exit() -> void:
	foreman.set_telegraphing(false)


func physics_update(delta: float) -> void:
	_time_left -= delta
	if _time_left <= 0.0:
		transition_requested.emit(CHARGE)
