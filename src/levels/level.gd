class_name Level
extends Node2D
## Base de los actos: conecta al jugador con los límites del mapa, el HUD y los diálogos.
##
## Cada acto hereda de esta clase y sobrescribe [method _on_dialogue_finished] para reaccionar a
## las conversaciones. Las subclases que sobrescriben [code]_ready[/code] deben llamar a
## [code]super()[/code].

## Zona transitable del mapa.
@export var bounds: Rect2 = Rect2(16, 140, 928, 384)
@export var player: Player
@export var hud: Hud
@export var music: AudioStream
## Conversación que se reproduce al entrar al nivel (opcional).
@export var intro_dialogue: DialogueData


func _ready() -> void:
	assert(player != null and hud != null, "Level: faltan el jugador o el HUD en '%s'." % name)
	player.set_bounds(bounds)
	Events.dialogue_finished.connect(_on_dialogue_finished)
	if music != null:
		AudioManager.play_music(music)
	if intro_dialogue != null:
		play_dialogue.call_deferred(intro_dialogue)


## Pide mostrar [param dialogue] en la caja de diálogo del nivel.
func play_dialogue(dialogue: DialogueData) -> void:
	if dialogue == null:
		push_error("Level: se pidió un diálogo nulo en '%s'." % name)
		return
	Events.dialogue_requested.emit(dialogue)


## Reacción a cada conversación terminada. Las subclases la sobrescriben.
func _on_dialogue_finished(_dialogue: DialogueData, _choice_index: int) -> void:
	pass
