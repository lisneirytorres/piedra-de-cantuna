class_name Npc
extends StaticBody2D
## Personaje con el que Cantuña puede conversar.
##
## Al interactuar, pide al bus [code]Events[/code] mostrar su diálogo actual y avisa con
## [signal talked_to]. El nivel cambia el diálogo según avanza la historia ([method set_dialogue]).

## El jugador habló con este personaje.
signal talked_to(npc: Npc)

## Capa de colisión del mundo (bloquea al jugador mientras el personaje está presente).
const WORLD_LAYER: int = 1

## Nombre visible del personaje.
@export var display_name: String = ""
## Aspecto del personaje.
@export var appearance: FigureAppearance
## Conversación que se muestra al hablarle.
@export var dialogue: DialogueData
## Mira hacia la izquierda.
@export var is_facing_left: bool = false

@onready var _figure: PixelFigure = $Figure
@onready var _interactable: InteractableComponent = $InteractableComponent


func _ready() -> void:
	_figure.appearance = appearance
	_figure.is_facing_left = is_facing_left
	_interactable.interacted.connect(_on_interactable_interacted)


## Cambia la conversación que se muestra al hablarle.
func set_dialogue(new_dialogue: DialogueData) -> void:
	dialogue = new_dialogue


## Muestra u oculta al personaje (y activa o desactiva la conversación).
func set_present(value: bool) -> void:
	visible = value
	_interactable.is_enabled = value
	collision_layer = WORLD_LAYER if value else 0


func _on_interactable_interacted(_by: Node2D) -> void:
	if dialogue == null:
		push_warning("Npc: '%s' no tiene diálogo asignado." % display_name)
		return
	Events.dialogue_requested.emit(dialogue)
	talked_to.emit(self)
