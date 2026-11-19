class_name XpGem
extends Node2D
## Fragmento de luz que sueltan los diablillos. Al recogerlo, Cantuña gana experiencia.
##
## Se acerca solo al jugador cuando está dentro de [member magnet_radius].

## El jugador recogió el fragmento.
signal collected(value: int)

@export var magnet_radius: float = 56.0
@export var collect_radius: float = 8.0
@export var magnet_speed: float = 200.0
@export var color: Color = Color("7fd8e8")

## Experiencia que otorga.
var value: int = 1
## Nodo que lo recoge (el jugador).
var target: Node2D


func _physics_process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		return
	var distance: float = global_position.distance_to(target.global_position)
	if distance <= collect_radius:
		collected.emit(value)
		queue_free()
		return
	if distance <= magnet_radius:
		global_position = global_position.move_toward(target.global_position, magnet_speed * delta)


func _draw() -> void:
	var points := PackedVector2Array(
		[Vector2(0, -7), Vector2(3, -4), Vector2(0, -1), Vector2(-3, -4)]
	)
	draw_colored_polygon(points, color)
