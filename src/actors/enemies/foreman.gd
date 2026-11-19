class_name Foreman
extends Node2D
## Capataz de los diablillos: mini-jefe que custodia la última piedra.
##
## Alterna entre perseguir a Cantuña, prepararse (parpadea) y embestir en línea recta.
## Su comportamiento vive en los estados de su [StateMachine].

## El capataz fue derrotado.
signal died
## Cambió su vida (para la barra de jefe del HUD).
signal health_changed(current: int, maximum: int)

@export var chase_speed: float = 34.0
@export var charge_speed: float = 210.0
@export var chase_duration: float = 2.4
@export var windup_duration: float = 0.6
@export var charge_duration: float = 0.55
## Experiencia que suelta al morir.
@export var xp_value: int = 12

## A quién persigue (el jugador).
var target: Node2D
## Límites del mapa que no puede cruzar.
var bounds: Rect2 = Rect2()

@onready var _state_machine: StateMachine = $StateMachine
@onready var _figure: PixelFigure = $Figure
@onready var _health: HealthComponent = $HealthComponent
@onready var _hurtbox: HurtboxComponent = $HurtboxComponent


func _ready() -> void:
	_figure.is_walking = true
	_hurtbox.hurt.connect(_on_hurtbox_hurt)
	_health.health_changed.connect(_on_health_health_changed)
	_health.died.connect(_on_health_died)
	_state_machine.setup(self)


func _physics_process(delta: float) -> void:
	_state_machine.physics_update(delta)


## Configura al capataz al aparecer.
func setup(chase_target: Node2D, max_health: int, map_bounds: Rect2) -> void:
	target = chase_target
	bounds = map_bounds
	_health.max_health = max_health
	_health.reset()


## Dirección hacia el objetivo (cero si no hay objetivo).
func get_direction_to_target() -> Vector2:
	if target == null or not is_instance_valid(target):
		return Vector2.ZERO
	return global_position.direction_to(target.global_position)


## Se mueve en [param direction] sin salir de los límites.
func move_in_direction(direction: Vector2, speed: float, delta: float) -> void:
	global_position += direction * speed * delta
	if bounds.has_area():
		global_position = global_position.clamp(bounds.position, bounds.end)
	if not is_zero_approx(direction.x):
		_figure.is_facing_left = direction.x < 0.0


## Activa o desactiva el aviso visual de que va a embestir.
func set_telegraphing(value: bool) -> void:
	_figure.is_walking = not value
	modulate = Color(1.6, 0.7, 0.7) if value else Color.WHITE


func _on_hurtbox_hurt(amount: int) -> void:
	_health.damage(amount)
	_figure.flash()


func _on_health_health_changed(current: int, maximum: int) -> void:
	health_changed.emit(current, maximum)


func _on_health_died() -> void:
	died.emit()
	queue_free()
