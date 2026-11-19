class_name Imp
extends Node2D
## Diablillo constructor: persigue a Cantuña y lo daña al tocarlo.
##
## Lo crea el [EnemySpawner], que le inyecta el objetivo y su dificultad con [method setup].

## El diablillo fue derrotado.
signal died(imp: Imp)

## Experiencia que suelta al morir.
@export var xp_value: int = 1

var target: Node2D
var speed: float = 40.0

@onready var _figure: PixelFigure = $Figure
@onready var _health: HealthComponent = $HealthComponent
@onready var _hurtbox: HurtboxComponent = $HurtboxComponent
@onready var _hitbox: HitboxComponent = $HitboxComponent


func _ready() -> void:
	_figure.is_walking = true
	_hurtbox.hurt.connect(_on_hurtbox_hurt)
	_health.died.connect(_on_health_died)


func _physics_process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		return
	var direction: Vector2 = global_position.direction_to(target.global_position)
	global_position += direction * speed * delta
	_figure.is_facing_left = direction.x < 0.0


## Configura al diablillo según la dificultad actual de la noche.
func setup(chase_target: Node2D, max_health: int, move_speed: float, contact_damage: int) -> void:
	target = chase_target
	speed = move_speed
	_health.max_health = max_health
	_health.reset()
	_hitbox.damage = contact_damage


func _on_hurtbox_hurt(amount: int) -> void:
	_health.damage(amount)
	_figure.flash()


func _on_health_died() -> void:
	died.emit(self)
	queue_free()
