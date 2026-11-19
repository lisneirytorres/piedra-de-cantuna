class_name HealthComponent
extends Node
## Puntos de vida de un actor.
##
## Lleva la cuenta de la vida y avisa con señales; el dueño decide qué hacer al morir.

## Cambió la vida actual o la máxima.
signal health_changed(current: int, maximum: int)
## La vida llegó a cero.
signal died

## Vida máxima.
@export var max_health: int = 100

## Vida actual.
var current_health: int = 0
## [code]true[/code] desde que la vida llegó a cero hasta el próximo [method reset].
var is_dead: bool = false


func _ready() -> void:
	reset()


## Restaura la vida al máximo.
func reset() -> void:
	current_health = max_health
	is_dead = false
	health_changed.emit(current_health, max_health)


## Resta [param amount] puntos de vida. Ignora valores no positivos o si ya está muerto.
func damage(amount: int) -> void:
	if is_dead or amount <= 0:
		return
	current_health = maxi(current_health - amount, 0)
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		is_dead = true
		died.emit()


## Suma [param amount] puntos de vida sin pasar del máximo.
func heal(amount: int) -> void:
	if is_dead or amount <= 0:
		return
	current_health = mini(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)


## Aumenta la vida máxima y cura la misma cantidad.
func increase_max(amount: int) -> void:
	if amount <= 0:
		return
	max_health += amount
	heal(amount)


## Proporción de vida restante, entre 0 y 1.
func get_ratio() -> float:
	if max_health <= 0:
		return 0.0
	return float(current_health) / float(max_health)
