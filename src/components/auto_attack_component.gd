class_name AutoAttackComponent
extends Node2D
## Lanza proyectiles automáticamente hacia el enemigo más cercano.
##
## Los proyectiles se crean como hijos con [member Node2D.top_level] activado: viajan por el mundo
## sin seguir al dueño y sin que este componente toque nodos ajenos.

## Escena del proyectil. Su raíz debe ser un [Projectile].
@export var projectile_scene: PackedScene
## Grupo de nodos a los que se apunta.
@export var target_group: StringName = &"enemies"
## Separación angular entre proyectiles cuando se lanzan varios a la vez.
@export var spread_degrees: float = 14.0

## Si es [code]false[/code], no ataca.
var is_active: bool = false
var damage: int = 10
var interval: float = 1.0
var attack_range: float = 140.0
var projectile_count: int = 1
var projectile_speed: float = 220.0

var _time_until_attack: float = 0.0


func _physics_process(delta: float) -> void:
	if not is_active:
		return
	_time_until_attack -= delta
	if _time_until_attack > 0.0:
		return
	var target: Node2D = _find_nearest_target()
	if target == null:
		return
	_fire_at(target)
	_time_until_attack = interval


## Copia los valores de ataque de [param stats].
func configure(stats: PlayerStats) -> void:
	damage = stats.attack_damage
	interval = stats.attack_interval
	attack_range = stats.attack_range
	projectile_count = stats.projectile_count
	projectile_speed = stats.projectile_speed


func _find_nearest_target() -> Node2D:
	var nearest: Node2D = null
	var nearest_distance: float = attack_range
	for node: Node in get_tree().get_nodes_in_group(target_group):
		var candidate := node as Node2D
		if candidate == null:
			continue
		var distance: float = global_position.distance_to(candidate.global_position)
		if distance <= nearest_distance:
			nearest = candidate
			nearest_distance = distance
	return nearest


func _fire_at(target: Node2D) -> void:
	if projectile_scene == null:
		push_error("AutoAttackComponent: falta la escena del proyectil.")
		return
	var base_direction: Vector2 = global_position.direction_to(target.global_position)
	var center: float = (projectile_count - 1) * 0.5
	for i: int in projectile_count:
		var angle: float = deg_to_rad((i - center) * spread_degrees)
		_spawn_projectile(base_direction.rotated(angle))


func _spawn_projectile(direction: Vector2) -> void:
	var projectile := projectile_scene.instantiate() as Projectile
	if projectile == null:
		push_error("AutoAttackComponent: la escena del proyectil no es un Projectile.")
		return
	projectile.top_level = true
	add_child(projectile)
	projectile.launch(global_position, direction, damage, projectile_speed)
