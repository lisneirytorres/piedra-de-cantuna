class_name ForemanState
extends State
## Estado base del capataz: da acceso tipado a [Foreman].

const CHASE: StringName = &"Chase"
const WINDUP: StringName = &"Windup"
const CHARGE: StringName = &"Charge"

## El capataz que controla este estado.
var foreman: Foreman:
	get:
		return actor as Foreman

var _time_left: float = 0.0
