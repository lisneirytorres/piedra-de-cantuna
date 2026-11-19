class_name DialogueData
extends Resource
## Una conversación: líneas con su hablante y, opcionalmente, decisiones al final.
##
## Las decisiones activan banderas en [code]GameState[/code] para que tengan consecuencias visibles.
## Cada conversación se guarda en [code]src/data/dialogue/<acto>_<personaje>_<tema>.tres[/code].

## Valor de la decisión cuando la conversación no tenía decisiones.
const NO_CHOICE: int = -1

## Identificador único (coincide con el nombre del archivo).
@export var id: StringName = &""
## Hablante de cada línea; debe tener el mismo tamaño que [member lines].
## Un hablante vacío indica la voz del narrador.
@export var speakers: PackedStringArray = PackedStringArray()
## Texto de cada línea (máximo unos dos renglones).
@export var lines: PackedStringArray = PackedStringArray()
## Textos de las decisiones que se muestran tras la última línea.
@export var choices: PackedStringArray = PackedStringArray()
## Bandera que activa cada decisión (vacía si no activa ninguna). Mismo tamaño que [member choices].
@export var choice_flags: Array[StringName] = []
## Bandera que se activa al terminar la conversación, haya o no decisión.
@export var finish_flag: StringName = &""


## Cantidad de líneas.
func get_line_count() -> int:
	return lines.size()


## Hablante de la línea [param index], o vacío si es el narrador o el índice no existe.
func get_speaker(index: int) -> String:
	if index < 0 or index >= speakers.size():
		return ""
	return speakers[index]


## Texto de la línea [param index], o vacío si el índice no existe.
func get_line(index: int) -> String:
	if index < 0 or index >= lines.size():
		return ""
	return lines[index]


## [code]true[/code] si la conversación termina con una decisión.
func has_choices() -> bool:
	return not choices.is_empty()


## Bandera que activa la decisión [param choice_index], o vacía si no activa ninguna.
func get_choice_flag(choice_index: int) -> StringName:
	if choice_index < 0 or choice_index >= choice_flags.size():
		return &""
	return choice_flags[choice_index]


## Todas las banderas que se deben activar al terminar con la decisión [param choice_index].
func get_flags_to_set(choice_index: int) -> Array[StringName]:
	var flags: Array[StringName] = []
	var choice_flag: StringName = get_choice_flag(choice_index)
	if not choice_flag.is_empty():
		flags.append(choice_flag)
	if not finish_flag.is_empty():
		flags.append(finish_flag)
	return flags


## [code]true[/code] si los datos son coherentes (sirve para validar los [code].tres[/code] en
## pruebas).
func is_valid() -> bool:
	if lines.is_empty() or speakers.size() != lines.size():
		return false
	return choice_flags.is_empty() or choice_flags.size() == choices.size()
