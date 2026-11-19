class_name PlayerState
extends State
## Estado base del jugador: da acceso tipado a [Player] y resuelve las acciones comunes.

const IDLE: StringName = &"Idle"
const MOVE: StringName = &"Move"
const DASH: StringName = &"Dash"
const LOCKED: StringName = &"Locked"

## El jugador que controla este estado.
var player: Player:
	get:
		return actor as Player


## Interactuar y hacer dash, disponibles mientras el jugador tiene el control.
func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"interact"):
		if player.try_interact():
			player.get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"dash") and player.can_dash():
		transition_requested.emit(DASH)
