class_name StateMachine
extends Node
## Máquina de estados finita: sus hijos [State] son los estados posibles.
##
## El actor llama a [method setup] en su [code]_ready[/code] y le delega sus callbacks
## ([method physics_update], [method update], [method handle_input]).

## Se emite después de cambiar de estado.
signal state_changed(state_name: StringName)

## Estado con el que arranca la máquina.
@export var initial_state: State

## Estado activo.
var current_state: State

var _states: Dictionary[StringName, State] = {}


## Registra los estados hijos, les inyecta el [param actor] y entra al estado inicial.
func setup(actor: Node) -> void:
	for child: Node in get_children():
		var state := child as State
		if state == null:
			continue
		state.actor = actor
		_states[StringName(state.name)] = state
		state.transition_requested.connect(transition_to)
	assert(initial_state != null, "StateMachine: falta el estado inicial en '%s'." % get_path())
	current_state = initial_state
	current_state.enter()


## Cambia al estado cuyo nodo se llama [param state_name].
func transition_to(state_name: StringName) -> void:
	var next_state: State = _states.get(state_name)
	if next_state == null:
		push_error("StateMachine: no existe el estado '%s'." % state_name)
		return
	if next_state == current_state:
		return
	current_state.exit()
	current_state = next_state
	current_state.enter()
	state_changed.emit(state_name)


## Devuelve [code]true[/code] si el estado activo se llama [param state_name].
func is_in_state(state_name: StringName) -> bool:
	return current_state != null and StringName(current_state.name) == state_name


## Delegado de [code]_process[/code].
func update(delta: float) -> void:
	if current_state != null:
		current_state.update(delta)


## Delegado de [code]_physics_process[/code].
func physics_update(delta: float) -> void:
	if current_state != null:
		current_state.physics_update(delta)


## Delegado de [code]_unhandled_input[/code].
func handle_input(event: InputEvent) -> void:
	if current_state != null:
		current_state.handle_input(event)
