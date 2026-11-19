class_name EnemySpawner
extends Node2D
## Genera diablillos alrededor del jugador, cada vez más rápido según la dificultad.
##
## El nivel le inyecta el objetivo, los límites y la configuración; el spawner avisa con
## [signal enemy_killed] para que el nivel suelte la experiencia.

## Un diablillo murió en [param at_position] y suelta [param xp_value] de experiencia.
signal enemy_killed(at_position: Vector2, xp_value: int)

@export var imp_scene: PackedScene

## Balance de la noche.
var config: NightConfig
## Nodo que persiguen los diablillos.
var target: Node2D
## Límites del mapa donde pueden aparecer.
var bounds: Rect2 = Rect2()
## Dificultad actual, de 0 a 1.
var difficulty: float = 0.0
## Si es [code]false[/code], no aparecen diablillos nuevos.
var is_active: bool = false

var _time_until_spawn: float = 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()


func _physics_process(delta: float) -> void:
	if not is_active or target == null or config == null:
		return
	_time_until_spawn -= delta
	if _time_until_spawn > 0.0:
		return
	_time_until_spawn = config.get_spawn_interval(difficulty)
	if get_child_count() < config.max_enemies:
		_spawn_imp()


## Elimina a todos los diablillos (al amanecer o al reintentar).
func clear_enemies() -> void:
	for child: Node in get_children():
		child.queue_free()


func _spawn_imp() -> void:
	var imp := imp_scene.instantiate() as Imp
	if imp == null:
		push_error("EnemySpawner: la escena de diablillo no es un Imp.")
		return
	add_child(imp)
	imp.global_position = _pick_spawn_position()
	imp.setup(
		target,
		config.get_imp_health(difficulty),
		config.get_imp_speed(difficulty),
		config.imp_damage
	)
	imp.died.connect(_on_imp_died)


func _pick_spawn_position() -> Vector2:
	var angle: float = _rng.randf() * TAU
	var spawn_position: Vector2 = (
		target.global_position + Vector2.from_angle(angle) * config.spawn_distance
	)
	if bounds.has_area():
		spawn_position = spawn_position.clamp(bounds.position, bounds.end)
	return spawn_position


func _on_imp_died(imp: Imp) -> void:
	enemy_killed.emit(imp.global_position, imp.xp_value)
