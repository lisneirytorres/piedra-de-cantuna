extends Node
## Estado de la partida: banderas de historia y decisiones del jugador.
##
## No accede a nodos de escena ni a la UI, para que pueda probarse de forma aislada con GUT.

## Se emite cuando cambia el valor de una bandera de historia.
signal flag_changed(flag: StringName, value: bool)

var _flags: Dictionary[StringName, bool] = {}


## Asigna el valor de una bandera de historia (por ejemplo, [code]&"accepted_pact"[/code]).
func set_flag(flag: StringName, value: bool = true) -> void:
	if _flags.get(flag, false) == value:
		return
	_flags[flag] = value
	flag_changed.emit(flag, value)


## Devuelve [code]true[/code] si la bandera está activa.
func has_flag(flag: StringName) -> bool:
	return _flags.get(flag, false)


## Reinicia el estado para una partida nueva.
func reset() -> void:
	_flags.clear()
