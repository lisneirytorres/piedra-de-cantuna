extends PlayerState
## Cantuña camina en la dirección que pide el jugador.


func enter() -> void:
	player.set_walking(true)


func physics_update(_delta: float) -> void:
	var direction: Vector2 = player.get_input_direction()
	if direction == Vector2.ZERO:
		transition_requested.emit(IDLE)
		return
	player.facing = direction
	player.velocity = direction * player.get_move_speed()
	player.move_within_bounds()
