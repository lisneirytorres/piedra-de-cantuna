@tool
class_name PixelFigure
extends Node2D
## Dibuja un personaje pixelado a partir de un [FigureAppearance].
##
## Es el arte original del juego hecho por código: no depende de imágenes externas.
## El origen del nodo está a los pies del personaje, para que el orden por Y funcione bien.

const FLASH_DURATION: float = 0.12
const WALK_CYCLE_SPEED: float = 10.0
const OUTLINE_COLOR: Color = Color(0.05, 0.04, 0.06, 0.9)
const SHADOW_COLOR: Color = Color(0.0, 0.0, 0.0, 0.3)
const CARRIED_STONE_COLOR: Color = Color("9a9184")
const CARRIED_STONE_EDGE: Color = Color("6c655c")

## Colores y tocado del personaje.
@export var appearance: FigureAppearance:
	set(value):
		appearance = value
		queue_redraw()
## Dibuja una piedra sobre la cabeza.
@export var is_carrying: bool = false:
	set(value):
		is_carrying = value
		queue_redraw()

## Activa la animación de caminar.
var is_walking: bool = false:
	set(value):
		is_walking = value
		queue_redraw()
## Mira hacia la izquierda (voltea el dibujo).
var is_facing_left: bool = false:
	set(value):
		is_facing_left = value
		queue_redraw()

var _walk_time: float = 0.0
var _flash_time_left: float = 0.0


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if is_walking:
		_walk_time += delta * WALK_CYCLE_SPEED
		queue_redraw()
	if _flash_time_left > 0.0:
		_flash_time_left -= delta
		queue_redraw()


## Destella en blanco un instante (al recibir daño).
func flash() -> void:
	_flash_time_left = FLASH_DURATION
	queue_redraw()


func _draw() -> void:
	var look: FigureAppearance = appearance if appearance != null else FigureAppearance.new()
	var step: int = int(sign(sin(_walk_time))) if is_walking else 0
	var bob: float = -1.0 if is_walking and absf(sin(_walk_time)) > 0.7 else 0.0
	draw_rect(Rect2(-5, -1, 10, 2), SHADOW_COLOR)
	if is_facing_left:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(-1, 1))
	_draw_legs(look, step)
	_draw_body(look, bob)
	_draw_head(look, bob)
	_draw_headwear(look, bob)
	if is_carrying:
		_draw_carried_stone(bob)


func _tint(color: Color) -> Color:
	return Color.WHITE if _flash_time_left > 0.0 else color


func _draw_legs(look: FigureAppearance, step: int) -> void:
	draw_rect(Rect2(-3, -5 + mini(step, 0), 2, 5 - mini(step, 0)), _tint(look.legs_color))
	draw_rect(Rect2(1, -5 - maxi(step, 0), 2, 5 + maxi(step, 0)), _tint(look.legs_color))


func _draw_body(look: FigureAppearance, bob: float) -> void:
	draw_rect(Rect2(-5, -13 + bob, 10, 9), _tint(OUTLINE_COLOR))
	draw_rect(Rect2(-4, -12 + bob, 8, 7), _tint(look.body_color))
	draw_rect(Rect2(-4, -7 + bob, 8, 1), _tint(look.body_color.darkened(0.3)))
	draw_rect(Rect2(-6, -11 + bob, 2, 5), _tint(look.skin_color))
	draw_rect(Rect2(4, -11 + bob, 2, 5), _tint(look.skin_color))


func _draw_head(look: FigureAppearance, bob: float) -> void:
	draw_rect(Rect2(-4, -19 + bob, 8, 7), _tint(OUTLINE_COLOR))
	draw_rect(Rect2(-3, -18 + bob, 6, 5), _tint(look.skin_color))
	draw_rect(Rect2(-3, -18 + bob, 6, 2), _tint(look.hair_color))
	draw_rect(Rect2(1, -15 + bob, 1, 1), _tint(look.eye_color))
	draw_rect(Rect2(-2, -15 + bob, 1, 1), _tint(look.eye_color))


func _draw_headwear(look: FigureAppearance, bob: float) -> void:
	var color: Color = _tint(look.headwear_color)
	match look.headwear:
		FigureAppearance.Headwear.HOOD:
			draw_rect(Rect2(-4, -20 + bob, 8, 3), color)
			draw_rect(Rect2(-4, -17 + bob, 1, 5), color)
			draw_rect(Rect2(3, -17 + bob, 1, 5), color)
		FigureAppearance.Headwear.HAT:
			draw_rect(Rect2(-6, -19 + bob, 12, 1), color)
			draw_rect(Rect2(-3, -22 + bob, 6, 3), color)
		FigureAppearance.Headwear.HORNS:
			draw_colored_polygon(_horn(-3, bob), color)
			draw_colored_polygon(_horn(3, bob), color)
		FigureAppearance.Headwear.SHAWL:
			draw_rect(Rect2(-4, -20 + bob, 8, 3), color)
			draw_rect(Rect2(-5, -17 + bob, 2, 7), color)
			draw_rect(Rect2(3, -17 + bob, 2, 7), color)
		FigureAppearance.Headwear.CAP:
			draw_rect(Rect2(-4, -20 + bob, 8, 2), color)


func _horn(x: float, bob: float) -> PackedVector2Array:
	var direction: float = sign(x)
	return PackedVector2Array(
		[
			Vector2(x - direction, -18 + bob),
			Vector2(x + direction * 2.0, -23 + bob),
			Vector2(x + direction, -18 + bob),
		]
	)


func _draw_carried_stone(bob: float) -> void:
	draw_rect(Rect2(-6, -27 + bob, 12, 8), _tint(CARRIED_STONE_EDGE))
	draw_rect(Rect2(-5, -26 + bob, 10, 6), _tint(CARRIED_STONE_COLOR))
