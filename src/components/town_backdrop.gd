@tool
class_name TownBackdrop
extends Node2D
## Dibuja el escenario de Quito colonial: el piso, la fachada de San Francisco, la pileta,
## los puestos del mercado y los faroles.
##
## Es arte original hecho por código. Se dibuja una sola vez (no usa [code]_process[/code]).

## Tipo de piso.
enum FloorStyle { COBBLESTONE, DIRT }

const CHURCH_HEIGHT: float = 128.0
const CHURCH_WIDTH: float = 360.0
const TOWER_WIDTH: float = 56.0
const TOWER_EXTRA_HEIGHT: float = 0.0
const DOOR_SIZE: Vector2 = Vector2(36, 52)
const FOUNTAIN_RADIUS: float = 26.0
const STALL_SIZE: Vector2 = Vector2(44, 26)
const LANTERN_GLOW_RADII: Array[float] = [40.0, 26.0, 14.0]

@export var area_size: Vector2 = Vector2(960, 540):
	set(value):
		area_size = value
		queue_redraw()
@export var floor_style: FloorStyle = FloorStyle.COBBLESTONE:
	set(value):
		floor_style = value
		queue_redraw()
@export var tile_size: int = 16
@export var floor_color: Color = Color("6f6a73")
@export var floor_accent_color: Color = Color("8d8790")
@export var mortar_color: Color = Color("4a4650")
@export var random_seed: int = 7

@export_group("Iglesia")
@export var has_church: bool = true:
	set(value):
		has_church = value
		queue_redraw()
## Dibuja andamios y huecos (la obra del atrio sin terminar).
@export var is_church_unfinished: bool = false:
	set(value):
		is_church_unfinished = value
		queue_redraw()
@export var church_color: Color = Color("d9cfbf")
@export var church_shadow_color: Color = Color("a89d8c")
@export var window_color: Color = Color("2b2433")

@export_group("Decoración")
@export var has_fountain: bool = true
@export var fountain_position: Vector2 = Vector2(480, 340)
@export var water_color: Color = Color("5b8fb0")
@export var stall_positions: PackedVector2Array = PackedVector2Array()
@export var awning_colors: PackedColorArray = PackedColorArray([Color("b5482f"), Color("d4a03c")])
@export var lantern_positions: PackedVector2Array = PackedVector2Array()
@export var lantern_glow_color: Color = Color(1.0, 0.8, 0.4, 0.12)


func _draw() -> void:
	_draw_floor()
	if has_church:
		_draw_church()
	if has_fountain:
		_draw_fountain()
	for i: int in stall_positions.size():
		_draw_stall(stall_positions[i], awning_colors[i % awning_colors.size()])
	for lantern_position: Vector2 in lantern_positions:
		_draw_lantern(lantern_position)


func _draw_floor() -> void:
	draw_rect(Rect2(Vector2.ZERO, area_size), mortar_color)
	var rng := RandomNumberGenerator.new()
	rng.seed = random_seed
	var columns: int = ceili(area_size.x / tile_size)
	var rows: int = ceili(area_size.y / tile_size)
	for row: int in rows:
		# En el empedrado, cada fila se desplaza media piedra.
		var offset: float = (
			tile_size * 0.5 if floor_style == FloorStyle.COBBLESTONE and row % 2 == 1 else 0.0
		)
		for column: int in columns + 1:
			var color: Color = floor_color.lerp(floor_accent_color, rng.randf() * 0.6)
			var origin := Vector2(column * tile_size - offset, row * tile_size)
			var gap: float = 1.0 if floor_style == FloorStyle.COBBLESTONE else 0.0
			draw_rect(Rect2(origin, Vector2(tile_size - gap, tile_size - gap)), color)


func _draw_church() -> void:
	var left: float = (area_size.x - CHURCH_WIDTH) * 0.5
	draw_rect(
		Rect2(left - TOWER_WIDTH, 0, CHURCH_WIDTH + TOWER_WIDTH * 2.0, CHURCH_HEIGHT),
		church_shadow_color
	)
	draw_rect(Rect2(left, 0, CHURCH_WIDTH, CHURCH_HEIGHT - 4.0), church_color)
	_draw_tower(left - TOWER_WIDTH)
	_draw_tower(left + CHURCH_WIDTH)
	var door_origin := Vector2(area_size.x * 0.5 - DOOR_SIZE.x * 0.5, CHURCH_HEIGHT - DOOR_SIZE.y)
	draw_rect(Rect2(door_origin, DOOR_SIZE), window_color)
	draw_circle(door_origin + Vector2(DOOR_SIZE.x * 0.5, 0), DOOR_SIZE.x * 0.5, window_color)
	for i: int in 4:
		var x: float = left + 40.0 + i * 92.0
		if absf(x + 8.0 - area_size.x * 0.5) < DOOR_SIZE.x:
			continue
		draw_rect(Rect2(x, 34, 16, 26), window_color)
	draw_rect(
		Rect2(left - TOWER_WIDTH, CHURCH_HEIGHT - 6.0, CHURCH_WIDTH + TOWER_WIDTH * 2.0, 6),
		church_shadow_color
	)
	if is_church_unfinished:
		_draw_scaffolding(left)


func _draw_tower(x: float) -> void:
	draw_rect(Rect2(x + 4, 0, TOWER_WIDTH - 8, CHURCH_HEIGHT - 6.0), church_color.darkened(0.06))
	draw_rect(Rect2(x + 18, 20, 20, 30), window_color)
	draw_circle(Vector2(x + 28, 20), 10, window_color)


func _draw_scaffolding(left: float) -> void:
	var wood := Color("7a5634")
	for i: int in 6:
		var x: float = left + 20.0 + i * 64.0
		draw_rect(Rect2(x, 10, 3, CHURCH_HEIGHT - 10.0), wood)
	for y: float in [30.0, 70.0, 108.0]:
		draw_rect(Rect2(left + 10.0, y, CHURCH_WIDTH - 20.0, 3), wood)


func _draw_fountain() -> void:
	draw_circle(fountain_position + Vector2(0, 4), FOUNTAIN_RADIUS + 4.0, Color(0, 0, 0, 0.25))
	draw_circle(fountain_position, FOUNTAIN_RADIUS + 4.0, church_shadow_color)
	draw_circle(fountain_position, FOUNTAIN_RADIUS, water_color)
	draw_circle(fountain_position, 7.0, church_color)
	draw_rect(Rect2(fountain_position + Vector2(-2, -18), Vector2(4, 14)), church_color)


func _draw_stall(origin: Vector2, awning: Color) -> void:
	var wood := Color("6b4a2f")
	draw_rect(Rect2(origin + Vector2(2, 8), Vector2(STALL_SIZE.x - 4, STALL_SIZE.y - 8)), wood)
	draw_rect(Rect2(origin, Vector2(STALL_SIZE.x, 9)), awning)
	for i: int in 4:
		var stripe := Rect2(origin + Vector2(i * 11.0, 0), Vector2(5, 9))
		draw_rect(stripe, awning.lightened(0.3))
	draw_rect(Rect2(origin + Vector2(6, 14), Vector2(8, 5)), Color("d8b54a"))
	draw_rect(Rect2(origin + Vector2(18, 14), Vector2(8, 5)), Color("7aa14a"))


func _draw_lantern(base: Vector2) -> void:
	for radius: float in LANTERN_GLOW_RADII:
		draw_circle(base + Vector2(0, -22), radius, lantern_glow_color)
	draw_rect(Rect2(base + Vector2(-1, -20), Vector2(2, 20)), Color("2b2523"))
	draw_rect(Rect2(base + Vector2(-3, -27), Vector2(6, 7)), Color("f2c35b"))
