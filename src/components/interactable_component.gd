class_name InteractableComponent
extends Area2D
## Zona con la que el jugador puede interactuar (hablar, recoger, colocar).
##
## No sabe qué pasa al interactuar: solo emite [signal interacted] para que su dueño decida.

## El jugador interactuó con este objeto.
signal interacted(by: Node2D)

## Verbo que se muestra al jugador, por ejemplo "Hablar" o "Recoger".
@export var prompt_text: String = "Hablar"
## Si es [code]false[/code], el jugador no puede interactuar ni ve el aviso.
@export var is_enabled: bool = true


## Ejecuta la interacción. No hace nada si el componente está desactivado.
func interact(by: Node2D) -> void:
	if not is_enabled:
		return
	interacted.emit(by)
