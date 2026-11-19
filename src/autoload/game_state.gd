extends Node
## Estado de la partida: banderas de historia y decisiones del jugador.
##
## No accede a nodos de escena ni a la UI, para que pueda probarse de forma aislada con GUT.
## Las banderas que activan los diálogos ([code].tres[/code]) usan estos mismos nombres.

## Se emite cuando cambia el valor de una bandera de historia.
signal flag_changed(flag: StringName, value: bool)

## Cantuña habló con fray Jodoco y aceptó el encargo del atrio.
const MET_FRIAR: StringName = &"met_friar"
## Cantuña aceptó buscar el cincel de don Mateo.
const ACCEPTED_WORKER_QUEST: StringName = &"accepted_worker_quest"
## Cantuña encontró el cincel perdido.
const FOUND_CHISEL: StringName = &"found_chisel"
## Cantuña devolvió el cincel y recibió la honda (mejora inicial en la noche).
const HELPED_WORKER: StringName = &"helped_worker"
## Juanito le contó a Cantuña dónde está la losa floja (escondite marcado en la noche).
const KNOWS_HIDEOUT: StringName = &"knows_hideout"
## Cantuña puso como condición del pacto que no faltara ninguna piedra.
const BARGAINED_PACT: StringName = &"bargained_pact"
## Cantuña escondió la última piedra durante la noche.
const STONE_HIDDEN: StringName = &"stone_hidden"

## Veces que el jugador empezó la noche (sirve para el epílogo y para medir la dificultad).
var night_attempts: int = 0

var _flags: Dictionary[StringName, bool] = {}


## Asigna el valor de una bandera de historia (por ejemplo, [constant BARGAINED_PACT]).
func set_flag(flag: StringName, value: bool = true) -> void:
	if flag.is_empty():
		push_warning("GameState: se intentó asignar una bandera vacía.")
		return
	if _flags.get(flag, false) == value:
		return
	_flags[flag] = value
	flag_changed.emit(flag, value)


## Devuelve [code]true[/code] si la bandera está activa.
func has_flag(flag: StringName) -> bool:
	return _flags.get(flag, false)


## Evalúa una condición escrita como bandera: [code]&"flag"[/code] exige que esté activa,
## [code]&"!flag"[/code] exige que esté inactiva y una condición vacía siempre se cumple.
func meets_condition(condition: StringName) -> bool:
	if condition.is_empty():
		return true
	var text: String = condition
	if text.begins_with("!"):
		return not has_flag(StringName(text.substr(1)))
	return has_flag(condition)


## Registra un nuevo intento de la noche.
func register_night_attempt() -> void:
	night_attempts += 1


## Reinicia el estado para una partida nueva.
func reset() -> void:
	_flags.clear()
	night_attempts = 0
