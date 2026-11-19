extends PlayerState
## Impulso corto e invulnerable para esquivar a los diablillos.

var _time_left: float = 0.0
var _direction: Vector2 = Vector2.ZERO


func enter() -> void:
	_direction = player.get_input_direction()
	if _direction == Vector2.ZERO:
		_direction = player.facing
	_time_left = player.stats.dash_duration
	player.set_walking(false)
	player.begin_dash()


func exit() -> void:
	player.end_dash()


func physics_update(delta: float) -> void:
	_time_left -= delta
	player.velocity = _direction * player.stats.dash_speed
	player.move_within_bounds()
	if _time_left <= 0.0:
		transition_requested.emit(MOVE)


func handle_input(_event: InputEvent) -> void:
	# Durante el dash se ignoran las acciones para no encadenar dashes ni interactuar en el aire.
	pass
