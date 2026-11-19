extends PlayerState
## Cantuña está quieto.


func enter() -> void:
	player.velocity = Vector2.ZERO
	player.set_walking(false)


func physics_update(_delta: float) -> void:
	if player.get_input_direction() != Vector2.ZERO:
		transition_requested.emit(MOVE)
