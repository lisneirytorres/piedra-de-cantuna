class_name CreditsData
extends Resource
## Texto de los créditos finales.
##
## Las líneas que empiezan con [constant HEADING_PREFIX] se muestran como títulos de sección.
## Debe mantenerse sincronizado con [code]CREDITS.md[/code], que es el registro de licencias.

const HEADING_PREFIX: String = "# "

@export var lines: PackedStringArray = PackedStringArray()


## [code]true[/code] si la línea [param line] es un título de sección.
static func is_heading(line: String) -> bool:
	return line.begins_with(HEADING_PREFIX)


## Texto visible de la línea, sin el prefijo de título.
static func strip_heading(line: String) -> String:
	return line.trim_prefix(HEADING_PREFIX)
