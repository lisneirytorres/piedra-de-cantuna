class_name Projectile
extends HitboxComponent
## Proyectil que viaja en línea recta y desaparece al impactar o al agotar su vida útil.
##
## En el juego son las piedrecitas que Cantuña lanza contra los diablillos.

## Segundos antes de desaparecer si no impacta.
@export var lifetime: float = 1.0
@export var radius: float = 2.5
@export var color: Color = Color("cfc6b8")
@export var outline_color: Color = Color("4d463f")

var _direction: Vector2 = Vector2.RIGHT
var _speed: float = 0.0
var _time_left: float = 0.0


func _ready() -> void:
	hit_landed.connect(_on_hit_landed)


func _physics_process(delta: float) -> void:
	global_position += _direction * _speed * delta
	_time_left -= delta
	if _time_left <= 0.0:
		queue_free()


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius + 1.0, outline_color)
	draw_circle(Vector2.ZERO, radius, color)


## Dispara el proyectil desde [param from] hacia [param direction].
func launch(from: Vector2, direction: Vector2, hit_damage: int, speed: float) -> void:
	global_position = from
	_direction = direction.normalized()
	damage = hit_damage
	_speed = speed
	_time_left = lifetime


func _on_hit_landed(_hurtbox: Area2D) -> void:
	deactivate()
	queue_free()
