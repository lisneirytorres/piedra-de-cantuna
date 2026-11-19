extends Level
## Acto 2: la obra del atrio.
##
## Puzzle: Cantuña lleva cada piedra al hueco del atrio que tiene su misma forma. Al terminar,
## cae la tarde, aparece el diablo y ofrece el pacto (decisión [code]bargained_pact[/code]).

@export_file("*.tscn") var next_scene: String

@export_group("Escena")
## Contenedor de las piedras sueltas ([Prop] de tipo piedra).
@export var stones_root: Node2D
## Contenedor de los huecos del atrio ([Prop] de tipo hueco).
@export var slots_root: Node2D
@export var devil: Npc
@export var place_sound: SoundEffect

@export_group("Diálogos")
@export var dusk: DialogueData
@export var devil_pact: DialogueData
@export var devil_bargained: DialogueData
@export var devil_plain: DialogueData

@export_group("Textos")
@export var objective_format: String = ""
@export var objective_meet_devil: String = ""
@export var message_need_stone: String = ""
@export var message_already_carrying: String = ""
@export var message_wrong_shape: String = ""
@export var message_stone_placed: String = ""

var _carried_shape: Prop.StoneShape = Prop.StoneShape.SQUARE
var _placed_count: int = 0
var _slot_count: int = 0
var _dialogue_handlers: Dictionary[DialogueData, Callable] = {}


func _ready() -> void:
	super()
	devil.set_present(false)
	_connect_props()
	_update_objective()
	_dialogue_handlers = {
		dusk: _on_dusk_finished,
		devil_pact: _on_devil_pact_finished,
		devil_bargained: _on_devil_reply_finished,
		devil_plain: _on_devil_reply_finished,
	}


func _connect_props() -> void:
	for stone: Node in stones_root.get_children():
		(stone as Prop).used.connect(_on_stone_used)
	for slot: Node in slots_root.get_children():
		(slot as Prop).used.connect(_on_slot_used)
		_slot_count += 1


func _update_objective() -> void:
	hud.set_objective(objective_format % [_placed_count, _slot_count])


func _on_dialogue_finished(dialogue: DialogueData, choice_index: int) -> void:
	var handler: Callable = _dialogue_handlers.get(dialogue, Callable())
	if handler.is_valid():
		handler.call(choice_index)


func _on_stone_used(stone: Prop) -> void:
	if player.is_carrying:
		hud.show_message(message_already_carrying)
		return
	stone.set_active(false)
	_carried_shape = stone.stone_shape
	player.set_carrying(true)


func _on_slot_used(slot: Prop) -> void:
	if not player.is_carrying:
		hud.show_message(message_need_stone)
		return
	if slot.stone_shape != _carried_shape:
		hud.show_message(message_wrong_shape)
		return
	slot.fill()
	AudioManager.play_effect(place_sound)
	player.set_carrying(false)
	_placed_count += 1
	_update_objective()
	if _placed_count >= _slot_count:
		play_dialogue(dusk)
	else:
		hud.show_message(message_stone_placed)


func _on_dusk_finished(_choice_index: int) -> void:
	devil.set_present(true)
	hud.set_objective(objective_meet_devil)
	play_dialogue(devil_pact)


func _on_devil_pact_finished(_choice_index: int) -> void:
	var is_bargained: bool = GameState.has_flag(GameState.BARGAINED_PACT)
	play_dialogue(devil_bargained if is_bargained else devil_plain)


func _on_devil_reply_finished(_choice_index: int) -> void:
	SceneManager.change_scene(next_scene)
