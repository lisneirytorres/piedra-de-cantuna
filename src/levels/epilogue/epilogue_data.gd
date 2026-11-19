class_name EpilogueData
extends Resource
## Párrafos del epílogo, cada uno con una condición sobre las decisiones del jugador.
##
## Las condiciones usan el formato de [code]GameState.meets_condition[/code]:
## vacía (siempre), [code]flag[/code] (bandera activa) o [code]!flag[/code] (bandera inactiva).

## Texto de cada párrafo.
@export var paragraphs: PackedStringArray = PackedStringArray()
## Condición de cada párrafo; mismo tamaño que [member paragraphs].
@export var conditions: Array[StringName] = []


## Párrafos cuya condición se cumple según [param meets_condition], una función
## [code](condition: StringName) -> bool[/code].
func get_paragraphs(meets_condition: Callable) -> PackedStringArray:
	var result := PackedStringArray()
	for i: int in paragraphs.size():
		var condition: StringName = conditions[i] if i < conditions.size() else &""
		if meets_condition.call(condition):
			result.append(paragraphs[i])
	return result


## [code]true[/code] si cada párrafo tiene su condición.
func is_valid() -> bool:
	return not paragraphs.is_empty() and paragraphs.size() == conditions.size()
