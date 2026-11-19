extends Level
## Acto 1: la plaza de San Francisco.
##
## Fray Jodoco encarga el atrio a Cantuña con un plazo (tutorial de movimiento y conversación).
## Decisiones opcionales: ayudar a don Mateo con su cincel ([code]helped_worker[/code]) y escuchar a
## Juanito ([code]knows_hideout[/code]). Ambas cambian la noche y el epílogo.

## Índice de la decisión "Cuéntame qué has visto" en [member child_rumor].
const CHOICE_LISTEN_CHILD: int = 0

@export_file("*.tscn") var next_scene: String

@export_group("Personajes")
@export var friar: Npc
@export var worker: Npc
@export var child: Npc
@export var chisel: Prop
@export var exit_zone: Area2D

@export_group("Diálogos")
@export var friar_commission: DialogueData
@export var friar_repeat: DialogueData
@export var worker_request: DialogueData
@export var worker_waiting: DialogueData
@export var worker_thanks: DialogueData
@export var worker_after: DialogueData
@export var worker_refused: DialogueData
@export var child_rumor: DialogueData
@export var child_secret: DialogueData
@export var child_dismissed: DialogueData
@export var child_after: DialogueData
@export var exit_locked: DialogueData

@export_group("Textos")
@export var objective_find_friar: String = ""
@export var objective_go_to_site: String = ""
@export var chisel_found_message: String = ""

var _dialogue_handlers: Dictionary[DialogueData, Callable] = {}


func _ready() -> void:
	super()
	hud.set_objective(objective_find_friar)
	chisel.set_active(false)
	chisel.used.connect(_on_chisel_used)
	exit_zone.body_entered.connect(_on_exit_zone_body_entered)
	_dialogue_handlers = {
		friar_commission: _on_friar_commission_finished,
		worker_request: _on_worker_request_finished,
		worker_thanks: _on_worker_thanks_finished,
		child_rumor: _on_child_rumor_finished,
	}


func _on_dialogue_finished(dialogue: DialogueData, choice_index: int) -> void:
	var handler: Callable = _dialogue_handlers.get(dialogue, Callable())
	if handler.is_valid():
		handler.call(choice_index)


func _on_friar_commission_finished(_choice_index: int) -> void:
	friar.set_dialogue(friar_repeat)
	hud.set_objective(objective_go_to_site)


func _on_worker_request_finished(_choice_index: int) -> void:
	if GameState.has_flag(GameState.ACCEPTED_WORKER_QUEST):
		worker.set_dialogue(worker_waiting)
		chisel.set_active(true)
	else:
		worker.set_dialogue(worker_refused)


func _on_worker_thanks_finished(_choice_index: int) -> void:
	worker.set_dialogue(worker_after)


func _on_child_rumor_finished(choice_index: int) -> void:
	# La bandera knows_hideout la activa child_secret al terminar, para que el jugador oiga el
	# secreto.
	child.set_dialogue(child_after)
	play_dialogue(child_secret if choice_index == CHOICE_LISTEN_CHILD else child_dismissed)


func _on_chisel_used(_prop: Prop) -> void:
	chisel.set_active(false)
	GameState.set_flag(GameState.FOUND_CHISEL)
	worker.set_dialogue(worker_thanks)
	hud.show_message(chisel_found_message)


func _on_exit_zone_body_entered(body: Node2D) -> void:
	if body != player:
		return
	if GameState.has_flag(GameState.MET_FRIAR):
		SceneManager.change_scene(next_scene)
	else:
		play_dialogue(exit_locked)
