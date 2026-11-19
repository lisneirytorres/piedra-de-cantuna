@abstract class_name State
extends Node
## Estado base de una [StateMachine].
##
## Cada estado concreto sobrescribe solo los métodos que necesita. Para cambiar de estado,
## emite [signal transition_requested] con el nombre del nodo destino: el estado no conoce a la
## máquina.

## Pide a la máquina de estados que cambie al estado [param next_state].
signal transition_requested(next_state: StringName)

## Actor que controla este estado. Lo inyecta la [StateMachine] en [method StateMachine.setup].
var actor: Node


## Se llama al entrar en el estado.
func enter() -> void:
	pass


## Se llama al salir del estado.
func exit() -> void:
	pass


## Se llama cada cuadro desde [code]_process[/code] del actor.
func update(_delta: float) -> void:
	pass


## Se llama cada cuadro de física desde [code]_physics_process[/code] del actor.
func physics_update(_delta: float) -> void:
	pass


## Se llama con cada entrada no consumida por la interfaz.
func handle_input(_event: InputEvent) -> void:
	pass
