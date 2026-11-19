extends Level
## Acto 3: la noche del pacto (la mecánica del prototipo, tipo "survivor").
##
## Fases: aguantar las oleadas mientras la obra avanza, robar la última piedra que custodia el
## capataz,
## esconderla y resistir hasta el amanecer. Si Cantuña cae o amanece sin la piedra escondida, la
## noche
## se reintenta. Las decisiones de los actos anteriores dan una mejora inicial y marcan el
## escondite.

## Fases de la noche.
enum Phase { INTRO, SURVIVE, STEAL, HIDE, WAIT, ENDED }

@export_file("*.tscn") var next_scene: String
@export var config: NightConfig

@export_group("Escena")
@export var clock: NightClock
@export var spawner: EnemySpawner
@export var pickups_root: Node2D
@export var upgrade_menu: UpgradeMenu
@export var last_stone: Prop
@export var true_hideout: Prop
@export var decoy_hideouts: Array[Prop] = []
@export var foreman_scene: PackedScene
@export var gem_scene: PackedScene

@export_group("Mejoras")
@export var upgrades: Array[UpgradeData] = []
## Mejora inicial si Cantuña ayudó a don Mateo (la honda).
@export var sling_upgrade: UpgradeData

@export_group("Diálogos")
@export var intro_plain: DialogueData
@export var stone_ready: DialogueData
@export var stone_taken: DialogueData
@export var wrong_hideout: DialogueData
@export var stone_hidden: DialogueData
@export var devil_dawn: DialogueData
@export var dawn_failed: DialogueData
@export var fallen: DialogueData

@export_group("Textos")
@export var objective_survive: String = ""
@export var objective_steal: String = ""
@export var objective_hide: String = ""
@export var objective_hide_known: String = ""
@export var objective_wait: String = ""
@export var foreman_name: String = ""
@export var sling_message: String = ""

var _phase: Phase = Phase.INTRO
var _experience: ExperienceTracker
var _kills: int = 0
var _pending_upgrades: int = 0
var _foreman: Foreman
var _dialogue_handlers: Dictionary[DialogueData, Callable] = {}
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	if not GameState.has_flag(GameState.BARGAINED_PACT) and intro_plain != null:
		intro_dialogue = intro_plain
	super()
	_rng.randomize()
	GameState.register_night_attempt()
	_experience = ExperienceTracker.new(config.xp_base, config.xp_growth)
	_setup_nodes()
	_connect_signals()
	_apply_previous_choices()
	_refresh_hud()


func _setup_nodes() -> void:
	clock.duration = config.duration
	spawner.config = config
	spawner.target = player
	spawner.bounds = bounds
	last_stone.set_active(false)
	true_hideout.set_active(false)
	for hideout: Prop in decoy_hideouts:
		hideout.set_active(false)


func _connect_signals() -> void:
	Events.dialogue_started.connect(_on_events_dialogue_started)
	clock.time_changed.connect(_on_clock_time_changed)
	clock.dawn_reached.connect(_on_clock_dawn_reached)
	spawner.enemy_killed.connect(_on_spawner_enemy_killed)
	upgrade_menu.upgrade_chosen.connect(_on_upgrade_menu_upgrade_chosen)
	player.health_changed.connect(hud.set_health)
	player.dash_charge_changed.connect(hud.set_dash_charge)
	player.died.connect(_on_player_died)
	last_stone.used.connect(_on_last_stone_used)
	true_hideout.used.connect(_on_hideout_used)
	for hideout: Prop in decoy_hideouts:
		hideout.used.connect(_on_hideout_used)
	_dialogue_handlers = {
		intro_dialogue: _on_intro_finished,
		stone_hidden: _on_stone_hidden_finished,
		devil_dawn: _on_devil_dawn_finished,
		dawn_failed: _on_retry_dialogue_finished,
		fallen: _on_retry_dialogue_finished,
	}


func _apply_previous_choices() -> void:
	if GameState.has_flag(GameState.HELPED_WORKER) and sling_upgrade != null:
		player.apply_upgrade(sling_upgrade)


func _refresh_hud() -> void:
	hud.set_health(player.get_current_health(), player.get_max_health())
	hud.set_progress(_experience.level, _experience.get_progress_ratio(), _kills)
	hud.set_clock(config.duration)
	hud.set_work_progress(0.0)
	hud.set_objective(objective_survive)


func _start_night() -> void:
	_phase = Phase.SURVIVE
	clock.start()
	spawner.is_active = true
	player.set_combat_active(true)
	if GameState.has_flag(GameState.HELPED_WORKER):
		hud.show_message(sling_message)


func _reveal_last_stone() -> void:
	_phase = Phase.STEAL
	last_stone.set_active(true)
	last_stone.is_highlighted = true
	hud.set_objective(objective_steal)
	_spawn_foreman()
	play_dialogue(stone_ready)


func _spawn_foreman() -> void:
	_foreman = foreman_scene.instantiate() as Foreman
	spawner.add_sibling(_foreman)
	_foreman.global_position = last_stone.global_position
	_foreman.setup(player, config.foreman_health, bounds)
	_foreman.health_changed.connect(hud.set_boss_health)
	_foreman.died.connect(_on_foreman_died)
	hud.show_boss(foreman_name)


func _show_hideouts() -> void:
	var knows_hideout: bool = GameState.has_flag(GameState.KNOWS_HIDEOUT)
	true_hideout.set_active(true)
	true_hideout.is_highlighted = knows_hideout
	for hideout: Prop in decoy_hideouts:
		hideout.set_active(not knows_hideout)
	hud.set_objective(objective_hide_known if knows_hideout else objective_hide)


func _end_night() -> void:
	_phase = Phase.ENDED
	clock.stop()
	spawner.is_active = false
	spawner.clear_enemies()
	player.set_combat_active(false)
	if _foreman != null and is_instance_valid(_foreman):
		_foreman.queue_free()
		hud.hide_boss()


func _spawn_gems(at_position: Vector2, xp_value: int) -> void:
	for i: int in xp_value:
		var gem := gem_scene.instantiate() as XpGem
		pickups_root.add_child(gem)
		gem.global_position = (
			at_position + Vector2(_rng.randf_range(-6, 6), _rng.randf_range(-6, 6))
		)
		gem.target = player
		gem.collected.connect(_on_gem_collected)


func _offer_upgrade() -> void:
	if _phase == Phase.ENDED or upgrades.is_empty():
		_pending_upgrades = 0
		return
	var pool: Array[UpgradeData] = upgrades.duplicate()
	pool.shuffle()
	get_tree().paused = true
	upgrade_menu.open(pool.slice(0, mini(config.upgrade_choices, pool.size())))


func _on_dialogue_finished(dialogue: DialogueData, choice_index: int) -> void:
	get_tree().paused = false
	var handler: Callable = _dialogue_handlers.get(dialogue, Callable())
	if handler.is_valid():
		handler.call(choice_index)


func _on_events_dialogue_started(_dialogue: DialogueData) -> void:
	# Durante las conversaciones de la noche, el mundo se congela para no castigar al jugador.
	get_tree().paused = true


func _on_intro_finished(_choice_index: int) -> void:
	_start_night()


func _on_stone_hidden_finished(_choice_index: int) -> void:
	hud.set_objective(objective_wait)


func _on_devil_dawn_finished(_choice_index: int) -> void:
	SceneManager.change_scene(next_scene)


func _on_retry_dialogue_finished(_choice_index: int) -> void:
	SceneManager.reload_current_scene()


func _on_clock_time_changed(elapsed: float, remaining: float, progress: float) -> void:
	hud.set_clock(remaining)
	hud.set_work_progress(config.get_work_progress(progress))
	spawner.difficulty = progress
	if _phase == Phase.SURVIVE and elapsed >= config.stone_appear_time:
		_reveal_last_stone()


func _on_clock_dawn_reached() -> void:
	var is_saved: bool = _phase == Phase.WAIT
	_end_night()
	play_dialogue(devil_dawn if is_saved else dawn_failed)


func _on_spawner_enemy_killed(at_position: Vector2, xp_value: int) -> void:
	_kills += 1
	hud.set_progress(_experience.level, _experience.get_progress_ratio(), _kills)
	_spawn_gems(at_position, xp_value)


func _on_gem_collected(value: int) -> void:
	_pending_upgrades += _experience.add_xp(value)
	hud.set_progress(_experience.level, _experience.get_progress_ratio(), _kills)
	if _pending_upgrades > 0 and not upgrade_menu.is_open():
		_offer_upgrade()


func _on_upgrade_menu_upgrade_chosen(upgrade: UpgradeData) -> void:
	player.apply_upgrade(upgrade)
	_pending_upgrades -= 1
	get_tree().paused = false
	if _pending_upgrades > 0:
		_offer_upgrade.call_deferred()


func _on_foreman_died() -> void:
	hud.hide_boss()
	_spawn_gems(_foreman.global_position, _foreman.xp_value)
	_foreman = null


func _on_last_stone_used(_prop: Prop) -> void:
	if _phase != Phase.STEAL:
		return
	_phase = Phase.HIDE
	last_stone.set_active(false)
	player.set_carrying(true)
	_show_hideouts()
	play_dialogue(stone_taken)


func _on_hideout_used(hideout: Prop) -> void:
	if _phase != Phase.HIDE:
		return
	if hideout != true_hideout:
		hideout.set_active(false)
		play_dialogue(wrong_hideout)
		return
	_phase = Phase.WAIT
	hideout.fill()
	player.set_carrying(false)
	GameState.set_flag(GameState.STONE_HIDDEN)
	play_dialogue(stone_hidden)


func _on_player_died() -> void:
	if _phase == Phase.ENDED:
		return
	_end_night()
	play_dialogue(fallen)
