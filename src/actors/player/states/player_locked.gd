extends PlayerState
## El jugador no tiene el control (diálogos, escenas o derrota).


func enter() -> void:
	player.velocity = Vector2.ZERO
	player.set_walking(false)


func handle_input(_event: InputEvent) -> void:
	pass
