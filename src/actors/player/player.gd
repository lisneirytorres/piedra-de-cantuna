class_name Player
extends CharacterBody2D
## Cantuña, el personaje que controla el jugador.
##
## Delega el movimiento a su [StateMachine] y la interacción, la vida y el ataque a sus componentes.
## El nivel le inyecta los límites del mapa con [method set_bounds].

## La vida llegó a cero.
signal died
## Cambió la vida (para el HUD).
signal health_changed(current: int, maximum: int)
## Cambió la recarga del dash, de 0 (recién usado) a 1 (listo).
signal dash_charge_changed(ratio: float)

## Formato del aviso de interacción que aparece sobre el jugador.
const PROMPT_FORMAT: String = "[E] %s"
const STATE_IDLE: StringName = &"Idle"
const STATE_LOCKED: StringName = &"Locked"

## Estadísticas base (se usa una copia).
@export var stats: PlayerStats
## Activa la vida y el ataque automático (solo en la noche).
@export var is_combat_enabled: bool = false

## [code]true[/code] mientras carga una piedra: va más lento y no puede hacer dash.
var is_carrying: bool = false
## Última dirección en la que se movió.
var facing: Vector2 = Vector2.DOWN

var _bounds: Rect2 = Rect2()
var _dash_cooldown_left: float = 0.0
var _open_dialogues: int = 0

@onready var _state_machine: StateMachine = $StateMachine
@onready var _figure: PixelFigure = $Figure
@onready var _interaction_area: Area2D = $InteractionArea
@onready var _prompt_label: Label = $PromptLabel
@onready var _hurtbox: HurtboxComponent = $HurtboxComponent
@onready var _health: HealthComponent = $HealthComponent
@onready var _auto_attack: AutoAttackComponent = $AutoAttackComponent
@onready var _camera: Camera2D = $Camera2D


func _ready() -> void:
	assert(stats != null, "Player: faltan las estadísticas.")
	stats = stats.duplicate() as PlayerStats
	_state_machine.setup(self)
	_setup_combat()
	Events.dialogue_started.connect(_on_events_dialogue_started)
	Events.dialogue_finished.connect(_on_events_dialogue_finished)


func _physics_process(delta: float) -> void:
	_state_machine.physics_update(delta)
	_update_dash_cooldown(delta)
	_update_prompt()


func _unhandled_input(event: InputEvent) -> void:
	_state_machine.handle_input(event)


## Fija los límites del mapa: el jugador no sale de [param bounds] y la cámara tampoco.
func set_bounds(bounds: Rect2) -> void:
	_bounds = bounds
	_camera.limit_left = floori(bounds.position.x)
	_camera.limit_top = 0
	_camera.limit_right = ceili(bounds.end.x)
	_camera.limit_bottom = ceili(bounds.end.y)


## Bloquea o libera el control del jugador (diálogos y escenas).
func set_locked(value: bool) -> void:
	_state_machine.transition_to(STATE_LOCKED if value else STATE_IDLE)


## Activa o desactiva el ataque automático.
func set_combat_active(value: bool) -> void:
	_auto_attack.is_active = value and is_combat_enabled


## Empieza o deja de cargar una piedra.
func set_carrying(value: bool) -> void:
	is_carrying = value
	_figure.is_carrying = value


## Dirección pedida por el jugador, normalizada.
func get_input_direction() -> Vector2:
	return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")


## Velocidad actual, más lenta si carga una piedra.
func get_move_speed() -> float:
	if is_carrying:
		return stats.move_speed * stats.carry_speed_multiplier
	return stats.move_speed


## Mueve al jugador con su [member velocity] sin dejarlo salir de los límites.
func move_within_bounds() -> void:
	move_and_slide()
	if _bounds.has_area():
		global_position = global_position.clamp(_bounds.position, _bounds.end)
	if not is_zero_approx(velocity.x):
		_figure.is_facing_left = velocity.x < 0.0


## Activa la animación de caminar.
func set_walking(value: bool) -> void:
	_figure.is_walking = value


## [code]true[/code] si el dash está disponible.
func can_dash() -> bool:
	return not is_carrying and _dash_cooldown_left <= 0.0


## Empieza un dash: invulnerable y con la recarga en marcha.
func begin_dash() -> void:
	_dash_cooldown_left = stats.dash_cooldown
	_hurtbox.set_ignoring_hits(true)


## Termina el dash.
func end_dash() -> void:
	_hurtbox.set_ignoring_hits(false)


## Interactúa con el objeto más cercano. Devuelve [code]true[/code] si había uno.
func try_interact() -> bool:
	var interactable: InteractableComponent = _find_nearest_interactable()
	if interactable == null:
		return false
	interactable.interact(self)
	return true


## Aplica una mejora elegida en la noche.
func apply_upgrade(upgrade: UpgradeData) -> void:
	stats.apply_upgrade(upgrade)
	_auto_attack.configure(stats)
	if upgrade.stat == UpgradeData.Stat.MAX_HEALTH:
		_health.increase_max(roundi(upgrade.amount))


## Vida actual.
func get_current_health() -> int:
	return _health.current_health


## Vida máxima.
func get_max_health() -> int:
	return _health.max_health


func _setup_combat() -> void:
	_hurtbox.monitoring = is_combat_enabled
	_health.max_health = stats.max_health
	_health.reset()
	_auto_attack.configure(stats)
	_health.health_changed.connect(_on_health_health_changed)
	_health.died.connect(_on_health_died)
	_hurtbox.hurt.connect(_on_hurtbox_hurt)


func _update_dash_cooldown(delta: float) -> void:
	if _dash_cooldown_left <= 0.0:
		return
	_dash_cooldown_left = maxf(_dash_cooldown_left - delta, 0.0)
	dash_charge_changed.emit(1.0 - _dash_cooldown_left / stats.dash_cooldown)


func _update_prompt() -> void:
	var interactable: InteractableComponent = null
	if not _state_machine.is_in_state(STATE_LOCKED):
		interactable = _find_nearest_interactable()
	_prompt_label.visible = interactable != null
	if interactable != null:
		_prompt_label.text = PROMPT_FORMAT % interactable.prompt_text


func _find_nearest_interactable() -> InteractableComponent:
	var nearest: InteractableComponent = null
	var nearest_distance: float = INF
	for area: Area2D in _interaction_area.get_overlapping_areas():
		var interactable := area as InteractableComponent
		if interactable == null or not interactable.is_enabled:
			continue
		var distance: float = global_position.distance_squared_to(interactable.global_position)
		if distance < nearest_distance:
			nearest = interactable
			nearest_distance = distance
	return nearest


func _on_events_dialogue_started(_dialogue: DialogueData) -> void:
	_open_dialogues += 1
	set_locked(true)


func _on_events_dialogue_finished(_dialogue: DialogueData, _choice_index: int) -> void:
	# Un diálogo puede encadenar otro en la misma señal: solo se libera si no queda ninguno abierto.
	_open_dialogues = maxi(_open_dialogues - 1, 0)
	if _open_dialogues == 0 and not _health.is_dead:
		set_locked(false)


func _on_health_health_changed(current: int, maximum: int) -> void:
	health_changed.emit(current, maximum)


func _on_health_died() -> void:
	set_combat_active(false)
	set_locked(true)
	died.emit()


func _on_hurtbox_hurt(amount: int) -> void:
	_health.damage(amount)
	_figure.flash()
