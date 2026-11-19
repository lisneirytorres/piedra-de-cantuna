extends Node
## Bus de señales globales.
##
## Comunica sistemas distantes que no se conocen entre sí (por ejemplo, un NPC con la caja de
## diálogo).
## No guarda estado ni contiene lógica: solo declara señales.
## Dentro de una misma escena usa señales locales, no este bus.

## Un actor pide mostrar una conversación. La atiende la caja de diálogo del nivel.
@warning_ignore("unused_signal")
signal dialogue_requested(dialogue: DialogueData)

## La caja de diálogo empezó a mostrar una conversación.
@warning_ignore("unused_signal")
signal dialogue_started(dialogue: DialogueData)

## La conversación terminó. [param choice_index] es la decisión tomada o
## [constant DialogueData.NO_CHOICE] si no había decisiones.
@warning_ignore("unused_signal")
signal dialogue_finished(dialogue: DialogueData, choice_index: int)
