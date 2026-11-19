class_name HitboxComponent
extends Area2D
## Zona que causa daño al tocar un [HurtboxComponent] (un proyectil, el cuerpo de un diablillo).

## Este hitbox acaba de dañar a [param hurtbox].
signal hit_landed(hurtbox: Area2D)

## Daño que causa cada golpe.
@export var damage: int = 10

## Si es [code]false[/code], el hitbox ya no causa daño (por ejemplo, un proyectil que ya impactó).
var is_active: bool = true


## Avisa que el golpe se aplicó. Lo llama el [HurtboxComponent] que recibió el daño.
func register_hit(hurtbox: Area2D) -> void:
	hit_landed.emit(hurtbox)


## Deja de causar daño de forma permanente.
func deactivate() -> void:
	is_active = false
	set_deferred("monitorable", false)
